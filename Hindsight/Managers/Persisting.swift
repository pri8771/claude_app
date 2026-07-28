import SwiftData

/// Protocol defining how to persist changes to the model context.
/// Allows injection of test doubles that can simulate save failures.
protocol Persisting {
    func save(_ context: ModelContext) throws
}

/// Production persister that calls SwiftData's context.save().
struct ContextPersister: Persisting {
    func save(_ context: ModelContext) throws {
        try context.save()
    }
}

/// Service providing centralized persistence with test injection support.
enum PersistenceService {
    static var shared: Persisting = ContextPersister()

    /// Attempts to save the context, returning true on success.
    /// On failure, returns false (caller should surface alert and NOT proceed with side effects).
    @discardableResult
    static func saveOrReport(_ context: ModelContext) -> Bool {
        do {
            try shared.save(context)
            return true
        } catch {
            // Failure logged implicitly by SwiftData; caller surfaces the alert.
            return false
        }
    }
}
