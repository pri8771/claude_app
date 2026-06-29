//
//  DecisionLogicTests.swift
//  HindsightTests
//
//  Unit tests for derived state on the Decision model and the export
//  encoder, covering the bugs fixed during the production-readiness pass.
//

import XCTest
@testable import Hindsight

final class DecisionLogicTests: XCTestCase {

    // MARK: Due-date predicates

    func testPastDueAndNeedsReviewAgree() {
        let past = Decision(status: .awaitingReview,
                            dueDate: Date().addingTimeInterval(-3600))
        XCTAssertTrue(past.isPastDue)
        XCTAssertTrue(past.needsReview)
        XCTAssertEqual(past.isPastDue, past.needsReview)

        let future = Decision(status: .awaitingReview,
                              dueDate: Date().addingTimeInterval(3600))
        XCTAssertFalse(future.isPastDue)
        XCTAssertFalse(future.needsReview)
    }

    func testReviewedIsNeverPastDue() {
        let reviewed = Decision(status: .reviewed,
                                dueDate: Date().addingTimeInterval(-3600))
        XCTAssertFalse(reviewed.isPastDue)
        XCTAssertFalse(reviewed.needsReview)
    }

    // MARK: Average confidence rounding

    func testAverageConfidenceRounds() {
        let d = Decision()
        d.predictions = [
            Prediction(probabilityPercent: 50),
            Prediction(probabilityPercent: 51)
        ]
        XCTAssertEqual(d.averageConfidence, 51)
    }

    func testAverageConfidenceEmptyIsZero() {
        XCTAssertEqual(Decision().averageConfidence, 0)
    }

    // MARK: Chosen option resolution

    func testChosenOptionResolvesByID() {
        let d = Decision()
        let a = DecisionOption(title: "Same")
        let b = DecisionOption(title: "Same") // duplicate title on purpose
        d.options = [a, b]
        d.chosenOptionID = b.id

        XCTAssertTrue(d.isChosen(b))
        XCTAssertFalse(d.isChosen(a))
        XCTAssertEqual(d.chosenOption?.id, b.id)
    }

    func testChosenOptionFallsBackToTitle() {
        let d = Decision()
        let a = DecisionOption(title: "Alpha")
        d.options = [a]
        d.chosenOptionTitle = "Alpha" // legacy record, no ID
        XCTAssertTrue(d.isChosen(a))
        XCTAssertEqual(d.chosenOptionDisplayTitle, "Alpha")
    }

    func testNoChosenOption() {
        let d = Decision()
        d.options = [DecisionOption(title: "Alpha")]
        XCTAssertNil(d.chosenOption)
        XCTAssertNil(d.chosenOptionDisplayTitle)
    }

    // MARK: Export

    func testJSONExportRoundTrips() throws {
        let d = Decision(title: "Move", status: .reviewed)
        d.options = [DecisionOption(title: "Stay")]
        d.predictions = [Prediction(title: "It works out", probabilityPercent: 70, status: .correct)]
        d.outcomeReview = OutcomeReview(whatHappened: "Went fine")

        let url = try ExportManager.exportJSON([d])
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(JournalExport.self, from: data)

        XCTAssertEqual(decoded.decisions.count, 1)
        XCTAssertEqual(decoded.decisions.first?.title, "Move")
        XCTAssertEqual(decoded.decisions.first?.predictions.first?.status, "Correct")
        XCTAssertEqual(decoded.decisions.first?.outcomeReview?.whatHappened, "Went fine")

        try? FileManager.default.removeItem(at: url)
    }
}
