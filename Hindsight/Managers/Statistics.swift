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

struct CalibrationInsight: Equatable {
    enum Assessment: Equatable {
        case keepResolving
        case overconfident
        case underconfident
        case wellCalibrated
    }

    static let minimumSampleSize = 3

    let resolvedCount: Int
    let averageStatedConfidence: Double
    let hitRate: Double
    let gap: Double
    let assessment: Assessment
}

// MARK: - Strict forecast analytics

/// A fixed, intentionally coarse confidence vocabulary.  The order is part of
/// the analytics contract: charts and accessibility descriptions must never
/// shuffle a band according to which records happen to exist.
enum ConfidenceBand: String, CaseIterable, Identifiable {
    case zeroToFortyNine = "0–49%"
    case fiftyToFiftyNine = "50–59%"
    case sixtyToSixtyNine = "60–69%"
    case seventyToSeventyNine = "70–79%"
    case eightyToEightyNine = "80–89%"
    case ninetyToNinetyNine = "90–99%"
    case oneHundred = "100%"

    var id: String { rawValue }

    var range: ClosedRange<Int> {
        switch self {
        case .zeroToFortyNine: return 0...49
        case .fiftyToFiftyNine: return 50...59
        case .sixtyToSixtyNine: return 60...69
        case .seventyToSeventyNine: return 70...79
        case .eightyToEightyNine: return 80...89
        case .ninetyToNinetyNine: return 90...99
        case .oneHundred: return 100...100
        }
    }
}

enum ForecastSampleState: Equatable {
    case noEvidence
    case learning
    case earlySignal
    case directional

    static func forCount(_ count: Int) -> ForecastSampleState {
        switch count {
        case 0: return .noEvidence
        case 1..<5: return .learning
        case 5..<10: return .earlySignal
        default: return .directional
        }
    }
}

struct ForecastExclusionCounts: Equatable {
    let totalPredictions: Int
    let sample: Int
    let pending: Int
    let partial: Int
    let notYetDue: Int
    let invalidConfidence: Int

    var excludedCount: Int { sample + pending + partial + notYetDue + invalidConfidence }
}

struct ForecastMetricSummary: Equatable {
    let eligibleCount: Int
    let correctCount: Int
    let meanConfidence: Double
    let observedRate: Double
    /// Observed outcome rate minus stated probability, in fractional points.
    /// Negative values mean the observed rate was lower than stated confidence.
    let signedGap: Double
    let meanBrierScore: Double?
    let sampleState: ForecastSampleState
}

struct ConfidenceBandSummary: Identifiable, Equatable {
    var id: String { band.id }
    let band: ConfidenceBand
    let metric: ForecastMetricSummary
}

struct HighConfidenceSummary: Equatable {
    static let range = 80...100
    let metric: ForecastMetricSummary
}

enum ForecastHorizonBand: String, CaseIterable, Identifiable {
    case weekOrLess = "0–7 days"
    case month = "8–30 days"
    case quarter = "31–90 days"
    case longer = "91+ days"

    var id: String { rawValue }
}

struct CategoryForecastCohort: Identifiable, Equatable {
    var id: String { category.id }
    let category: DecisionCategory
    let metric: ForecastMetricSummary
}

struct HorizonForecastCohort: Identifiable, Equatable {
    var id: String { horizon.id }
    let horizon: ForecastHorizonBand
    let metric: ForecastMetricSummary
}

struct ReasoningForecastCohort: Identifiable, Equatable {
    var id: String { hasReasoning ? "with-reasoning" : "without-reasoning" }
    let hasReasoning: Bool
    let metric: ForecastMetricSummary
}

/// All values in this snapshot are strictly binary forecast measures. It is a
/// pure view of local data, so it can be tested without SwiftData or a clock.
struct ForecastAnalyticsSnapshot: Equatable {
    static let cohortMinimumSampleSize = 8

    let overall: ForecastMetricSummary
    let highConfidence: HighConfidenceSummary
    let confidenceBands: [ConfidenceBandSummary]
    let exclusions: ForecastExclusionCounts
    /// Cohorts below the gate are intentionally omitted. Their absence is not
    /// evidence of a difference; a caller can use `cohortMinimumSampleSize` to
    /// render an honest learning state.
    let categoryCohorts: [CategoryForecastCohort]
    let horizonCohorts: [HorizonForecastCohort]
    let reasoningCohorts: [ReasoningForecastCohort]
}

private struct EligibleForecast {
    let prediction: Prediction
    let decision: Decision

    var probability: Double { Double(prediction.probabilityPercent) / 100 }
    var outcome: Double { prediction.status == .correct ? 1 : 0 }
}

enum Statistics {

    // MARK: Strict binary forecast analytics

    /// Returns deterministic, sample-safe forecast analytics. Only explicit
    /// correct/incorrect verdicts whose check date has arrived are eligible: a
    /// review recorded early remains outside calibration until it is due.
    static func forecastAnalytics(
        _ decisions: [Decision],
        asOf referenceDate: Date = Date()
    ) -> ForecastAnalyticsSnapshot {
        let selection = strictBinaryForecasts(decisions, asOf: referenceDate)
        let forecasts = selection.forecasts
        let overall = forecastMetric(for: forecasts)

        let confidenceBands = ConfidenceBand.allCases.map { band in
            ConfidenceBandSummary(
                band: band,
                metric: forecastMetric(for: forecasts.filter {
                    band.range.contains($0.prediction.probabilityPercent)
                })
            )
        }
        let highConfidence = HighConfidenceSummary(
            metric: forecastMetric(for: forecasts.filter {
                HighConfidenceSummary.range.contains($0.prediction.probabilityPercent)
            })
        )

        let categoryCohorts = DecisionCategory.allCases.compactMap { category -> CategoryForecastCohort? in
            let metric = forecastMetric(for: forecasts.filter { $0.decision.category == category })
            guard metric.eligibleCount >= ForecastAnalyticsSnapshot.cohortMinimumSampleSize else { return nil }
            return CategoryForecastCohort(category: category, metric: metric)
        }
        let horizonCohorts = ForecastHorizonBand.allCases.compactMap { horizon -> HorizonForecastCohort? in
            let metric = forecastMetric(for: forecasts.filter { horizonBand(for: $0) == horizon })
            guard metric.eligibleCount >= ForecastAnalyticsSnapshot.cohortMinimumSampleSize else { return nil }
            return HorizonForecastCohort(horizon: horizon, metric: metric)
        }
        // Keep both cohorts in a stable false/true order when they have enough
        // evidence. A one-sided cohort is not a comparison and is withheld.
        let withoutReasoning = forecastMetric(for: forecasts.filter { !hasReasoning($0.decision) })
        let withReasoning = forecastMetric(for: forecasts.filter { hasReasoning($0.decision) })
        let reasoningCohorts: [ReasoningForecastCohort]
        if withoutReasoning.eligibleCount >= ForecastAnalyticsSnapshot.cohortMinimumSampleSize,
           withReasoning.eligibleCount >= ForecastAnalyticsSnapshot.cohortMinimumSampleSize {
            reasoningCohorts = [
                ReasoningForecastCohort(hasReasoning: false, metric: withoutReasoning),
                ReasoningForecastCohort(hasReasoning: true, metric: withReasoning)
            ]
        } else {
            reasoningCohorts = []
        }

        return ForecastAnalyticsSnapshot(
            overall: overall,
            highConfidence: highConfidence,
            confidenceBands: confidenceBands,
            exclusions: selection.exclusions,
            categoryCohorts: categoryCohorts,
            horizonCohorts: horizonCohorts,
            reasoningCohorts: reasoningCohorts
        )
    }

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
        let reviews = reviewedDecisions(decisions)
            .compactMap(\.outcomeReview)
            .filter(\.hasDecisionQuality)
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.decisionQuality }) / Double(reviews.count)
    }

    static func averageOutcomeQuality(_ decisions: [Decision]) -> Double {
        let reviews = reviewedDecisions(decisions)
            .compactMap(\.outcomeReview)
            .filter(\.hasOutcomeQuality)
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.outcomeQuality }) / Double(reviews.count)
    }

    /// Average stated confidence across every prediction (0–100).
    static func averageConfidence(_ decisions: [Decision]) -> Int {
        let predictions = decisions.flatMap { $0.predictions }
        guard !predictions.isEmpty else { return 0 }
        return predictions.reduce(0) { $0 + $1.probabilityPercent } / predictions.count
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

    /// Calibration is derived only from real, resolved binary predictions.
    /// Partial outcomes remain visible in reflection but are excluded because
    /// self-assigned fractional credit is not binary calibration evidence.
    static func calibrationInsight(
        _ decisions: [Decision],
        confidenceRange: ClosedRange<Int>? = nil,
        asOf referenceDate: Date = Date()
    ) -> CalibrationInsight {
        let resolved = strictBinaryForecasts(decisions, asOf: referenceDate).forecasts.filter { forecast in
            confidenceRange?.contains(forecast.prediction.probabilityPercent) ?? true
        }
        let count = resolved.count
        guard count > 0 else {
            return CalibrationInsight(resolvedCount: 0, averageStatedConfidence: 0, hitRate: 0, gap: 0, assessment: .keepResolving)
        }
        let stated = resolved.reduce(0.0) { $0 + $1.probability } / Double(count)
        let hitRate = resolved.reduce(0.0) { $0 + $1.outcome } / Double(count)
        let gap = stated - hitRate
        let assessment: CalibrationInsight.Assessment
        if count < CalibrationInsight.minimumSampleSize {
            assessment = .keepResolving
        } else if gap >= 0.15 {
            assessment = .overconfident
        } else if gap <= -0.15 {
            assessment = .underconfident
        } else {
            assessment = .wellCalibrated
        }
        return CalibrationInsight(resolvedCount: count, averageStatedConfidence: stated, hitRate: hitRate, gap: gap, assessment: assessment)
    }

    // MARK: Charts

    static func decisionsByCategory(_ decisions: [Decision]) -> [CategoryCount] {
        DecisionCategory.allCases.compactMap { category in
            let count = decisions.filter { $0.category == category }.count
            return count > 0 ? CategoryCount(category: category, count: count) : nil
        }
    }

    /// Paired outcome/process quality over time. A point exists only when both
    /// optional ratings were answered; backing defaults are never evidence.
    static func qualityOverTime(_ decisions: [Decision]) -> [QualityPoint] {
        reviewedDecisions(decisions)
            .compactMap { decision -> QualityPoint? in
                guard let review = decision.outcomeReview,
                      review.hasDecisionQuality,
                      review.hasOutcomeQuality else { return nil }
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

        // Stakes vs decision quality.
        let qualityRated = reviewed.filter { $0.outcomeReview?.hasDecisionQuality == true }
        let highStakes = qualityRated.filter { $0.stakesLevel.weight >= 3 }
        let lowStakes  = qualityRated.filter { $0.stakesLevel.weight < 3 }
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

        // Reversible vs irreversible regret.
        let irreversible = reviewed.filter {
            !$0.isReversible && $0.outcomeReview?.hasWouldDoAgain == true
        }
        if irreversible.count >= 2 {
            let regret = irreversible.filter { $0.outcomeReview?.wouldDoAgain == false }.count
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
        let reviews = decisions.compactMap(\.outcomeReview).filter(\.hasDecisionQuality)
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.decisionQuality }) / Double(reviews.count)
    }

    private static func reviewRatio(_ tuple: (DecisionCategory, Int, Int)) -> Double {
        tuple.1 == 0 ? 0 : Double(tuple.2) / Double(tuple.1)
    }

    private static func formatted(_ value: Double) -> String {
        String(format: "%.1f/5", value)
    }

    private static func strictBinaryForecasts(
        _ decisions: [Decision],
        asOf referenceDate: Date
    ) -> (forecasts: [EligibleForecast], exclusions: ForecastExclusionCounts) {
        var forecasts: [EligibleForecast] = []
        var sample = 0
        var pending = 0
        var partial = 0
        var notYetDue = 0
        var invalidConfidence = 0
        var total = 0

        for decision in decisions {
            for prediction in decision.predictions {
                total += 1
                // Stable sample UUID provenance is the only currently
                // available production provenance signal. It intentionally
                // occurs before status validation so demo calls never affect
                // an exclusion category or any denominator.
                guard !SampleData.isDemoDecision(decision) else {
                    sample += 1
                    continue
                }
                guard (0...100).contains(prediction.probabilityPercent) else {
                    invalidConfidence += 1
                    continue
                }
                switch prediction.status {
                case .correct, .incorrect:
                    guard prediction.dueDate <= referenceDate else {
                        notYetDue += 1
                        continue
                    }
                    forecasts.append(EligibleForecast(prediction: prediction, decision: decision))
                case .pending:
                    pending += 1
                case .partial:
                    partial += 1
                }
            }
        }
        return (
            forecasts,
            ForecastExclusionCounts(
                totalPredictions: total,
                sample: sample,
                pending: pending,
                partial: partial,
                notYetDue: notYetDue,
                invalidConfidence: invalidConfidence
            )
        )
    }

    private static func forecastMetric(for forecasts: [EligibleForecast]) -> ForecastMetricSummary {
        let count = forecasts.count
        guard count > 0 else {
            return ForecastMetricSummary(
                eligibleCount: 0, correctCount: 0, meanConfidence: 0,
                observedRate: 0, signedGap: 0, meanBrierScore: nil,
                sampleState: .noEvidence
            )
        }
        let meanConfidence = forecasts.reduce(0.0) { $0 + $1.probability } / Double(count)
        let correctCount = forecasts.reduce(0) { $0 + Int($1.outcome) }
        let observedRate = Double(correctCount) / Double(count)
        let brier = forecasts.reduce(0.0) { partial, forecast in
            let error = forecast.probability - forecast.outcome
            return partial + error * error
        } / Double(count)
        return ForecastMetricSummary(
            eligibleCount: count,
            correctCount: correctCount,
            meanConfidence: meanConfidence,
            observedRate: observedRate,
            signedGap: observedRate - meanConfidence,
            meanBrierScore: brier,
            sampleState: ForecastSampleState.forCount(count)
        )
    }

    private static func horizonBand(for forecast: EligibleForecast) -> ForecastHorizonBand {
        let start = forecast.decision.decidedAt ?? forecast.decision.createdAt
        let days = max(0, Int(floor(forecast.prediction.dueDate.timeIntervalSince(start) / 86_400)))
        switch days {
        case ...7: return .weekOrLess
        case 8...30: return .month
        case 31...90: return .quarter
        default: return .longer
        }
    }

    private static func hasReasoning(_ decision: Decision) -> Bool {
        !decision.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
