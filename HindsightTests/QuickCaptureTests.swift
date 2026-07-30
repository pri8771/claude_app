import XCTest
@testable import Hindsight

@MainActor
final class QuickCaptureTests: XCTestCase {
    func testQuickCaptureRequiresNonBlankStatementAndSelectedDate() {
        let draft = QuickCaptureDraft()
        draft.statement = "   \n"
        draft.confidence = 75
        draft.selectedHorizon = .tomorrow

        XCTAssertFalse(draft.isStatementValid)
        XCTAssertNil(draft.makeDecision(now: Date(timeIntervalSince1970: 0)))
    }

    func testQuickCaptureRequiresExplicitConfidence() {
        let draft = QuickCaptureDraft()
        draft.statement = "This prediction has no assumed confidence"
        draft.selectedHorizon = .tomorrow

        XCTAssertNil(draft.confidence)
        XCTAssertNil(draft.makeDecision(now: Date(timeIntervalSince1970: 0)))
    }

    func testQuickCaptureBuildsOnePendingPredictionWithExplicitFields() throws {
        let now = Date(timeIntervalSince1970: 1_735_689_600) // 2025-01-01 12:00 UTC
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let draft = QuickCaptureDraft()
        draft.statement = "  The launch will be calm.  "
        draft.confidence = 75
        draft.selectedHorizon = .tomorrow

        let decision = try XCTUnwrap(draft.makeDecision(now: now, calendar: calendar))
        XCTAssertEqual(decision.title, "The launch will be calm.")
        XCTAssertEqual(decision.category, .personal)
        XCTAssertEqual(decision.stakesLevel, .low)
        XCTAssertTrue(decision.isReversible)
        XCTAssertEqual(decision.predictions.count, 1)
        XCTAssertEqual(decision.predictions[0].title, "The launch will be calm.")
        XCTAssertEqual(decision.predictions[0].probabilityPercent, 75)
        XCTAssertEqual(decision.predictions[0].status, .pending)
        XCTAssertEqual(decision.predictions[0].dueDate, decision.dueDate)
    }

    func testReviewHorizonsResolveToFutureDatesAtMonthAndWeekBoundaries() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2 // Monday
        let friday = Date(timeIntervalSince1970: 1_735_862_400) // 2025-01-03 12:00 UTC
        let monthEnd = Date(timeIntervalSince1970: 1_738_288_000) // 2025-01-31 14:00 UTC

        XCTAssertGreaterThan(QuickCaptureHorizon.thisWeek.date(from: friday, calendar: calendar), friday)
        XCTAssertGreaterThan(QuickCaptureHorizon.thisMonth.date(from: monthEnd, calendar: calendar), monthEnd)
        XCTAssertGreaterThan(QuickCaptureHorizon.sixMonths.date(from: monthEnd, calendar: calendar), monthEnd)
    }
}
