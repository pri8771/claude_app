import XCTest
import SwiftData
@testable import Hindsight

/// Test double that always fails to save.
struct FailingPersister: Persisting {
    func save(_ context: ModelContext) throws {
        throw NSError(domain: "FailingPersister", code: 1, userInfo: nil)
    }
}

@MainActor
final class PersistenceBoundaryTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Decision.self, Prediction.self, DecisionOption.self, OutcomeReview.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDown() async throws {
        PersistenceService.shared = ContextPersister()
        container = nil
        context = nil
    }

    /// Test that saveOrReport returns false when the persister throws.
    func testFailedSaveReturnsFalse() {
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }

        PersistenceService.shared = FailingPersister()

        let result = PersistenceService.saveOrReport(context)
        XCTAssertFalse(result, "saveOrReport should return false on save failure")
    }

    /// Test that failed save does not proceed with success side effects.
    /// Simulates the wizard save flow: insert Decision, attempt save with failing double,
    /// verify that saveOrReport returns false and caller code path would skip scheduling reminder.
    func testFailedSaveDoesNotMutateStoreEffects() {
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }

        PersistenceService.shared = FailingPersister()

        // Simulate wizard flow: create and insert a decision
        let decision = Decision(
            title: "Test Decision",
            notes: "",
            category: .career,
            stakesLevel: .medium,
            status: .active,
            isReversible: true,
            clarityScore: 50,
            createdAt: Date(),
            dueDate: Date().addingTimeInterval(86400 * 30)
        )
        context.insert(decision)

        // Attempt to save; should fail
        let saveSucceeded = PersistenceService.saveOrReport(context)
        XCTAssertFalse(saveSucceeded, "Save should fail with FailingPersister")

        // Verify that code path would skip side effects:
        // The contract is that callers check the return value before proceeding.
        // This test verifies the helper behaves correctly; the UI layer tests
        // verify that side effects (haptics, reminders, dismiss) are skipped.
    }

    func testFailedNewDecisionGraphIsRemovedBeforeSuccessfulRetry() throws {
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }

        func makeGraph(title: String) -> Decision {
            let decision = Decision(title: title)
            decision.options = [DecisionOption(title: "Option")]
            decision.predictions = [Prediction(title: "Forecast", probabilityPercent: 70)]
            return decision
        }

        PersistenceService.shared = FailingPersister()
        XCTAssertFalse(NewDecisionGraphPersistenceService.save(makeGraph(title: "Abandoned attempt"), in: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<DecisionOption>()), 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 0)

        PersistenceService.shared = ContextPersister()
        XCTAssertTrue(NewDecisionGraphPersistenceService.save(makeGraph(title: "Successful retry"), in: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<DecisionOption>()), 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Prediction>()), 1)
    }

    func testJSONExportWritesStablePersonalGraphAndExcludesSamples() throws {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        let personal = Decision(
            title: "Personal forecast",
            notes: "Original Why",
            createdAt: createdAt,
            dueDate: dueDate
        )
        let prediction = Prediction(
            title: "Personal forecast",
            probabilityPercent: 0,
            dueDate: dueDate,
            status: .incorrect
        )
        personal.predictions = [prediction]
        personal.outcomeReview = OutcomeReview(whatHappened: "It did not happen", reviewedAt: dueDate)

        let sample = Decision(title: "Sample forecast")
        sample.id = UUID(uuidString: "A1F00100-0000-4000-8000-000000000001")!
        sample.predictions = [Prediction(title: "Sample forecast", probabilityPercent: 100, status: .correct)]

        let url = try ExportManager.exportJSON([personal, sample])
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let exported = try decoder.decode(JournalExport.self, from: Data(contentsOf: url))
        XCTAssertEqual(exported.decisions.count, 1)
        let record = try XCTUnwrap(exported.decisions.first)
        XCTAssertEqual(record.id, personal.id)
        XCTAssertEqual(record.title, "Personal forecast")
        XCTAssertEqual(record.createdAt, createdAt)
        XCTAssertEqual(record.dueDate, dueDate)
        XCTAssertEqual(record.predictions.first?.id, prediction.id)
        XCTAssertEqual(record.predictions.first?.probabilityPercent, 0)
        XCTAssertEqual(record.outcomeReview?.whatHappened, "It did not happen")
    }

    func testDeletionFailureRetainsDraftUntilSuccessfulRetryThenClearsEverything() throws {
        let suiteName = "PersistenceBoundaryTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            PersistenceService.shared = ContextPersister()
        }
        let snapshot = QuickCaptureDraftSnapshot(
            statement: "Keep this until deletion succeeds",
            reasoning: "Because",
            confidence: 60,
            horizon: QuickCaptureHorizon.tomorrow.rawValue,
            customDate: Date(timeIntervalSince1970: 1_800_000_000)
        )
        QuickCaptureDraftStore.save(snapshot, defaults: defaults)

        let first = Decision(title: "First personal record")
        let second = Decision(title: "Second personal record")
        context.insert(first)
        context.insert(second)
        try context.save()

        PersistenceService.shared = FailingPersister()
        XCTAssertFalse(DataLifecycleManager.deleteAllJournalData([first, second], in: context, defaults: defaults))
        XCTAssertEqual(QuickCaptureDraftStore.load(defaults: defaults), snapshot)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 2)

        PersistenceService.shared = ContextPersister()
        XCTAssertTrue(DataLifecycleManager.deleteAllJournalData([first, second], in: context, defaults: defaults))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertNil(QuickCaptureDraftStore.load(defaults: defaults))
    }
}
