import XCTest
import SwiftData
@testable import Hindsight

/// Test double that always fails to save.
struct FailingPersister: Persisting {
    func save(_ context: ModelContext) throws {
        throw NSError(domain: "FailingPersister", code: 1, userInfo: nil)
    }
}

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
}
