//
//  ClarityScoreTests.swift
//  HindsightTests
//
//  Unit tests for the clarity-score algorithm and its labels.
//

import XCTest
@testable import Hindsight

final class ClarityScoreTests: XCTestCase {

    func testEmptyDraftScoresLow() {
        let score = ClarityScore.score(
            title: "", notes: "", optionCount: 0,
            optionsWithTradeoffs: 0, predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(score, 0)
    }

    func testFullyDetailedDecisionScoresHigh() {
        let score = ClarityScore.score(
            title: "Take the offer",
            notes: "A reasonably long note describing the context.",
            optionCount: 3,
            optionsWithTradeoffs: 3,
            predictionCount: 3,
            hasReviewDate: true
        )
        XCTAssertEqual(score, 100)
    }

    func testShortNotesDoNotEarnNotesPoints() {
        // Notes shorter than 12 characters should not earn the 15-point block.
        let withShortNotes = ClarityScore.score(
            title: "X", notes: "short", optionCount: 0,
            optionsWithTradeoffs: 0, predictionCount: 0, hasReviewDate: false
        )
        XCTAssertEqual(withShortNotes, 20) // title only
    }

    func testPartialTradeoffsScaleLinearly() {
        // 1 of 2 options with trade-offs → half of the 20-point block (10).
        let score = ClarityScore.score(
            title: "", notes: "", optionCount: 2,
            optionsWithTradeoffs: 1, predictionCount: 0, hasReviewDate: false
        )
        // options(2)=18 + tradeoffs(0.5*20)=10 → 28
        XCTAssertEqual(score, 28)
    }

    func testLabelBoundaries() {
        XCTAssertEqual(ClarityScore.label(for: 0), "Sketchy")
        XCTAssertEqual(ClarityScore.label(for: 39), "Sketchy")
        XCTAssertEqual(ClarityScore.label(for: 40), "Decent")
        XCTAssertEqual(ClarityScore.label(for: 69), "Decent")
        XCTAssertEqual(ClarityScore.label(for: 70), "Thorough")
        XCTAssertEqual(ClarityScore.label(for: 89), "Thorough")
        XCTAssertEqual(ClarityScore.label(for: 90), "Crystal clear")
        XCTAssertEqual(ClarityScore.label(for: 100), "Crystal clear")
    }

    func testScoreNeverExceeds100() {
        let score = ClarityScore.score(
            title: "T", notes: String(repeating: "a", count: 200),
            optionCount: 10, optionsWithTradeoffs: 10,
            predictionCount: 10, hasReviewDate: true
        )
        XCTAssertLessThanOrEqual(score, 100)
    }
}
