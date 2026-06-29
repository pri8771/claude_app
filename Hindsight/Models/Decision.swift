//
//  Decision.swift
//  Hindsight
//
//  The core SwiftData model: a single decision the user captured, along
//  with the options they weighed, the predictions they made, and the
//  eventual outcome review.
//

import Foundation
import SwiftData

@Model
final class Decision {
    /// Stable identifier (also used for notification request IDs).
    var id: UUID = UUID()

    var title: String = ""
    /// Free-form context / notes about the decision.
    var notes: String = ""

    var category: DecisionCategory = DecisionCategory.personal
    var stakesLevel: StakesLevel = StakesLevel.medium
    var status: DecisionStatus = DecisionStatus.active

    /// Whether the decision can be walked back later.
    var isReversible: Bool = true

    /// 0–100 completeness score calculated when the decision is saved.
    var clarityScore: Int = 0

    /// The option the user ultimately committed to (if any). The ID is the
    /// source of truth; the title is kept in sync for export readability and
    /// as a fallback for older records created before IDs were tracked.
    var chosenOptionID: UUID?
    var chosenOptionTitle: String?

    var createdAt: Date = Date()
    /// When the user marked the decision as "decided".
    var decidedAt: Date?
    /// When the user wants to be reminded to review the outcome.
    var dueDate: Date = Date()
    /// Optional hard deadline for actually making the choice.
    var deadline: Date?

    @Relationship(deleteRule: .cascade, inverse: \DecisionOption.decision)
    var options: [DecisionOption] = []

    @Relationship(deleteRule: .cascade, inverse: \Prediction.decision)
    var predictions: [Prediction] = []

    @Relationship(deleteRule: .cascade, inverse: \OutcomeReview.decision)
    var outcomeReview: OutcomeReview?

    init(
        title: String = "",
        notes: String = "",
        category: DecisionCategory = .personal,
        stakesLevel: StakesLevel = .medium,
        status: DecisionStatus = .active,
        isReversible: Bool = true,
        clarityScore: Int = 0,
        chosenOptionID: UUID? = nil,
        chosenOptionTitle: String? = nil,
        createdAt: Date = Date(),
        decidedAt: Date? = nil,
        dueDate: Date = Date(),
        deadline: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.category = category
        self.stakesLevel = stakesLevel
        self.status = status
        self.isReversible = isReversible
        self.clarityScore = clarityScore
        self.chosenOptionID = chosenOptionID
        self.chosenOptionTitle = chosenOptionTitle
        self.createdAt = createdAt
        self.decidedAt = decidedAt
        self.dueDate = dueDate
        self.deadline = deadline
        self.options = []
        self.predictions = []
        self.outcomeReview = nil
    }
}

// MARK: - Derived state

extension Decision {

    /// True once the review date has reached/passed and no outcome has been
    /// logged. This is the single source of truth for "reality has arrived".
    var isPastDue: Bool {
        status != .reviewed && dueDate <= Date()
    }

    /// Surfaced in the "Needs Review" section on the home screen. Identical
    /// to `isPastDue` — kept as a named alias for readability at call sites.
    var needsReview: Bool { isPastDue }

    /// The option flagged as chosen, resolved by stable ID first and falling
    /// back to a title match for records created before IDs were tracked.
    var chosenOption: DecisionOption? {
        if let chosenOptionID, let match = options.first(where: { $0.id == chosenOptionID }) {
            return match
        }
        guard let chosenOptionTitle else { return nil }
        return options.first { $0.title == chosenOptionTitle }
    }

    /// Whether the given option is the one the user committed to.
    func isChosen(_ option: DecisionOption) -> Bool {
        if let chosenOptionID { return option.id == chosenOptionID }
        return chosenOptionTitle != nil && option.title == chosenOptionTitle
    }

    /// The chosen option's title for display, regardless of how it was stored.
    var chosenOptionDisplayTitle: String? {
        chosenOption?.title ?? chosenOptionTitle
    }

    /// Sorted predictions (pending first, then by due date).
    var sortedPredictions: [Prediction] {
        predictions.sorted { lhs, rhs in
            if lhs.status == .pending && rhs.status != .pending { return true }
            if lhs.status != .pending && rhs.status == .pending { return false }
            return lhs.dueDate < rhs.dueDate
        }
    }

    /// Average stated confidence across all predictions (0–100), rounded.
    var averageConfidence: Int {
        guard !predictions.isEmpty else { return 0 }
        let total = predictions.reduce(0) { $0 + $1.probabilityPercent }
        return Int((Double(total) / Double(predictions.count)).rounded())
    }

    /// Whether the most recent outcome was a "win" (good result, would repeat).
    var wasGoodOutcome: Bool {
        guard let review = outcomeReview else { return false }
        return review.outcomeQuality >= 4 && review.wouldDoAgain
    }

    /// Number of days until (negative if past) the review date.
    var daysUntilReview: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()),
                                        to: Calendar.current.startOfDay(for: dueDate)).day ?? 0
    }
}
