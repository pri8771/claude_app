//
//  ModelPersistenceTests.swift
//  HindsightTests
//
//  Exercises the SwiftData model layer: decision/prediction/outcome
//  persistence actually round-trips through disk (not just an in-memory
//  reference), cascade-delete rules hold, and the derived `Decision`
//  properties compute correctly. This is the second thing Docs/STATUS.md
//  flags as unverified.
//

import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class ModelPersistenceTests: XCTestCase {

    private var storeDirectory: URL!

    /// Keeps every `ModelContainer` created by a test alive for that test's
    /// duration. SwiftData does not keep a store usable once its
    /// `ModelContainer` is deallocated: a helper that builds a container and
    /// returns only `container.mainContext` lets the container fall out of
    /// scope on return, leaving the caller holding a context backed by an
    /// already-torn-down store (fetches on it crash rather than throw).
    /// Each test method gets a fresh instance of this class, so there is
    /// nothing to reset between tests.
    private var retainedContainers: [ModelContainer] = []

    private static var schema: Schema {
        Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HindsightModelPersistenceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        retainedContainers.removeAll()
        if let storeDirectory {
            try? FileManager.default.removeItem(at: storeDirectory)
        }
        try super.tearDownWithError()
    }

    /// A fresh, isolated in-memory context for tests that don't need to
    /// survive a reload.
    private func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(schema: Self.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Self.schema, configurations: [config])
        retainedContainers.append(container)
        return container.mainContext
    }

    /// A file-backed container pointed at this test's private store URL, so
    /// callers can close it and reopen a second container against the same
    /// file to prove data actually reached disk.
    private func makeFileBackedContainer(filename: String = "test.store") throws -> ModelContainer {
        let storeURL = storeDirectory.appendingPathComponent(filename)
        let config = ModelConfiguration(schema: Self.schema, url: storeURL)
        let container = try ModelContainer(for: Self.schema, configurations: [config])
        retainedContainers.append(container)
        return container
    }

    // MARK: Round trip through disk

    func testDecisionWithFullGraphSurvivesAReload() throws {
        let decisionID = UUID()
        let optionID = UUID()
        let predictionID = UUID()

        do {
            let container = try makeFileBackedContainer()
            let context = container.mainContext

            let decision = Decision(
                title: "Take the Northwind offer",
                notes: "Bigger comp, riskier company.",
                category: .career,
                stakesLevel: .high,
                status: .awaitingReview,
                isReversible: false,
                clarityScore: 82,
                dueDate: Date(timeIntervalSinceNow: 86_400)
            )
            decision.id = decisionID

            let option = DecisionOption(title: "Take it", upside: "Growth", downside: "Risk")
            option.id = optionID
            decision.options = [option]

            let prediction = Prediction(title: "I'll be glad I switched", probabilityPercent: 75)
            prediction.id = predictionID
            decision.predictions = [prediction]

            context.insert(decision)
            try context.save()
        }

        // Reopen a brand new container against the same store file — if the
        // graph didn't actually persist, none of this would fetch back.
        let reopened = try makeFileBackedContainer()
        let context = reopened.mainContext

        let fetchedDecision = try XCTUnwrap(
            try context.fetch(FetchDescriptor<Decision>(predicate: #Predicate { $0.id == decisionID })).first
        )
        XCTAssertEqual(fetchedDecision.title, "Take the Northwind offer")
        XCTAssertEqual(fetchedDecision.category, .career)
        XCTAssertEqual(fetchedDecision.stakesLevel, .high)
        XCTAssertEqual(fetchedDecision.clarityScore, 82)
        XCTAssertFalse(fetchedDecision.isReversible)

        XCTAssertEqual(fetchedDecision.options.count, 1)
        XCTAssertEqual(fetchedDecision.options.first?.id, optionID)
        XCTAssertEqual(fetchedDecision.options.first?.upside, "Growth")

        XCTAssertEqual(fetchedDecision.predictions.count, 1)
        XCTAssertEqual(fetchedDecision.predictions.first?.id, predictionID)
        XCTAssertEqual(fetchedDecision.predictions.first?.status, .pending)

        // The inverse relationships should also have rehydrated correctly.
        XCTAssertEqual(fetchedDecision.options.first?.decision?.id, decisionID)
        XCTAssertEqual(fetchedDecision.predictions.first?.decision?.id, decisionID)
    }

    func testOutcomeReviewSurvivesAReload() throws {
        let decisionID = UUID()

        do {
            let container = try makeFileBackedContainer()
            let context = container.mainContext
            let decision = Decision(title: "Move apartments")
            decision.id = decisionID
            decision.status = .reviewed
            decision.outcomeReview = OutcomeReview(
                whatHappened: "Saved money, missed the old neighborhood.",
                outcomeQuality: 4,
                decisionQuality: 5,
                wouldDoAgain: true,
                whatSurprised: "Commute got worse than expected",
                mainLesson: "Weigh commute time more heavily"
            )
            context.insert(decision)
            try context.save()
        }

        let reopened = try makeFileBackedContainer()
        let context = reopened.mainContext
        let fetched = try XCTUnwrap(
            try context.fetch(FetchDescriptor<Decision>(predicate: #Predicate { $0.id == decisionID })).first
        )

        let review = try XCTUnwrap(fetched.outcomeReview)
        XCTAssertEqual(review.whatHappened, "Saved money, missed the old neighborhood.")
        XCTAssertEqual(review.outcomeQuality, 4)
        XCTAssertEqual(review.decisionQuality, 5)
        XCTAssertTrue(review.wouldDoAgain)
        XCTAssertEqual(review.mainLesson, "Weigh commute time more heavily")
        XCTAssertEqual(review.decision?.id, decisionID)
    }

    // MARK: Cascade deletes

    func testDeletingDecisionCascadesToOptionsPredictionsAndReview() throws {
        let context = try makeInMemoryContext()

        let decision = Decision(title: "Side project")
        decision.options = [DecisionOption(title: "Build it"), DecisionOption(title: "Skip it")]
        decision.predictions = [Prediction(title: "I'll finish it")]
        decision.outcomeReview = OutcomeReview(whatHappened: "Shipped a v1")
        context.insert(decision)
        try context.save()

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<DecisionOption>()), 2)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<OutcomeReview>()), 1)

        context.delete(decision)
        try context.save()

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<DecisionOption>()), 0,
                       "Options should cascade-delete with their decision")
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 0,
                       "Predictions should cascade-delete with their decision")
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<OutcomeReview>()), 0,
                       "The outcome review should cascade-delete with its decision")
    }

    func testDeletingOneDecisionDoesNotAffectAnother() throws {
        let context = try makeInMemoryContext()

        let keep = Decision(title: "Keep me")
        keep.predictions = [Prediction(title: "Stays put")]
        let remove = Decision(title: "Remove me")
        remove.predictions = [Prediction(title: "Goes away")]
        context.insert(keep)
        context.insert(remove)
        try context.save()

        context.delete(remove)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "Keep me")
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 1)
    }

    // MARK: Derived state

    func testIsPastDueAndNeedsReview() {
        let past = Decision(title: "Past", status: .awaitingReview, dueDate: Date(timeIntervalSinceNow: -3_600))
        XCTAssertTrue(past.isPastDue)
        XCTAssertTrue(past.needsReview)

        let future = Decision(title: "Future", status: .awaitingReview, dueDate: Date(timeIntervalSinceNow: 3_600))
        XCTAssertFalse(future.isPastDue)
        XCTAssertFalse(future.needsReview)

        let reviewed = Decision(title: "Reviewed", status: .reviewed, dueDate: Date(timeIntervalSinceNow: -3_600))
        XCTAssertFalse(reviewed.isPastDue, "A reviewed decision is never past due, regardless of its date")
        XCTAssertFalse(reviewed.needsReview)
    }

    func testChosenOptionResolvesAgainstStoredTitle() {
        let decision = Decision(title: "Pick one")
        decision.options = [DecisionOption(title: "A"), DecisionOption(title: "B")]
        decision.chosenOptionTitle = "B"
        XCTAssertEqual(decision.chosenOption?.title, "B")

        decision.chosenOptionTitle = "Not an option"
        XCTAssertNil(decision.chosenOption)
    }

    func testSortedPredictionsPutsPendingFirstThenByDueDate() {
        let decision = Decision(title: "d")
        let resolvedSoon = Prediction(title: "resolved soon", dueDate: Date(timeIntervalSinceNow: 100), status: .correct)
        let pendingLate = Prediction(title: "pending late", dueDate: Date(timeIntervalSinceNow: 500), status: .pending)
        let pendingSoon = Prediction(title: "pending soon", dueDate: Date(timeIntervalSinceNow: 200), status: .pending)
        decision.predictions = [resolvedSoon, pendingLate, pendingSoon]

        let sorted = decision.sortedPredictions
        XCTAssertEqual(sorted.map(\.title), ["pending soon", "pending late", "resolved soon"])
    }

    func testAverageConfidenceAcrossPredictions() {
        let decision = Decision(title: "d")
        decision.predictions = [
            Prediction(probabilityPercent: 20),
            Prediction(probabilityPercent: 80)
        ]
        XCTAssertEqual(decision.averageConfidence, 50)

        XCTAssertEqual(Decision(title: "empty").averageConfidence, 0)
    }

    func testWasGoodOutcomeRequiresHighQualityAndWouldDoAgain() {
        let good = Decision(title: "good")
        good.outcomeReview = OutcomeReview(outcomeQuality: 5, wouldDoAgain: true)
        XCTAssertTrue(good.wasGoodOutcome)

        let regretted = Decision(title: "regretted")
        regretted.outcomeReview = OutcomeReview(outcomeQuality: 5, wouldDoAgain: false)
        XCTAssertFalse(regretted.wasGoodOutcome)

        let mediocre = Decision(title: "mediocre")
        mediocre.outcomeReview = OutcomeReview(outcomeQuality: 3, wouldDoAgain: true)
        XCTAssertFalse(mediocre.wasGoodOutcome)

        XCTAssertFalse(Decision(title: "unreviewed").wasGoodOutcome)
    }
}
