//
//  OutcomeReview.swift
//  Hindsight
//
//  The retrospective a user writes once reality has delivered its verdict
//  on a decision.
//

import Foundation
import SwiftData

@Model
final class OutcomeReview {
    var id: UUID = UUID()

    /// What actually happened after the decision was made.
    var whatHappened: String = ""

    /// Was the result good? (1–5)
    var outcomeQuality: Int = 3
    /// Was the decision-making *process* good, regardless of luck? (1–5)
    var decisionQuality: Int = 3

    /// Would the user make the same decision again knowing what they know now?
    var wouldDoAgain: Bool = true

    /// What surprised the user about how things played out.
    var whatSurprised: String = ""
    /// The single biggest lesson learned.
    var mainLesson: String = ""

    var reviewedAt: Date = Date()

    /// Inverse relationship back to the owning decision.
    var decision: Decision?

    init(
        whatHappened: String = "",
        outcomeQuality: Int = 3,
        decisionQuality: Int = 3,
        wouldDoAgain: Bool = true,
        whatSurprised: String = "",
        mainLesson: String = "",
        reviewedAt: Date = Date()
    ) {
        self.id = UUID()
        self.whatHappened = whatHappened
        self.outcomeQuality = outcomeQuality
        self.decisionQuality = decisionQuality
        self.wouldDoAgain = wouldDoAgain
        self.whatSurprised = whatSurprised
        self.mainLesson = mainLesson
        self.reviewedAt = reviewedAt
    }
}
