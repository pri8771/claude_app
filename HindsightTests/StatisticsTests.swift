//
//  StatisticsTests.swift
//  HindsightTests
//
//  Unit tests for the analytics functions that drive the Insights screen.
//

import XCTest
@testable import Hindsight

final class StatisticsTests: XCTestCase {

    // MARK: Helpers

    private func decision(
        category: DecisionCategory = .personal,
        stakes: StakesLevel = .medium,
        status: DecisionStatus = .active,
        predictions: [Prediction] = [],
        review: OutcomeReview? = nil
    ) -> Decision {
        let d = Decision(category: category, stakesLevel: stakes, status: status)
        d.predictions = predictions
        d.outcomeReview = review
        return d
    }

    private func prediction(_ percent: Int, _ status: PredictionStatus) -> Prediction {
        Prediction(probabilityPercent: percent, status: status)
    }

    // MARK: Tests

    func testReviewRateRounds() {
        let decisions = [
            decision(status: .reviewed, review: OutcomeReview()),
            decision(status: .reviewed, review: OutcomeReview()),
            decision(status: .active)
        ]
        // 2 of 3 reviewed → 66.67% → 67
        XCTAssertEqual(Statistics.reviewRate(decisions), 67)
    }

    func testReviewRateEmptyIsZero() {
        XCTAssertEqual(Statistics.reviewRate([]), 0)
    }

    func testAverageConfidenceRoundsRatherThanTruncates() {
        // 50 and 51 → mean 50.5 → rounds to 51 (truncation would give 50).
        let decisions = [
            decision(predictions: [prediction(50, .pending), prediction(51, .pending)])
        ]
        XCTAssertEqual(Statistics.averageConfidence(decisions), 51)
    }

    func testPredictionAccuracyPartialCountsAsHalf() {
        let decisions = [
            decision(predictions: [
                prediction(80, .correct),
                prediction(60, .incorrect),
                prediction(50, .partial)
            ])
        ]
        // (1.0 + 0.0 + 0.5) / 3 = 0.5
        XCTAssertEqual(Statistics.predictionAccuracy(decisions), 0.5, accuracy: 0.0001)
    }

    func testPredictionAccuracyIgnoresPending() {
        let decisions = [
            decision(predictions: [
                prediction(80, .correct),
                prediction(50, .pending)
            ])
        ]
        // Only the resolved one counts → 1.0
        XCTAssertEqual(Statistics.predictionAccuracy(decisions), 1.0, accuracy: 0.0001)
    }

    func testPredictionStatusCountsCoverAllCases() {
        let decisions = [
            decision(predictions: [
                prediction(80, .correct),
                prediction(80, .correct),
                prediction(50, .pending)
            ])
        ]
        let counts = Statistics.predictionStatusCounts(decisions)
        XCTAssertEqual(counts.count, PredictionStatus.allCases.count)
        XCTAssertEqual(counts.first { $0.status == .correct }?.count, 2)
        XCTAssertEqual(counts.first { $0.status == .pending }?.count, 1)
        XCTAssertEqual(counts.first { $0.status == .incorrect }?.count, 0)
    }

    func testDecisionsByCategoryOmitsEmptyCategories() {
        let decisions = [
            decision(category: .career),
            decision(category: .career),
            decision(category: .health)
        ]
        let byCategory = Statistics.decisionsByCategory(decisions)
        XCTAssertEqual(byCategory.count, 2)
        XCTAssertEqual(byCategory.first { $0.category == .career }?.count, 2)
        XCTAssertNil(byCategory.first { $0.category == .financial })
    }

    func testReviewedDecisionsRequiresOutcomeReview() {
        // Marked reviewed but missing a review object → not counted.
        let decisions = [
            decision(status: .reviewed, review: nil),
            decision(status: .reviewed, review: OutcomeReview())
        ]
        XCTAssertEqual(Statistics.reviewedDecisions(decisions).count, 1)
    }

    func testPatternsPlaceholderWhenTooFewReviews() {
        let patterns = Statistics.patterns([decision(status: .active)])
        XCTAssertEqual(patterns.count, 1)
        XCTAssertEqual(patterns.first?.title, "Patterns unlock as you review")
    }
}
