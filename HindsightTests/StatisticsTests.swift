//
//  StatisticsTests.swift
//  HindsightTests
//
//  Unit tests for `Statistics`, the pure functions behind every number and
//  pattern shown on the Insights screen. Covers headline numbers, sample-size
//  gating, and drill-through correctness of the pattern heuristics — the two
//  things Docs/STATUS.md flags as unverified.
//

import XCTest
@testable import Hindsight

@MainActor
final class StatisticsTests: XCTestCase {

    // MARK: Helpers

    private func makeDecision(
        title: String = "Decision",
        category: DecisionCategory = .personal,
        stakes: StakesLevel = .medium,
        isReversible: Bool = true,
        status: DecisionStatus = .active
    ) -> Decision {
        Decision(title: title, category: category, stakesLevel: stakes, status: status, isReversible: isReversible)
    }

    private func attachReview(
        to decision: Decision,
        decisionQuality: Int = 3,
        outcomeQuality: Int = 3,
        wouldDoAgain: Bool = true
    ) {
        decision.status = .reviewed
        decision.outcomeReview = OutcomeReview(
            outcomeQuality: outcomeQuality, decisionQuality: decisionQuality, wouldDoAgain: wouldDoAgain
        )
    }

    private func addPrediction(
        to decision: Decision,
        probability: Int,
        status: PredictionStatus,
        dueDate: Date = Date(timeIntervalSince1970: 0)
    ) {
        decision.predictions.append(Prediction(title: "p", probabilityPercent: probability, dueDate: dueDate, status: status))
    }

    // MARK: Headline numbers — empty state

    func testHeadlineNumbersOnEmptyDataset() {
        XCTAssertEqual(Statistics.totalDecisions([]), 0)
        XCTAssertEqual(Statistics.reviewRate([]), 0)
        XCTAssertEqual(Statistics.averageDecisionQuality([]), 0)
        XCTAssertEqual(Statistics.averageOutcomeQuality([]), 0)
        XCTAssertEqual(Statistics.averageConfidence([]), 0)
        XCTAssertEqual(Statistics.predictionAccuracy([]), 0)
        XCTAssertTrue(Statistics.decisionsByCategory([]).isEmpty)
        XCTAssertEqual(Statistics.qualityOverTime([]).count, 0)
    }

    // MARK: Review rate

    func testReviewRateRoundsToNearestPercent() {
        let reviewed = makeDecision()
        attachReview(to: reviewed)
        let active = makeDecision()
        let awaiting = makeDecision(status: .awaitingReview)

        // 1 of 3 reviewed = 33.33...% -> rounds to 33.
        XCTAssertEqual(Statistics.reviewRate([reviewed, active, awaiting]), 33)
    }

    func testReviewedDecisionsRequiresBothStatusAndOutcomeReview() {
        let reviewedNoReview = makeDecision(status: .reviewed) // status flipped without attaching a review
        let properlyReviewed = makeDecision()
        attachReview(to: properlyReviewed)

        let reviewed = Statistics.reviewedDecisions([reviewedNoReview, properlyReviewed])
        XCTAssertEqual(reviewed.count, 1)
        XCTAssertTrue(reviewed.contains { $0 === properlyReviewed })
    }

    // MARK: Average quality

    func testAverageQualityAveragesOnlyReviewedDecisions() {
        let a = makeDecision()
        attachReview(to: a, decisionQuality: 4, outcomeQuality: 2)
        let b = makeDecision()
        attachReview(to: b, decisionQuality: 2, outcomeQuality: 4)
        let unreviewed = makeDecision()

        XCTAssertEqual(Statistics.averageDecisionQuality([a, b, unreviewed]), 3.0)
        XCTAssertEqual(Statistics.averageOutcomeQuality([a, b, unreviewed]), 3.0)
    }

    func testOmittedOptionalRatingsDoNotAffectAveragesOrPairedTrend() {
        let rated = makeDecision()
        attachReview(to: rated, decisionQuality: 4, outcomeQuality: 5)

        let omitted = makeDecision()
        omitted.status = .reviewed
        omitted.outcomeReview = OutcomeReview(whatHappened: "Facts only")

        let processOnly = makeDecision()
        processOnly.status = .reviewed
        processOnly.outcomeReview = OutcomeReview(decisionQuality: 1)

        XCTAssertEqual(Statistics.averageDecisionQuality([rated, omitted, processOnly]), 2.5)
        XCTAssertEqual(Statistics.averageOutcomeQuality([rated, omitted, processOnly]), 5)
        XCTAssertEqual(Statistics.qualityOverTime([rated, omitted, processOnly]).count, 1)
    }

    // MARK: Average confidence

    func testAverageConfidenceAcrossAllPredictions() {
        let a = makeDecision()
        addPrediction(to: a, probability: 40, status: .pending)
        let b = makeDecision()
        addPrediction(to: b, probability: 80, status: .correct)

        // (40 + 80) / 2 = 60
        XCTAssertEqual(Statistics.averageConfidence([a, b]), 60)
    }

    // MARK: Prediction accuracy

    func testPredictionAccuracyExcludesPendingAndWeightsPartialAsHalf() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 50, status: .correct)   // 1.0
        addPrediction(to: decision, probability: 50, status: .partial)  // 0.5
        addPrediction(to: decision, probability: 50, status: .incorrect) // 0.0
        addPrediction(to: decision, probability: 50, status: .pending)  // excluded entirely

        // (1.0 + 0.5 + 0.0) / 3 resolved predictions = 0.5
        XCTAssertEqual(Statistics.predictionAccuracy([decision]), 0.5, accuracy: 0.0001)
    }

    // MARK: Calibration insight

    func testCalibrationInsightKeepsResolvingBelowMinimumSample() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 10, status: .pending)

        let insight = Statistics.calibrationInsight([decision])
        XCTAssertEqual(insight.resolvedCount, 2)
        XCTAssertEqual(insight.assessment, .keepResolving)
        XCTAssertEqual(insight.averageStatedConfidence, 0.9, accuracy: 0.0001)
        XCTAssertEqual(insight.hitRate, 0, accuracy: 0.0001)
    }

    func testCalibrationInsightDetectsOverconfidenceUsingOnlyResolvedPredictions() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 90, status: .partial)
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 0, status: .pending)

        let insight = Statistics.calibrationInsight([decision])
        XCTAssertEqual(insight.resolvedCount, 3)
        XCTAssertEqual(insight.assessment, .overconfident)
        XCTAssertEqual(insight.averageStatedConfidence, 0.9, accuracy: 0.0001)
        XCTAssertEqual(insight.hitRate, 0, accuracy: 0.0001)
    }

    func testCalibrationInsightDetectsUnderconfidenceAndWellCalibrated() {
        let underconfident = makeDecision()
        for _ in 0..<3 { addPrediction(to: underconfident, probability: 20, status: .correct) }
        XCTAssertEqual(Statistics.calibrationInsight([underconfident]).assessment, .underconfident)

        let calibrated = makeDecision()
        addPrediction(to: calibrated, probability: 70, status: .correct)
        addPrediction(to: calibrated, probability: 70, status: .correct)
        addPrediction(to: calibrated, probability: 70, status: .incorrect)
        XCTAssertEqual(Statistics.calibrationInsight([calibrated]).assessment, .wellCalibrated)
    }

    func testCalibrationInsightHasNoClaimForZeroResolvedPredictions() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 100, status: .pending)
        let insight = Statistics.calibrationInsight([decision])
        XCTAssertEqual(insight.resolvedCount, 0)
        XCTAssertEqual(insight.assessment, .keepResolving)
        XCTAssertEqual(insight.gap, 0)
    }

    func testCalibrationInsightCanFocusOnHighConfidencePredictions() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 85, status: .correct)
        addPrediction(to: decision, probability: 90, status: .incorrect)
        addPrediction(to: decision, probability: 95, status: .incorrect)
        addPrediction(to: decision, probability: 75, status: .correct)

        let insight = Statistics.calibrationInsight([decision], confidenceRange: 80...100)

        XCTAssertEqual(insight.resolvedCount, 3)
        XCTAssertEqual(insight.averageStatedConfidence, 0.9, accuracy: 0.0001)
        XCTAssertEqual(insight.hitRate, 1.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(insight.assessment, .overconfident)
    }

    // MARK: Strict binary forecast analytics

    func testForecastAnalyticsExcludesSamplesPendingAndPartialFromEveryStrictDenominator() {
        let real = makeDecision()
        addPrediction(to: real, probability: 80, status: .correct)
        addPrediction(to: real, probability: 80, status: .pending)
        addPrediction(to: real, probability: 80, status: .partial)

        let sample = makeDecision()
        sample.id = UUID(uuidString: "A1F00100-0000-4000-8000-000000000001")!
        addPrediction(to: sample, probability: 100, status: .correct)

        let snapshot = Statistics.forecastAnalytics([real, sample])
        XCTAssertEqual(snapshot.overall.eligibleCount, 1)
        XCTAssertEqual(snapshot.overall.correctCount, 1)
        XCTAssertEqual(snapshot.overall.meanConfidence, 0.8, accuracy: 0.0001)
        XCTAssertEqual(snapshot.exclusions.totalPredictions, 4)
        XCTAssertEqual(snapshot.exclusions.sample, 1)
        XCTAssertEqual(snapshot.exclusions.pending, 1)
        XCTAssertEqual(snapshot.exclusions.partial, 1)
        XCTAssertEqual(snapshot.exclusions.notYetDue, 0)
        XCTAssertEqual(snapshot.exclusions.excludedCount, 3)
        XCTAssertEqual(snapshot.highConfidence.metric.eligibleCount, 1)
    }

    func testForecastAnalyticsCountsMalformedSampleOnlyAsSampleNotPersonalEvidence() {
        let personal = makeDecision()
        addPrediction(to: personal, probability: 80, status: .correct)

        let sample = makeDecision()
        sample.id = UUID(uuidString: "A1F00100-0000-4000-8000-000000000001")!
        addPrediction(to: sample, probability: 101, status: .correct)

        let snapshot = Statistics.forecastAnalytics([personal, sample])
        XCTAssertEqual(snapshot.overall.eligibleCount, 1)
        XCTAssertEqual(snapshot.exclusions.totalPredictions, 2)
        XCTAssertEqual(snapshot.exclusions.sample, 1)
        XCTAssertEqual(snapshot.exclusions.invalidConfidence, 0)
    }

    func testForecastAnalyticsPlacesEveryConfidenceBoundaryInStableBands() {
        let decision = makeDecision()
        let boundaries = [0, 1, 49, 50, 59, 60, 69, 70, 79, 80, 89, 90, 99, 100]
        for (index, probability) in boundaries.enumerated() {
            addPrediction(to: decision, probability: probability, status: index.isMultiple(of: 2) ? .correct : .incorrect)
        }

        let bands = Statistics.forecastAnalytics([decision]).confidenceBands
        XCTAssertEqual(bands.map(\.band), ConfidenceBand.allCases)
        XCTAssertEqual(bands.map(\.metric.eligibleCount), [3, 2, 2, 2, 2, 2, 1])
        XCTAssertEqual(bands.first?.metric.meanConfidence ?? -1, Double(0 + 1 + 49) / 300, accuracy: 0.0001)
        XCTAssertEqual(bands.last?.metric.meanConfidence ?? -1, 1, accuracy: 0.0001)
    }

    func testForecastAnalyticsCalculatesHandCheckedMeanBrierAndSignedGap() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 80, status: .correct)   // (0.8 - 1)^2 = 0.04
        addPrediction(to: decision, probability: 60, status: .incorrect) // (0.6 - 0)^2 = 0.36

        let metric = Statistics.forecastAnalytics([decision]).overall
        XCTAssertEqual(metric.eligibleCount, 2)
        XCTAssertEqual(metric.correctCount, 1)
        XCTAssertEqual(metric.meanConfidence, 0.7, accuracy: 0.0001)
        XCTAssertEqual(metric.observedRate, 0.5, accuracy: 0.0001)
        XCTAssertEqual(metric.signedGap, -0.2, accuracy: 0.0001)
        XCTAssertEqual(metric.meanBrierScore ?? -1, 0.2, accuracy: 0.0001)
    }

    func testForecastAnalyticsWithholdsEarlyTerminalOutcomeUntilOriginalCheckDate() {
        let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)
        let checkDate = referenceDate.addingTimeInterval(86_400)
        let reviewedEarly = makeDecision(status: .reviewed)
        reviewedEarly.outcomeReview = OutcomeReview(reviewedAt: referenceDate)
        addPrediction(to: reviewedEarly, probability: 80, status: .correct, dueDate: checkDate)

        let beforeDue = Statistics.forecastAnalytics([reviewedEarly], asOf: referenceDate)
        XCTAssertEqual(beforeDue.overall.eligibleCount, 0)
        XCTAssertEqual(beforeDue.exclusions.notYetDue, 1)
        XCTAssertEqual(beforeDue.exclusions.excludedCount, 1)
        XCTAssertEqual(
            Statistics.calibrationInsight([reviewedEarly], asOf: referenceDate).resolvedCount,
            0
        )

        let atDue = Statistics.forecastAnalytics([reviewedEarly], asOf: checkDate)
        XCTAssertEqual(atDue.overall.eligibleCount, 1)
        XCTAssertEqual(atDue.exclusions.notYetDue, 0)
        XCTAssertEqual(
            Statistics.calibrationInsight([reviewedEarly], asOf: checkDate).resolvedCount,
            1
        )
    }

    func testForecastAnalyticsUsesHonestLowSampleGates() {
        let learning = makeDecision()
        for _ in 0..<4 { addPrediction(to: learning, probability: 70, status: .correct) }
        XCTAssertEqual(Statistics.forecastAnalytics([learning]).overall.sampleState, .learning)

        let early = makeDecision()
        for _ in 0..<5 { addPrediction(to: early, probability: 70, status: .correct) }
        XCTAssertEqual(Statistics.forecastAnalytics([early]).overall.sampleState, .earlySignal)

        let directional = makeDecision()
        for _ in 0..<10 { addPrediction(to: directional, probability: 70, status: .correct) }
        XCTAssertEqual(Statistics.forecastAnalytics([directional]).overall.sampleState, .directional)

        let emptyBand = Statistics.forecastAnalytics([learning]).confidenceBands.first { $0.band == .ninetyToNinetyNine }
        XCTAssertEqual(emptyBand?.metric.sampleState, .noEvidence)
    }

    func testForecastAnalyticsReturnsOnlyDeterministicallyEligibleCohorts() {
        let base = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let career = Decision(category: .career, createdAt: base)
        career.notes = "Assumptions recorded"
        for _ in 0..<8 {
            addPrediction(to: career, probability: 80, status: .correct,
                          dueDate: base.addingTimeInterval(7 * 86_400))
        }
        let health = Decision(category: .health, createdAt: base)
        health.notes = "   "
        for _ in 0..<8 {
            addPrediction(to: health, probability: 60, status: .incorrect,
                          dueDate: base.addingTimeInterval(91 * 86_400))
        }
        let snapshot = Statistics.forecastAnalytics([health, career])

        XCTAssertEqual(snapshot.categoryCohorts.map(\.category), [.career, .health])
        XCTAssertEqual(snapshot.horizonCohorts.map(\.horizon), [.weekOrLess, .longer])
        XCTAssertEqual(snapshot.reasoningCohorts.map(\.hasReasoning), [false, true])
        XCTAssertEqual(snapshot.reasoningCohorts.map(\.metric.eligibleCount), [8, 8])

        let insufficient = makeDecision(category: .financial)
        for _ in 0..<7 { addPrediction(to: insufficient, probability: 70, status: .correct) }
        XCTAssertTrue(Statistics.forecastAnalytics([insufficient]).categoryCohorts.isEmpty)
        XCTAssertTrue(Statistics.forecastAnalytics([insufficient]).reasoningCohorts.isEmpty)
    }

    func testPredictionStatusCountsIncludesEveryStatusEvenAtZero() {
        let decision = makeDecision()
        addPrediction(to: decision, probability: 50, status: .correct)

        let counts = Statistics.predictionStatusCounts([decision])
        XCTAssertEqual(counts.count, PredictionStatus.allCases.count)
        XCTAssertEqual(counts.first { $0.status == .correct }?.count, 1)
        XCTAssertEqual(counts.first { $0.status == .pending }?.count, 0)
        XCTAssertEqual(counts.first { $0.status == .incorrect }?.count, 0)
        XCTAssertEqual(counts.first { $0.status == .partial }?.count, 0)
    }

    // MARK: Category breakdown

    func testDecisionsByCategoryOmitsEmptyCategories() {
        let a = makeDecision(category: .career)
        let b = makeDecision(category: .career)
        let c = makeDecision(category: .health)

        let counts = Statistics.decisionsByCategory([a, b, c])
        XCTAssertEqual(counts.count, 2, "Only categories with at least one decision should appear")
        XCTAssertEqual(counts.first { $0.category == .career }?.count, 2)
        XCTAssertEqual(counts.first { $0.category == .health }?.count, 1)
        XCTAssertNil(counts.first { $0.category == .financial })
    }

    // MARK: Quality over time

    func testQualityOverTimeSortsChronologically() {
        let later = makeDecision()
        attachReview(to: later)
        later.outcomeReview?.reviewedAt = Date()

        let earlier = makeDecision()
        attachReview(to: earlier)
        earlier.outcomeReview?.reviewedAt = Date(timeIntervalSinceNow: -86_400 * 10)

        let points = Statistics.qualityOverTime([later, earlier])
        XCTAssertEqual(points.count, 2)
        XCTAssertLessThan(points[0].date, points[1].date, "Points must be sorted earliest first")
    }

    // MARK: Patterns — sample-size gating

    func testPatternsShowsPlaceholderWithFewerThanTwoReviews() {
        XCTAssertEqual(Statistics.patterns([]).count, 1)
        XCTAssertEqual(Statistics.patterns([]).first?.title, "Patterns unlock as you review")

        let onlyOneReviewed = makeDecision()
        attachReview(to: onlyOneReviewed)
        let patterns = Statistics.patterns([onlyOneReviewed])
        XCTAssertEqual(patterns.count, 1)
        XCTAssertEqual(patterns.first?.title, "Patterns unlock as you review")
    }

    func testPatternsFallsBackToKeepReviewingWhenNoHeuristicFires() {
        // Two reviewed decisions, same (low) stakes bucket, same category
        // with a full review ratio, no predictions, all reversible — every
        // other heuristic's guard should fail, leaving only the fallback.
        let a = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: a, decisionQuality: 3)
        let b = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: b, decisionQuality: 3)

        let patterns = Statistics.patterns([a, b])
        XCTAssertEqual(patterns.count, 1)
        XCTAssertEqual(patterns.first?.title, "Keep reviewing")
    }

    // MARK: Patterns — stakes vs. quality drill-through

    func testPatternsDetectsRisingToHighStakes() {
        let high1 = makeDecision(stakes: .high)
        attachReview(to: high1, decisionQuality: 5)
        let high2 = makeDecision(stakes: .critical)
        attachReview(to: high2, decisionQuality: 5)
        let low1 = makeDecision(stakes: .low)
        attachReview(to: low1, decisionQuality: 3)
        let low2 = makeDecision(stakes: .medium)
        attachReview(to: low2, decisionQuality: 3)

        let patterns = Statistics.patterns([high1, high2, low1, low2])
        XCTAssertTrue(patterns.contains { $0.title == "You rise to high stakes" })
    }

    func testPatternsDetectsHighStakesTrippingUp() {
        let high1 = makeDecision(stakes: .high)
        attachReview(to: high1, decisionQuality: 2)
        let high2 = makeDecision(stakes: .critical)
        attachReview(to: high2, decisionQuality: 2)
        let low1 = makeDecision(stakes: .low)
        attachReview(to: low1, decisionQuality: 5)
        let low2 = makeDecision(stakes: .medium)
        attachReview(to: low2, decisionQuality: 5)

        let patterns = Statistics.patterns([high1, high2, low1, low2])
        XCTAssertTrue(patterns.contains { $0.title == "High stakes trip you up" })
    }

    // MARK: Patterns — unreviewed category drill-through

    func testPatternsFlagsCategoryWithLowReviewRatio() {
        // Career: 1 of 3 reviewed (33%) -> below the 50% bar, and has >= 2
        // total decisions so it's eligible to be picked.
        let reviewedCareer = makeDecision(category: .career)
        attachReview(to: reviewedCareer)
        let unreviewedCareer1 = makeDecision(category: .career, status: .active)
        let unreviewedCareer2 = makeDecision(category: .career, status: .awaitingReview)

        // A second reviewed decision, in a different category with the SAME
        // stakes bucket, purely to clear the >= 2 reviewed gate without
        // tripping the stakes heuristic.
        let otherReviewed = makeDecision(category: .health, stakes: .medium)
        attachReview(to: otherReviewed)

        let patterns = Statistics.patterns([reviewedCareer, unreviewedCareer1, unreviewedCareer2, otherReviewed])
        XCTAssertTrue(patterns.contains { $0.title == "Career decisions go unreviewed" })
    }

    // MARK: Patterns — confidence calibration is owned by its dedicated card

    func testPatternsDoesNotDuplicateDedicatedCalibrationInsight() {
        let a = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: a)
        addPrediction(to: a, probability: 80, status: .correct)
        addPrediction(to: a, probability: 80, status: .partial)
        let b = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: b)
        addPrediction(to: b, probability: 80, status: .incorrect)
        addPrediction(to: b, probability: 80, status: .correct)

        let patterns = Statistics.patterns([a, b])
        XCTAssertFalse(patterns.contains {
            $0.title.localizedCaseInsensitiveContains("confident") ||
            $0.title.localizedCaseInsensitiveContains("calibrated")
        })
    }

    // MARK: Patterns — irreversible regret drill-through

    func testPatternsDetectsNoRegretsOnIrreversibleDecisions() {
        let a = makeDecision(stakes: .critical, isReversible: false)
        attachReview(to: a, wouldDoAgain: true)
        let b = makeDecision(stakes: .critical, isReversible: false)
        attachReview(to: b, wouldDoAgain: true)

        let patterns = Statistics.patterns([a, b])
        XCTAssertTrue(patterns.contains { $0.title == "No regrets on the big ones" })
    }

    func testPatternsDoNotTreatOmittedRatingsAsNeutralQualityOrNoRegret() {
        let ratedHigh = makeDecision(stakes: .high)
        attachReview(to: ratedHigh, decisionQuality: 5)
        let ratedHighAgain = makeDecision(stakes: .critical)
        attachReview(to: ratedHighAgain, decisionQuality: 5)

        let omittedLow = makeDecision(stakes: .low, isReversible: false)
        omittedLow.status = .reviewed
        omittedLow.outcomeReview = OutcomeReview(whatHappened: "No optional answers")
        let omittedLowAgain = makeDecision(stakes: .medium, isReversible: false)
        omittedLowAgain.status = .reviewed
        omittedLowAgain.outcomeReview = OutcomeReview(whatHappened: "No optional answers")

        let patterns = Statistics.patterns([ratedHigh, ratedHighAgain, omittedLow, omittedLowAgain])
        XCTAssertFalse(patterns.contains { $0.title == "You rise to high stakes" })
        XCTAssertFalse(patterns.contains { $0.title == "No regrets on the big ones" })
    }
}
