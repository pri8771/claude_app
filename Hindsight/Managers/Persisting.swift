import Foundation
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

/// Inserts a brand-new decision graph exactly once per save attempt. A failed
/// write removes the transient graph from the context so a retry cannot later
/// persist both the abandoned attempt and the replacement.
enum NewDecisionGraphPersistenceService {
    @discardableResult
    static func save(_ decision: Decision, in context: ModelContext) -> Bool {
        context.insert(decision)
        guard PersistenceService.saveOrReport(context) else {
            context.delete(decision)
            return false
        }
        return true
    }
}

/// The outcome-review save boundary keeps a failed write retryable without
/// asking SwiftData to roll back a relationship graph with cascade rules.
enum OutcomeReviewPersistenceService {
    struct Input {
        let whatHappened: String
        let outcomeQuality: Int?
        let decisionQuality: Int?
        let wouldDoAgain: Bool?
        let whatSurprised: String
        let mainLesson: String
        let predictionVerdicts: [UUID: PredictionStatus]
        let predictionResults: [UUID: String]
        let createsReview: Bool
    }

    private struct ReviewSnapshot {
        let whatHappened: String
        let outcomeQuality: Int
        let hasOutcomeQuality: Bool
        let decisionQuality: Int
        let hasDecisionQuality: Bool
        let wouldDoAgain: Bool
        let hasWouldDoAgain: Bool
        let whatSurprised: String
        let mainLesson: String

        init(_ review: OutcomeReview) {
            whatHappened = review.whatHappened
            outcomeQuality = review.outcomeQuality
            hasOutcomeQuality = review.hasOutcomeQuality
            decisionQuality = review.decisionQuality
            hasDecisionQuality = review.hasDecisionQuality
            wouldDoAgain = review.wouldDoAgain
            hasWouldDoAgain = review.hasWouldDoAgain
            whatSurprised = review.whatSurprised
            mainLesson = review.mainLesson
        }

        func restore(_ review: OutcomeReview) {
            review.whatHappened = whatHappened
            review.outcomeQuality = outcomeQuality
            review.hasOutcomeQuality = hasOutcomeQuality
            review.decisionQuality = decisionQuality
            review.hasDecisionQuality = hasDecisionQuality
            review.wouldDoAgain = wouldDoAgain
            review.hasWouldDoAgain = hasWouldDoAgain
            review.whatSurprised = whatSurprised
            review.mainLesson = mainLesson
        }
    }

    /// Applies a resolution as one save attempt. If persistence rejects it,
    /// every in-memory value is restored explicitly. This is deliberately not
    /// `ModelContext.rollback()`: rolling back a newly attached cascade graph
    /// can itself fault/crash before the durable UI draft can be retried.
    @discardableResult
    static func save(_ input: Input, for decision: Decision, in context: ModelContext) -> Bool {
        let previousDecisionStatus = decision.status
        let previousPredictions = decision.predictions.map {
            ($0, $0.status, $0.actualResult)
        }
        let existingReview = decision.outcomeReview
        let previousReview = existingReview.map(ReviewSnapshot.init)

        let review = existingReview ?? (input.createsReview ? OutcomeReview() : nil)
        if let review {
            review.whatHappened = input.whatHappened
            review.hasOutcomeQuality = input.outcomeQuality != nil
            if let outcomeQuality = input.outcomeQuality { review.outcomeQuality = outcomeQuality }
            review.hasDecisionQuality = input.decisionQuality != nil
            if let decisionQuality = input.decisionQuality { review.decisionQuality = decisionQuality }
            review.hasWouldDoAgain = input.wouldDoAgain != nil
            if let wouldDoAgain = input.wouldDoAgain { review.wouldDoAgain = wouldDoAgain }
            review.whatSurprised = input.whatSurprised
            review.mainLesson = input.mainLesson

            if existingReview == nil {
                context.insert(review)
                // Set one side only; SwiftData maintains the inverse.
                decision.outcomeReview = review
            }
        }

        for prediction in decision.predictions {
            if let verdict = input.predictionVerdicts[prediction.id] {
                prediction.status = verdict
            }
            let result = input.predictionResults[prediction.id]?.trimmingCharacters(in: .whitespacesAndNewlines)
            prediction.actualResult = result?.isEmpty == false ? result : nil
        }
        // A terminal forecast is evidence, but it is not itself a full outcome
        // review. Keep the lifecycle truthful: `reviewed` always has a review.
        decision.status = review == nil ? .awaitingReview : .reviewed

        guard PersistenceService.saveOrReport(context) else {
            decision.status = previousDecisionStatus
            for (prediction, status, actualResult) in previousPredictions {
                prediction.status = status
                prediction.actualResult = actualResult
            }
            if let existingReview, let previousReview {
                previousReview.restore(existingReview)
            } else if let review {
                // Detach before deleting the transient review, so this never
                // asks the context to traverse the decision's cascade graph.
                decision.outcomeReview = nil
                context.delete(review)
            }
            return false
        }
        return true
    }
}
