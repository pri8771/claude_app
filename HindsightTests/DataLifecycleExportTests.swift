import XCTest
import SwiftData
@testable import Hindsight

private struct DataLifecycleFailingPersister: Persisting {
    func save(_ context: ModelContext) throws {
        throw NSError(domain: "DataLifecycleExportTests", code: 1)
    }
}

@MainActor
final class DataLifecycleExportTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
    }

    override func tearDown() {
        PersistenceService.shared = ContextPersister()
        context = nil
        container = nil
        super.tearDown()
    }

    func testExportExcludesExplicitSampleWhenRealRecordHasIdenticalTitle() throws {
        SampleData.insert(into: context)
        let demo = try XCTUnwrap(
            try context.fetch(FetchDescriptor<Decision>()).first(where: SampleData.isDemoDecision)
        )
        let real = Decision(title: demo.title, dueDate: Date().addingTimeInterval(86_400))
        context.insert(real)
        try context.save()

        let exported = ExportManager.makeExport(from: try context.fetch(FetchDescriptor<Decision>()))

        XCTAssertEqual(exported.decisions.count, 1)
        XCTAssertEqual(exported.decisions.first?.id, real.id)
        XCTAssertEqual(exported.decisions.first?.title, demo.title)
    }

    func testExportPreservesStableIDsAndDecisionDates() {
        let createdAt = Date(timeIntervalSince1970: 100)
        let decidedAt = Date(timeIntervalSince1970: 200)
        let dueDate = Date(timeIntervalSince1970: 300)
        let deadline = Date(timeIntervalSince1970: 400)
        let decision = Decision(
            title: "A complete record",
            createdAt: createdAt,
            decidedAt: decidedAt,
            dueDate: dueDate,
            deadline: deadline
        )
        let option = DecisionOption(title: "Option")
        let prediction = Prediction(title: "Prediction", dueDate: dueDate)
        let review = OutcomeReview(whatHappened: "Outcome")
        decision.options = [option]
        decision.predictions = [prediction]
        decision.outcomeReview = review

        let exported = ExportManager.makeExport(from: [decision])
        let record = exported.decisions[0]

        XCTAssertEqual(record.id, decision.id)
        XCTAssertEqual(record.createdAt, createdAt)
        XCTAssertEqual(record.decidedAt, decidedAt)
        XCTAssertEqual(record.dueDate, dueDate)
        XCTAssertEqual(record.deadline, deadline)
        XCTAssertEqual(record.options.first?.id, option.id)
        XCTAssertEqual(record.predictions.first?.id, prediction.id)
        XCTAssertEqual(record.outcomeReview?.id, review.id)
    }

    func testExportOmitsOptionalReviewAnswersThatWereNeverRecorded() throws {
        let decision = Decision(title: "Facts only")
        decision.outcomeReview = OutcomeReview(whatHappened: "It happened")

        let export = ExportManager.makeExport(from: [decision])
        let review = try XCTUnwrap(export.decisions.first?.outcomeReview)
        XCTAssertNil(review.outcomeQuality)
        XCTAssertNil(review.decisionQuality)
        XCTAssertNil(review.wouldDoAgain)

        let data = try JSONEncoder().encode(export)
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decisions = try XCTUnwrap(root["decisions"] as? [[String: Any]])
        let encodedReview = try XCTUnwrap(decisions.first?["outcomeReview"] as? [String: Any])
        XCTAssertNil(encodedReview["outcomeQuality"])
        XCTAssertNil(encodedReview["decisionQuality"])
        XCTAssertNil(encodedReview["wouldDoAgain"])
    }

    func testExportIncludesExplicitOptionalReviewAnswersEvenAtNeutralValues() throws {
        let decision = Decision(title: "Explicit answers")
        decision.outcomeReview = OutcomeReview(
            outcomeQuality: 3,
            decisionQuality: 3,
            wouldDoAgain: false
        )

        let review = try XCTUnwrap(ExportManager.makeExport(from: [decision]).decisions.first?.outcomeReview)
        XCTAssertEqual(review.outcomeQuality, 3)
        XCTAssertEqual(review.decisionQuality, 3)
        XCTAssertEqual(review.wouldDoAgain, false)
    }

    func testDeleteAllJournalDataClearsPersistedRecordsAndDurableDraft() throws {
        let suiteName = "DataLifecycleExportTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        QuickCaptureDraftStore.save(
            QuickCaptureDraftSnapshot(
                statement: "Private unfinished prediction",
                reasoning: "Because",
                confidence: 80,
                horizon: QuickCaptureHorizon.tomorrow.rawValue,
                customDate: Date().addingTimeInterval(86_400)
            ),
            defaults: defaults
        )
        let decision = Decision(title: "Persisted decision")
        context.insert(decision)
        try context.save()

        XCTAssertTrue(DataLifecycleManager.deleteAllJournalData([decision], in: context, defaults: defaults))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertNil(QuickCaptureDraftStore.load(defaults: defaults))
    }

    func testFailedJournalDeletionKeepsDurableDraftForRecovery() throws {
        let suiteName = "DataLifecycleExportTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let snapshot = QuickCaptureDraftSnapshot(
            statement: "Keep this if deleting fails",
            reasoning: "Because",
            confidence: 60,
            horizon: QuickCaptureHorizon.tomorrow.rawValue,
            customDate: Date().addingTimeInterval(86_400)
        )
        QuickCaptureDraftStore.save(snapshot, defaults: defaults)
        let decision = Decision(title: "Persisted decision")
        context.insert(decision)
        try context.save()
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }
        PersistenceService.shared = DataLifecycleFailingPersister()

        XCTAssertFalse(DataLifecycleManager.deleteAllJournalData([decision], in: context, defaults: defaults))
        XCTAssertEqual(QuickCaptureDraftStore.load(defaults: defaults), snapshot)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 1)
    }

    func testFailedJournalDeletionLeavesVisibleCascadeGraphUntouched() throws {
        let decision = Decision(title: "Persisted decision")
        let option = DecisionOption(title: "Keep this option")
        let prediction = Prediction(title: "Keep this prediction")
        decision.options = [option]
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }
        PersistenceService.shared = DataLifecycleFailingPersister()

        XCTAssertFalse(DataLifecycleManager.deleteAllJournalData([decision], in: context))
        XCTAssertEqual(decision.title, "Persisted decision")
        XCTAssertEqual(decision.options.map(\.title), ["Keep this option"])
        XCTAssertEqual(decision.predictions.map(\.title), ["Keep this prediction"])
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 1)
    }

    func testSingleDecisionDeletionReturnsPrecapturedReminderIdentifiersAndCascades() throws {
        let decision = Decision(title: "Delete this")
        let prediction = Prediction(title: "Delete this forecast")
        decision.options = [DecisionOption(title: "Option")]
        decision.predictions = [prediction]
        decision.outcomeReview = OutcomeReview(whatHappened: "Outcome")
        let expectedIdentifiers = [
            ReminderRequestIdentifier.decision(decision.id),
            ReminderRequestIdentifier.prediction(prediction.id)
        ]
        context.insert(decision)
        try context.save()

        let result = DataLifecycleManager.deleteDecision(decision, in: context)
        guard case .deleted(let receipt) = result else {
            return XCTFail("Expected staged deletion to succeed")
        }

        XCTAssertEqual(receipt.reminderIdentifiers, expectedIdentifiers)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<DecisionOption>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<OutcomeReview>()), 0)
    }

    func testSingleDecisionDeletionFailurePreservesGraphAndRetrySucceeds() throws {
        let decision = Decision(title: "Keep until confirmed")
        let option = DecisionOption(title: "Still attached")
        let prediction = Prediction(title: "Still attached")
        decision.options = [option]
        decision.predictions = [prediction]
        let expectedDecisionID = decision.id
        context.insert(decision)
        try context.save()

        PersistenceService.shared = DataLifecycleFailingPersister()
        XCTAssertEqual(DataLifecycleManager.deleteDecision(decision, in: context), .failed)
        XCTAssertEqual(decision.options.map(\.title), ["Still attached"])
        XCTAssertEqual(decision.predictions.map(\.title), ["Still attached"])
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 1)

        PersistenceService.shared = ContextPersister()
        guard case .deleted(let receipt) = DataLifecycleManager.deleteDecision(decision, in: context) else {
            return XCTFail("Expected retry to delete the intact graph")
        }
        XCTAssertEqual(receipt.decisionID, expectedDecisionID)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
    }

    func testFailedSampleRemovalReportsFailureAndRetainsSamples() throws {
        SampleData.insert(into: context)
        try context.save()
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }
        PersistenceService.shared = DataLifecycleFailingPersister()

        XCTAssertEqual(SampleData.remove(from: context), .failed)
        XCTAssertTrue(
            try context.fetch(FetchDescriptor<Decision>()).contains(where: SampleData.isDemoDecision)
        )
    }
}
