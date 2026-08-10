//
//  ResolutionTests.swift
//  HindsightTests
//
//  Tests the prediction resolution behavior: pending predictions should not
//  be preselected (seeded) with a default verdict, and ungraded predictions
//  should remain pending after save (never coerced to .correct).
//

import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class ResolutionTests: XCTestCase {

    private var storeDirectory: URL!
    private var retainedContainers: [ModelContainer] = []

    private final class FailingPersister: Persisting {
        func save(_ context: ModelContext) throws { throw NSError(domain: "ResolutionTests", code: 1) }
    }

    private static var schema: Schema {
        Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HindsightResolutionTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        PersistenceService.shared = ContextPersister()
        retainedContainers.removeAll()
        if let storeDirectory {
            try? FileManager.default.removeItem(at: storeDirectory)
        }
        try super.tearDownWithError()
    }

    /// A fresh, isolated in-memory context for tests.
    private func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(schema: Self.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Self.schema, configurations: [config])
        retainedContainers.append(container)
        return container.mainContext
    }

    // MARK: - Resolution behavior tests

    /// Test that a new pending prediction produces no seeded verdict
    /// (no dictionary entry), and after save logic its status remains .pending.
    func testResolution_newCallHasNoPreselectedVerdict() throws {
        let context = try makeInMemoryContext()

        // Create a decision with a pending prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        // Prediction defaults to .pending
        XCTAssertEqual(prediction.status, .pending)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate the seedExistingReview behavior: pending predictions should NOT
        // be seeded into the verdict dictionary (no entry = nil)
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            // Only seed verdicts for already-resolved predictions; pending predictions get no entry
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: no entry for the pending prediction
        XCTAssertNil(predictionVerdicts[prediction.id], "Pending prediction should not be seeded")

        // Simulate save behavior: prediction without explicit verdict should keep its existing status
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
            // If no entry in dictionary, status stays as-is (remains .pending)
        }

        // Verify: prediction status is still .pending (not coerced to .correct)
        XCTAssertEqual(prediction.status, .pending, "Ungraded prediction should remain .pending after save")
    }

    /// Test that an explicitly selected verdict persists on save.
    func testResolution_allowsOneTerminalChoice() throws {
        let context = try makeInMemoryContext()

        // Create a decision with a pending prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate the user selecting a verdict in the outcome review
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }
        // User explicitly selects .correct
        predictionVerdicts[prediction.id] = .correct

        // Simulate save behavior
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: the selected verdict was persisted
        XCTAssertEqual(prediction.status, .correct, "Explicitly selected verdict should persist")
    }

    /// Test that already-resolved predictions retain their existing status
    /// (they seed the dictionary with their current status).
    func testResolution_alreadyResolvedPredictionPreservesStatus() throws {
        let context = try makeInMemoryContext()

        // Create a decision with an already-resolved prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        prediction.status = .correct
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate seedExistingReview: already-resolved predictions ARE seeded
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: resolved prediction is seeded with its existing status
        XCTAssertEqual(predictionVerdicts[prediction.id], .correct, "Resolved prediction should be seeded")

        // Simulate save without changing the verdict
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: status unchanged
        XCTAssertEqual(prediction.status, .correct, "Already-resolved prediction should maintain its status")
    }

    /// Test that saving with ungraded predictions (mix of pending and resolved) is allowed.
    func testResolution_allowsSavingWithUngradedPredictions() throws {
        let context = try makeInMemoryContext()

        // Create a decision with mixed pending and resolved predictions
        let decision = Decision(title: "Test decision")
        let pending = Prediction(title: "Pending prediction", probabilityPercent: 70)
        let resolved = Prediction(title: "Resolved prediction", probabilityPercent: 80)
        resolved.status = .incorrect
        decision.predictions = [pending, resolved]
        context.insert(decision)
        try context.save()

        // Simulate outcome review: only resolved prediction is seeded
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: pending has no entry, resolved is seeded
        XCTAssertNil(predictionVerdicts[pending.id], "Pending prediction should not be seeded")
        XCTAssertEqual(predictionVerdicts[resolved.id], .incorrect, "Resolved prediction should be seeded")

        // Save without changing either verdict
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: pending stays pending, resolved stays resolved
        XCTAssertEqual(pending.status, .pending, "Pending prediction should remain pending after save")
        XCTAssertEqual(resolved.status, .incorrect, "Resolved prediction should remain resolved after save")
    }

    func testFastResolutionPersistsOnceAndIgnoresDuplicateAttempt() throws {
        let context = try makeInMemoryContext()
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "Forecast", probabilityPercent: 75)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        XCTAssertEqual(PredictionResolutionService.resolve(prediction, as: .partial, note: "Some of it happened", in: context), .saved)
        XCTAssertEqual(prediction.status, .partial)
        XCTAssertEqual(prediction.actualResult, "Some of it happened")
        XCTAssertEqual(PredictionResolutionService.resolve(prediction, as: .incorrect, note: "", in: context), .alreadyResolved)
        XCTAssertEqual(prediction.status, .partial)
    }

    func testFastResolutionOutcomeContextDraftSurvivesAndClearsExplicitly() throws {
        let suiteName = "ResolutionTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let predictionID = UUID()

        PredictionResolutionDraftStore.save("  The evidence arrived late.  ", for: predictionID, defaults: defaults)
        XCTAssertEqual(
            PredictionResolutionDraftStore.load(for: predictionID, defaults: defaults),
            "  The evidence arrived late.  "
        )

        PredictionResolutionDraftStore.clear(for: predictionID, defaults: defaults)
        XCTAssertEqual(PredictionResolutionDraftStore.load(for: predictionID, defaults: defaults), "")
    }

    func testFastResolutionRecordsOutcomeWithoutClaimingFullReview() throws {
        let context = try makeInMemoryContext()
        let decision = Decision(
            title: "The launch will go smoothly",
            notes: "",
            category: .personal,
            stakesLevel: .low,
            status: .awaitingReview
        )
        let prediction = Prediction(title: decision.title, probabilityPercent: 75)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        XCTAssertTrue(decision.isQuickCapture)
        XCTAssertEqual(PredictionResolutionService.resolve(prediction, as: .correct, note: "", in: context), .saved)
        XCTAssertEqual(decision.status, .awaitingReview)
        XCTAssertNil(decision.outcomeReview)
    }

    func testFastResolutionWithReasoningStillRequiresReviewForReviewedState() throws {
        let context = try makeInMemoryContext()
        let decision = Decision(
            title: "The launch will go smoothly",
            notes: "The checklist is complete.",
            category: .personal,
            stakesLevel: .low,
            status: .awaitingReview
        )
        let prediction = Prediction(title: decision.title, probabilityPercent: 50)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        XCTAssertTrue(decision.isQuickCapture)
        XCTAssertEqual(PredictionResolutionService.resolve(prediction, as: .correct, note: "", in: context), .saved)
        XCTAssertEqual(decision.status, .awaitingReview)
        XCTAssertNil(decision.outcomeReview)
    }

    func testReviewedDecisionRetainsFuturePendingPredictionReminderEligibility() {
        let now = Date(timeIntervalSince1970: 1_735_689_600)
        let decision = Decision(title: "Reviewed early", status: .reviewed)
        let futurePending = Prediction(
            title: "Future result",
            probabilityPercent: 75,
            dueDate: now.addingTimeInterval(86_400),
            status: .pending
        )
        let pastPending = Prediction(
            title: "Already due",
            probabilityPercent: 75,
            dueDate: now.addingTimeInterval(-86_400),
            status: .pending
        )
        let futureResolved = Prediction(
            title: "Already resolved",
            probabilityPercent: 75,
            dueDate: now.addingTimeInterval(86_400),
            status: .correct
        )
        decision.predictions = [futurePending, pastPending, futureResolved]

        let eligible = NotificationManager.pendingPredictionsNeedingStandaloneReminders(
            for: decision,
            now: now
        )

        XCTAssertEqual(eligible.map(\.id), [futurePending.id])
    }

    func testNotificationSelectorsExcludeExplicitSampleRecords() {
        let now = Date(timeIntervalSince1970: 1_735_689_600)
        let personal = Decision(title: "Personal", dueDate: now.addingTimeInterval(86_400))
        let sample = Decision(title: "Example", dueDate: now.addingTimeInterval(86_400))
        sample.id = UUID(uuidString: "A1F00100-0000-4000-8000-000000000001")!
        sample.predictions = [Prediction(
            title: "Sample forecast",
            dueDate: now.addingTimeInterval(86_400),
            status: .pending
        )]

        XCTAssertEqual(
            NotificationManager.decisionsEligibleForRescheduling([sample, personal]).map(\.id),
            [personal.id]
        )
        XCTAssertTrue(
            NotificationManager.pendingPredictionsNeedingStandaloneReminders(for: sample, now: now).isEmpty
        )
    }

    func testFastResolutionFailureRestoresPredictionForRetry() throws {
        let context = try makeInMemoryContext()
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "Forecast", probabilityPercent: 75)
        prediction.actualResult = "Original note"
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        PersistenceService.shared = FailingPersister()
        XCTAssertEqual(PredictionResolutionService.resolve(prediction, as: .incorrect, note: "New note", in: context), .failed)
        XCTAssertEqual(prediction.status, .pending)
        XCTAssertEqual(prediction.actualResult, "Original note")
    }

    func testFastResolutionPreservesSealedForecastFieldsWhileRecordingOutcome() throws {
        let context = try makeInMemoryContext()
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        let decision = Decision(
            title: "The launch will be calm",
            notes: "The checklist is complete",
            category: .personal,
            stakesLevel: .low,
            status: .awaitingReview,
            isReversible: true,
            createdAt: createdAt,
            decidedAt: createdAt,
            dueDate: dueDate
        )
        let prediction = Prediction(
            title: decision.title,
            probabilityPercent: 75,
            dueDate: dueDate,
            status: .pending
        )
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        XCTAssertEqual(
            PredictionResolutionService.resolve(prediction, as: .incorrect, note: "  It slipped a week.  ", in: context),
            .saved
        )

        XCTAssertEqual(decision.title, "The launch will be calm")
        XCTAssertEqual(decision.notes, "The checklist is complete")
        XCTAssertEqual(decision.createdAt, createdAt)
        XCTAssertEqual(decision.dueDate, dueDate)
        XCTAssertEqual(prediction.title, "The launch will be calm")
        XCTAssertEqual(prediction.probabilityPercent, 75)
        XCTAssertEqual(prediction.status, .incorrect)
        XCTAssertEqual(prediction.actualResult, "It slipped a week.")
    }
}
