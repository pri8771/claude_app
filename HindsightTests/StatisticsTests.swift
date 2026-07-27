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
        status: PredictionStatus
    ) {
        decision.predictions.append(Prediction(title: "p", probabilityPercent: probability, status: status))
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

    // MARK: Patterns — confidence calibration drill-through

    func testPatternsDetectsOverconfidence() {
        let a = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: a)
        addPrediction(to: a, probability: 80, status: .correct)
        addPrediction(to: a, probability: 80, status: .partial)
        let b = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: b)
        addPrediction(to: b, probability: 80, status: .incorrect)
        addPrediction(to: b, probability: 80, status: .correct)

        // avgStated = 0.8, actual = (1.0 + 0.5 + 0.0 + 1.0)/4 = 0.625, gap = 0.175 >= 0.15
        let patterns = Statistics.patterns([a, b])
        XCTAssertTrue(patterns.contains { $0.title == "You tend to be overconfident" })
    }

    func testPatternsDetectsUnderselling() {
        let a = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: a)
        addPrediction(to: a, probability: 30, status: .correct)
        addPrediction(to: a, probability: 30, status: .correct)
        let b = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: b)
        addPrediction(to: b, probability: 30, status: .correct)
        addPrediction(to: b, probability: 30, status: .correct)

        // avgStated = 0.3, actual = 1.0, gap = -0.7 <= -0.15
        let patterns = Statistics.patterns([a, b])
        XCTAssertTrue(patterns.contains { $0.title == "You sell yourself short" })
    }

    func testPatternsDetectsGoodCalibration() {
        let a = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: a)
        addPrediction(to: a, probability: 70, status: .correct)
        addPrediction(to: a, probability: 70, status: .correct)
        let b = makeDecision(category: .personal, stakes: .medium)
        attachReview(to: b)
        addPrediction(to: b, probability: 70, status: .incorrect)

        // avgStated = 0.7, actual = (1.0 + 1.0 + 0.0)/3 = 0.667, gap ~= 0.033, within +-0.15
        let patterns = Statistics.patterns([a, b])
        XCTAssertTrue(patterns.contains { $0.title == "Your gut is well-calibrated" })
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
}
