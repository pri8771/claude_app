//
//  ClarityScoreTests.swift
//  HindsightTests
//
//  Unit tests for the pure `ClarityScore.score` function: boundary
//  behavior of each scoring dimension and the resulting label buckets.
//

import XCTest

final class ClarityScoreTests: XCTestCase {

    // MARK: Title (20 pts)

    func testEmptyTitleContributesNoPoints() {
        let scoreWithout = ClarityScore.score(
            title: "   ", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        let scoreWith = ClarityScore.score(
            title: "Take the job", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(scoreWithout, 0)
        XCTAssertEqual(scoreWith, 20)
    }

    // MARK: Notes (15 pts, >= 12 trimmed characters)

    func testNotesBelowThresholdDoNotCount() {
        let short = ClarityScore.score(
            title: "", notes: "short", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(short, 0)
    }

    func testNotesAtThresholdCount() {
        // Exactly 12 trimmed characters should just clear the bar.
        let notes = "123456789012"
        XCTAssertEqual(notes.count, 12)
        let score = ClarityScore.score(
            title: "", notes: notes, optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(score, 15)
    }

    func testNotesWhitespaceIsTrimmedBeforeCounting() {
        // 12 real characters padded with whitespace that should NOT count
        // toward the length, but if the implementation only trims (not
        // collapses) internal content this still clears the bar.
        let notes = "  123456789012  "
        let score = ClarityScore.score(
            title: "", notes: notes, optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(score, 15)
    }

    // MARK: Options (25 pts, graduated)

    func testOptionCountGraduatedScoring() {
        func score(_ count: Int) -> Int {
            ClarityScore.score(title: "", notes: "", optionCount: count, optionsWithTradeoffs: 0,
                                predictionCount: 0, hasReviewDate: false)
        }
        XCTAssertEqual(score(0), 0)
        XCTAssertEqual(score(1), 8)
        XCTAssertEqual(score(2), 18)
        XCTAssertEqual(score(3), 25)
        XCTAssertEqual(score(5), 25, "4+ options should not exceed the 25pt cap")
    }

    // MARK: Trade-offs (20 pts, proportional to ratio)

    func testTradeoffRatioScalesLinearly() {
        let half = ClarityScore.score(
            title: "", notes: "", optionCount: 2, optionsWithTradeoffs: 1,
            predictionCount: 0, hasReviewDate: false
        )
        let full = ClarityScore.score(
            title: "", notes: "", optionCount: 2, optionsWithTradeoffs: 2,
            predictionCount: 0, hasReviewDate: false
        )
        // 18 (2 options) + 10 (half of 20) = 28
        XCTAssertEqual(half, 28)
        // 18 (2 options) + 20 (full tradeoffs) = 38
        XCTAssertEqual(full, 38)
    }

    func testTradeoffsAreIgnoredWhenThereAreNoOptions() {
        // Guards against a division by zero when optionCount == 0.
        let score = ClarityScore.score(
            title: "", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(score, 0)
    }

    // MARK: Predictions (15 pts, graduated)

    func testPredictionCountGraduatedScoring() {
        func score(_ count: Int) -> Int {
            ClarityScore.score(title: "", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
                                predictionCount: count, hasReviewDate: false)
        }
        XCTAssertEqual(score(0), 0)
        XCTAssertEqual(score(1), 8)
        XCTAssertEqual(score(2), 12)
        XCTAssertEqual(score(3), 15)
        XCTAssertEqual(score(4), 15, "3+ predictions should not exceed the 15pt cap")
    }

    // MARK: Review date (5 pts, flat)

    func testReviewDateBonus() {
        let without = ClarityScore.score(
            title: "", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: false
        )
        let with = ClarityScore.score(
            title: "", notes: "", optionCount: 0, optionsWithTradeoffs: 0,
            predictionCount: 0, hasReviewDate: true
        )
        XCTAssertEqual(with - without, 5)
    }

    // MARK: A fully thorough decision reaches 100

    func testMaximallyThoroughDecisionScoresOneHundred() {
        let score = ClarityScore.score(
            title: "Take the job",
            notes: "This is a long enough note to clear the notes threshold easily.",
            optionCount: 3,
            optionsWithTradeoffs: 3,
            predictionCount: 3,
            hasReviewDate: true
        )
        XCTAssertEqual(score, 100)
    }

    // MARK: score(for:) convenience overload

    @MainActor
    func testScoreForDecisionCountsOnlyOptionsWithBothUpsideAndDownside() {
        let decision = Decision(title: "Move cities", notes: "Weighing a move for work reasons.")
        decision.options = [
            DecisionOption(title: "Move", upside: "New scenery", downside: "Leaving friends"),
            DecisionOption(title: "Stay", upside: "", downside: "Missed opportunity")
        ]
        decision.predictions = [
            Prediction(title: "I'll regret staying", probabilityPercent: 60)
        ]

        let score = ClarityScore.score(for: decision)
        // Title (20) + notes (15) + 2 options (18) + 1/2 tradeoffs (10) +
        // 1 prediction (8) + review date always true for existing decisions (5) = 76
        XCTAssertEqual(score, 76)
    }

    // MARK: Label buckets

    func testLabelBuckets() {
        XCTAssertEqual(ClarityScore.label(for: 0), "Sketchy")
        XCTAssertEqual(ClarityScore.label(for: 39), "Sketchy")
        XCTAssertEqual(ClarityScore.label(for: 40), "Decent")
        XCTAssertEqual(ClarityScore.label(for: 69), "Decent")
        XCTAssertEqual(ClarityScore.label(for: 70), "Thorough")
        XCTAssertEqual(ClarityScore.label(for: 89), "Thorough")
        XCTAssertEqual(ClarityScore.label(for: 90), "Crystal clear")
        XCTAssertEqual(ClarityScore.label(for: 100), "Crystal clear")
    }
}
