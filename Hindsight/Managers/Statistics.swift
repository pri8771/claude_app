//
//  Statistics.swift
//  Hindsight
//
//  Pure functions that turn a list of decisions into the numbers and
//  patterns shown on the Insights screen. Kept separate from views so the
//  analytics are easy to reason about and test.
//

import Foundation

struct CategoryCount: Identifiable {
    let id = UUID()
    let category: DecisionCategory
    let count: Int
}

struct QualityPoint: Identifiable {
    let id = UUID()
    let date: Date
    let decisionQuality: Double
    let outcomeQuality: Double
}

struct Pattern: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

struct StatusCount: Identifiable {
    var id: String { status.rawValue }
    let status: PredictionStatus
    let count: Int
}

enum Statistics {

    // MARK: Headline numbers

    static func totalDecisions(_ decisions: [Decision]) -> Int { decisions.count }

    static func reviewedDecisions(_ decisions: [Decision]) -> [Decision] {
        decisions.filter { $0.status == .reviewed && $0.outcomeReview != nil }
    }

    /// Percentage of decisions that have reached an outcome review (0–100).
    static func reviewRate(_ decisions: [Decision]) -> Int {
        guard !decisions.isEmpty else { return 0 }
        let reviewed = reviewedDecisions(decisions).count
        return Int((Double(reviewed) / Double(decisions.count) * 100).rounded())
    }

    static func averageDecisionQuality(_ decisions: [Decision]) -> Double {
        let reviews = reviewedDecisions(decisions).compactMap { $0.outcomeReview }
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.decisionQuality }) / Double(reviews.count)
    }

    static func averageOutcomeQuality(_ decisions: [Decision]) -> Double {
        let reviews = reviewedDecisions(decisions).compactMap { $0.outcomeReview }
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.outcomeQuality }) / Double(reviews.count)
    }

    /// Average stated confidence across every prediction (0–100), rounded.
    static func averageConfidence(_ decisions: [Decision]) -> Int {
        let predictions = decisions.flatMap { $0.predictions }
        guard !predictions.isEmpty else { return 0 }
        let total = predictions.reduce(0) { $0 + $1.probabilityPercent }
        return Int((Double(total) / Double(predictions.count)).rounded())
    }

    // MARK: Prediction accuracy

    /// Fraction (0–1) of resolved predictions that came true, partial = 0.5.
    static func predictionAccuracy(_ decisions: [Decision]) -> Double {
        let resolved = decisions.flatMap { $0.predictions }.filter { $0.status != .pending }
        guard !resolved.isEmpty else { return 0 }
        let total = resolved.reduce(0.0) { $0 + $1.status.score }
        return total / Double(resolved.count)
    }

    static func predictionStatusCounts(_ decisions: [Decision]) -> [StatusCount] {
        let predictions = decisions.flatMap { $0.predictions }
        return PredictionStatus.allCases.map { status in
            StatusCount(status: status, count: predictions.filter { $0.status == status }.count)
        }
    }

    // MARK: Charts

    static func decisionsByCategory(_ decisions: [Decision]) -> [CategoryCount] {
        DecisionCategory.allCases.compactMap { category in
            let count = decisions.filter { $0.category == category }.count
            return count > 0 ? CategoryCount(category: category, count: count) : nil
        }
    }

    /// Outcome / decision quality over time (one point per reviewed decision).
    static func qualityOverTime(_ decisions: [Decision]) -> [QualityPoint] {
        reviewedDecisions(decisions)
            .compactMap { decision -> QualityPoint? in
                guard let review = decision.outcomeReview else { return nil }
                return QualityPoint(
                    date: review.reviewedAt,
                    decisionQuality: Double(review.decisionQuality),
                    outcomeQuality: Double(review.outcomeQuality)
                )
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: Patterns (lightweight heuristics over the user's own history)

    static func patterns(_ decisions: [Decision]) -> [Pattern] {
        var patterns: [Pattern] = []
        let reviewed = reviewedDecisions(decisions)

        guard reviewed.count >= 2 else {
            return [Pattern(
                icon: "sparkles",
                title: "Patterns unlock as you review",
                detail: "Review a few decisions and Hindsight will surface trends from your own track record."
            )]
        }

        // Stakes vs decision quality. "High" = at or above the High level.
        let highStakesThreshold = StakesLevel.high.weight
        let highStakes = reviewed.filter { $0.stakesLevel.weight >= highStakesThreshold }
        let lowStakes  = reviewed.filter { $0.stakesLevel.weight < highStakesThreshold }
        if !highStakes.isEmpty && !lowStakes.isEmpty {
            let highAvg = avgDecisionQuality(highStakes)
            let lowAvg  = avgDecisionQuality(lowStakes)
            if highAvg - lowAvg >= 0.4 {
                patterns.append(Pattern(
                    icon: "bolt.fill",
                    title: "You rise to high stakes",
                    detail: "Your decision-making scores \(formatted(highAvg)) on high-stakes calls vs \(formatted(lowAvg)) on smaller ones."
                ))
            } else if lowAvg - highAvg >= 0.4 {
                patterns.append(Pattern(
                    icon: "exclamationmark.triangle.fill",
                    title: "High stakes trip you up",
                    detail: "You score \(formatted(lowAvg)) on low-stakes decisions but only \(formatted(highAvg)) when it really counts."
                ))
            }
        }

        // Lowest review-rate category.
        let counts = DecisionCategory.allCases.map { category -> (DecisionCategory, Int, Int) in
            let all = decisions.filter { $0.category == category }
            let done = all.filter { $0.status == .reviewed }
            return (category, all.count, done.count)
        }.filter { $0.1 >= 2 }
        if let worst = counts.min(by: { reviewRatio($0) < reviewRatio($1) }), reviewRatio(worst) < 0.5 {
            patterns.append(Pattern(
                icon: worst.0.icon,
                title: "\(worst.0.rawValue) decisions go unreviewed",
                detail: "Only \(Int(reviewRatio(worst) * 100))% of your \(worst.0.rawValue.lowercased()) decisions get a look back. Close the loop to learn faster."
            ))
        }

        // Confidence calibration.
        let resolved = decisions.flatMap { $0.predictions }.filter { $0.status != .pending }
        if resolved.count >= 3 {
            let avgStated = Double(resolved.reduce(0) { $0 + $1.probabilityPercent }) / Double(resolved.count) / 100
            let actual = predictionAccuracy(decisions)
            let gap = avgStated - actual
            if gap >= 0.15 {
                patterns.append(Pattern(
                    icon: "gauge.with.dots.needle.33percent",
                    title: "You tend to be overconfident",
                    detail: "You predicted \(Int(avgStated * 100))% on average but were right \(Int(actual * 100))% of the time."
                ))
            } else if gap <= -0.15 {
                patterns.append(Pattern(
                    icon: "gauge.with.dots.needle.67percent",
                    title: "You sell yourself short",
                    detail: "You were right \(Int(actual * 100))% of the time but only predicted \(Int(avgStated * 100))% confidence."
                ))
            } else {
                patterns.append(Pattern(
                    icon: "checkmark.seal.fill",
                    title: "Your gut is well-calibrated",
                    detail: "Your stated confidence (\(Int(avgStated * 100))%) closely tracks reality (\(Int(actual * 100))%). Trust it."
                ))
            }
        }

        // Reversible vs irreversible regret.
        let irreversible = reviewed.filter { !$0.isReversible }
        if irreversible.count >= 2 {
            let regret = irreversible.filter { !($0.outcomeReview?.wouldDoAgain ?? true) }.count
            if regret == 0 {
                patterns.append(Pattern(
                    icon: "lock.fill",
                    title: "No regrets on the big ones",
                    detail: "You'd make every one of your irreversible decisions again. Strong conviction."
                ))
            }
        }

        if patterns.isEmpty {
            patterns.append(Pattern(
                icon: "chart.line.uptrend.xyaxis",
                title: "Keep reviewing",
                detail: "Your history is taking shape. More reviews mean sharper patterns."
            ))
        }
        return patterns
    }

    // MARK: Helpers

    private static func avgDecisionQuality(_ decisions: [Decision]) -> Double {
        let reviews = decisions.compactMap { $0.outcomeReview }
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.decisionQuality }) / Double(reviews.count)
    }

    private static func reviewRatio(_ tuple: (DecisionCategory, Int, Int)) -> Double {
        tuple.1 == 0 ? 0 : Double(tuple.2) / Double(tuple.1)
    }

    private static func formatted(_ value: Double) -> String {
        String(format: "%.1f/5", value)
    }
}
