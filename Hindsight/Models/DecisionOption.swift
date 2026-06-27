//
//  DecisionOption.swift
//  Hindsight
//
//  One of the choices a user weighed for a decision, with the trade-offs
//  they recorded at the time.
//

import Foundation
import SwiftData

@Model
final class DecisionOption {
    var id: UUID = UUID()

    var title: String = ""
    /// What's good about choosing this option.
    var upside: String = ""
    /// What's bad about choosing this option.
    var downside: String = ""

    /// How much effort this option takes (1–5).
    var effortLevel: Int = 3
    /// How risky this option feels (1–5).
    var riskLevel: Int = 3
    /// Gut feeling about this option (1 = bad, 5 = great).
    var gutFeeling: Int = 3

    /// Inverse relationship back to the owning decision.
    var decision: Decision?

    init(
        title: String = "",
        upside: String = "",
        downside: String = "",
        effortLevel: Int = 3,
        riskLevel: Int = 3,
        gutFeeling: Int = 3
    ) {
        self.id = UUID()
        self.title = title
        self.upside = upside
        self.downside = downside
        self.effortLevel = effortLevel
        self.riskLevel = riskLevel
        self.gutFeeling = gutFeeling
    }
}
