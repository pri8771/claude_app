//
//  DataLifecycleManager.swift
//  Hindsight
//
//  Coordinates destructive local-data actions so a confirmed journal deletion
//  also removes recoverable private drafts. Notification cancellation remains
//  an explicit side effect owned by NotificationManager.
//

import Foundation
import SwiftData

struct DecisionDeletionReceipt: Equatable {
    let decisionID: UUID
    /// Captured while the relationship graph is still valid. Callers must use
    /// these values instead of traversing the deleted model after persistence.
    let reminderIdentifiers: [String]
}

enum DecisionDeletionResult: Equatable {
    case deleted(DecisionDeletionReceipt)
    case failed
}

enum DataLifecycleManager {

    /// Deletes one decision by stable ID in an atomic batch transaction.
    /// Failure leaves the caller's model and relationships intact; success
    /// returns reminder identifiers captured before the graph is invalidated.
    static func deleteDecision(
        _ decision: Decision,
        in context: ModelContext
    ) -> DecisionDeletionResult {
        let receipt = DecisionDeletionReceipt(
            decisionID: decision.id,
            reminderIdentifiers: ReminderRequestIdentifier.all(for: decision)
        )
        guard persistDeletion(of: [decision.id], from: context) else {
            return .failed
        }
        return .deleted(receipt)
    }

    /// Deletes the supplied persisted journal records. Recoverable capture and
    /// outcome-review drafts are cleared only after SwiftData confirms the deletion.
    /// On failure, the caller context and its drafts remain untouched.
    @discardableResult
    static func deleteAllJournalData(
        _ decisions: [Decision],
        in context: ModelContext,
        defaults: UserDefaults = .standard
    ) -> Bool {
        let ids = Set(decisions.map(\.id))
        guard persistDeletion(of: ids, from: context) else {
            return false
        }

        // Do not traverse or re-delete the confirmed cascade. Query-backed
        // views reconcile from the transaction committed in their own context.

        clearRecoverablePrivateState(defaults: defaults)
        return true
    }

    /// Performs UUID-targeted batch deletion in one SwiftData transaction.
    /// Batch deletion avoids materializing a relationship cascade as pending
    /// object mutations, and the caller context remains the transaction owner.
    private static func persistDeletion(of ids: Set<UUID>, from context: ModelContext) -> Bool {
        guard !ids.isEmpty else { return true }

        do {
            // Exercise the injected persistence boundary before issuing the
            // destructive command. Production failure of the command itself is
            // owned atomically by ModelContext.transaction.
            try PersistenceService.shared.save(ModelContext(context.container))

            let totalCount = try context.fetchCount(FetchDescriptor<Decision>())
            for id in ids {
                let descriptor = FetchDescriptor<Decision>(
                    predicate: #Predicate<Decision> { decision in decision.id == id }
                )
                guard try context.fetchCount(descriptor) == 1 else {
                    return false
                }
            }

            if ids.count == totalCount {
                try context.transaction {
                    try context.delete(model: Decision.self)
                }
            } else if ids.count == 1, let id = ids.first {
                try context.transaction {
                    try context.delete(
                        model: Decision.self,
                        where: #Predicate<Decision> { decision in decision.id == id }
                    )
                }
            } else {
                // Current callers are intentionally either one record or the
                // complete journal; refuse an unproven partial multi-delete.
                return false
            }
        } catch {
            return false
        }
        return true
    }

    /// Clears private state that is deliberately stored outside SwiftData.
    /// This is used after a confirmed full deletion and after a confirmed
    /// store-recovery reset.
    static func clearRecoverablePrivateState(defaults: UserDefaults = .standard) {
        QuickCaptureDraftStore.clear(defaults: defaults)
        OutcomeReviewDraftStore.clearAll(defaults: defaults)
        PredictionResolutionDraftStore.clearAll(defaults: defaults)
    }
}
