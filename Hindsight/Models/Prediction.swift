//
//  Prediction.swift
//  Hindsight
//
//  A falsifiable statement the user made about the future at the time of
//  the decision, scored later against what actually happened.
//

import Foundation
import SwiftData

@Model
final class Prediction {
    var id: UUID = UUID()

    /// The prediction statement, e.g. "I'll still feel good about this in 30 days".
    var title: String = ""

    /// Stated probability that the prediction comes true (0–100).
    var probabilityPercent: Int = 50

    /// When this prediction should be evaluated.
    var dueDate: Date = Date()

    var status: PredictionStatus = PredictionStatus.pending

    /// What actually happened, filled in during the outcome review.
    var actualResult: String?

    /// Inverse relationship back to the owning decision.
    var decision: Decision?

    init(
        title: String = "",
        probabilityPercent: Int = 50,
        dueDate: Date = Date(),
        status: PredictionStatus = .pending,
        actualResult: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.probabilityPercent = probabilityPercent
        self.dueDate = dueDate
        self.status = status
        self.actualResult = actualResult
    }
}
