//
//  ClarityScore.swift
//  Hindsight
//
//  Computes a 0–100 "clarity score" for a decision based on how
//  thoroughly the user thought it through. Used as gentle encouragement
//  to capture richer decisions.
//

import Foundation

enum ClarityScore {

    /// Scores a draft. Each dimension contributes to a 0–100 total.
    static func score(
        title: String,
        notes: String,
        optionCount: Int,
        optionsWithTradeoffs: Int,
        predictionCount: Int,
        hasReviewDate: Bool
    ) -> Int {
        var total = 0.0

        // A clear title (20)
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { total += 20 }

        // Context / notes captured (15)
        if notes.trimmingCharacters(in: .whitespacesAndNewlines).count >= 12 { total += 15 }

        // Considering real alternatives (25): 2 options = partial, 3+ = full
        switch optionCount {
        case 0:    total += 0
        case 1:    total += 8
        case 2:    total += 18
        default:   total += 25
        }

        // Articulated trade-offs for the options (20)
        if optionCount > 0 {
            let ratio = Double(optionsWithTradeoffs) / Double(optionCount)
            total += ratio * 20
        }

        // Falsifiable predictions (15)
        switch predictionCount {
        case 0:    total += 0
        case 1:    total += 8
        case 2:    total += 12
        default:   total += 15
        }

        // Committed to a review date (5)
        if hasReviewDate { total += 5 }

        return Int(total.rounded())
    }

    /// Convenience scorer for an existing model object.
    static func score(for decision: Decision) -> Int {
        let withTradeoffs = decision.options.filter {
            !$0.upside.trimmingCharacters(in: .whitespaces).isEmpty &&
            !$0.downside.trimmingCharacters(in: .whitespaces).isEmpty
        }.count
        return score(
            title: decision.title,
            notes: decision.notes,
            optionCount: decision.options.count,
            optionsWithTradeoffs: withTradeoffs,
            predictionCount: decision.predictions.count,
            hasReviewDate: true
        )
    }

    static func label(for score: Int) -> String {
        switch score {
        case 0...39:   return "Sketchy"
        case 40...69:  return "Decent"
        case 70...89:  return "Thorough"
        default:       return "Crystal clear"
        }
    }
}
