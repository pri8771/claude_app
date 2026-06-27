//
//  DecisionDraft.swift
//  Hindsight
//
//  Mutable, observable scratch state shared across the steps of the new
//  decision wizard. Only persisted to SwiftData when the user saves.
//

import SwiftUI
import Observation

@Observable
final class OptionDraft: Identifiable {
    let id = UUID()
    var title: String = ""
    var upside: String = ""
    var downside: String = ""
    var effort: Int = 3
    var risk: Int = 3
    var gutFeeling: Int = 3

    var hasTradeoffs: Bool {
        !upside.trimmingCharacters(in: .whitespaces).isEmpty &&
        !downside.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

@Observable
final class PredictionDraft: Identifiable {
    let id = UUID()
    var statement: String = ""
    var probability: Int = 50
    var dueDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
}

@Observable
final class DecisionDraft {
    var title: String = ""
    var notes: String = ""
    var category: DecisionCategory = .personal
    var stakes: StakesLevel = .medium
    var isReversible: Bool = true

    var options: [OptionDraft] = [OptionDraft(), OptionDraft()]
    var predictions: [PredictionDraft] = [PredictionDraft()]

    var reviewDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    // MARK: Validation per step

    var step1Valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var validOptions: [OptionDraft] {
        options.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var step2Valid: Bool { validOptions.count >= 2 }

    var validPredictions: [PredictionDraft] {
        predictions.filter { !$0.statement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var step3Valid: Bool { !validPredictions.isEmpty }

    // MARK: Clarity score

    var clarityScore: Int {
        ClarityScore.score(
            title: title,
            notes: notes,
            optionCount: validOptions.count,
            optionsWithTradeoffs: validOptions.filter { $0.hasTradeoffs }.count,
            predictionCount: validPredictions.count,
            hasReviewDate: true
        )
    }

    // MARK: Build the persistent model

    /// Constructs a `Decision` (with its options and predictions) ready to
    /// insert into a model context.
    func makeDecision() -> Decision {
        let decision = Decision(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            stakesLevel: stakes,
            status: .awaitingReview,
            isReversible: isReversible,
            clarityScore: clarityScore,
            createdAt: Date(),
            decidedAt: Date(),
            dueDate: reviewDate
        )

        decision.options = validOptions.map {
            DecisionOption(
                title: $0.title.trimmingCharacters(in: .whitespacesAndNewlines),
                upside: $0.upside.trimmingCharacters(in: .whitespacesAndNewlines),
                downside: $0.downside.trimmingCharacters(in: .whitespacesAndNewlines),
                effortLevel: $0.effort,
                riskLevel: $0.risk,
                gutFeeling: $0.gutFeeling
            )
        }

        decision.predictions = validPredictions.map {
            Prediction(
                title: $0.statement.trimmingCharacters(in: .whitespacesAndNewlines),
                probabilityPercent: $0.probability,
                dueDate: $0.dueDate,
                status: .pending
            )
        }

        return decision
    }
}
