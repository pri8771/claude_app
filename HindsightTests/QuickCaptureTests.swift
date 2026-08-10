import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class QuickCaptureTests: XCTestCase {
    func testDetailedPredictionHasNoImplicitConfidenceAndBlocksProgressUntilSelected() throws {
        let draft = DecisionDraft()
        let prediction = try XCTUnwrap(draft.predictions.first)

        XCTAssertNil(prediction.probability)
        XCTAssertFalse(draft.step3Valid)

        prediction.statement = "The detailed forecast will remain falsifiable"
        XCTAssertFalse(draft.step3Valid, "Text alone must not manufacture 50% confidence")

        prediction.probability = 0
        XCTAssertTrue(draft.step3Valid, "Zero is an intentional, valid confidence value")
        XCTAssertEqual(draft.makeDecision().predictions.first?.probabilityPercent, 0)
    }

    func testDetailedPredictionPersistsExactConfidenceBoundaries() throws {
        for confidence in [0, 1, 50, 99, 100] {
            let draft = DecisionDraft()
            let prediction = try XCTUnwrap(draft.predictions.first)
            prediction.statement = "Boundary \(confidence)"
            prediction.probability = confidence

            XCTAssertTrue(draft.step3Valid)
            XCTAssertEqual(draft.makeDecision().predictions.first?.probabilityPercent, confidence)
        }
    }

    func testDetailedPredictionDoesNotSilentlyDropAPartiallyEnteredCard() throws {
        let draft = DecisionDraft()
        let complete = try XCTUnwrap(draft.predictions.first)
        complete.statement = "Complete forecast"
        complete.probability = 75
        draft.predictions.append(PredictionDraft())
        draft.predictions[1].statement = "Missing an intentional confidence"

        XCTAssertEqual(draft.validPredictions.count, 1)
        XCTAssertFalse(draft.step3Valid)
    }

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

    func testQuickCaptureAcceptsFullConfidenceRangeWithoutInferringAValue() throws {
        let now = Date(timeIntervalSince1970: 1_735_689_600)
        let calendar = Calendar(identifier: .gregorian)

        for confidence in [0, 50, 100] {
            let draft = QuickCaptureDraft(snapshot: nil)
            draft.statement = "A range test"
            draft.confidence = confidence
            draft.selectedHorizon = .tomorrow

            let decision = try XCTUnwrap(draft.makeDecision(now: now, calendar: calendar))
            XCTAssertEqual(decision.predictions.first?.probabilityPercent, confidence)
        }
    }

    func testQuickCaptureStoresOptionalReasoningWithoutChangingItsClassification() throws {
        let draft = QuickCaptureDraft(snapshot: nil)
        draft.statement = "The launch will be calm"
        draft.reasoning = "  The checklist is complete.  "
        draft.confidence = 50
        draft.selectedHorizon = .tomorrow

        let decision = try XCTUnwrap(draft.makeDecision(now: Date(timeIntervalSince1970: 0)))
        XCTAssertEqual(decision.notes, "The checklist is complete.")
        XCTAssertTrue(decision.isQuickCapture)
    }

    func testQuickCaptureDraftRoundTripPreservesAllUserOwnedFields() throws {
        let suiteName = "QuickCaptureTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let customDate = Date(timeIntervalSince1970: 1_735_776_000)
        let snapshot = QuickCaptureDraftSnapshot(
            statement: "Will the plan hold?",
            reasoning: "The team has slack.",
            confidence: 0,
            horizon: QuickCaptureHorizon.custom.rawValue,
            customDate: customDate
        )
        QuickCaptureDraftStore.save(snapshot, defaults: defaults)

        let restored = try XCTUnwrap(QuickCaptureDraftStore.load(defaults: defaults))
        XCTAssertEqual(restored, snapshot)
        let draft = QuickCaptureDraft(snapshot: restored)
        XCTAssertEqual(draft.statement, snapshot.statement)
        XCTAssertEqual(draft.reasoning, snapshot.reasoning)
        XCTAssertEqual(draft.confidence, 0)
        XCTAssertEqual(draft.selectedHorizon, .custom)
        XCTAssertEqual(draft.customDate, customDate)

        QuickCaptureDraftStore.clear(defaults: defaults)
        XCTAssertNil(QuickCaptureDraftStore.load(defaults: defaults))
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

    func testCaptureFailureKeepsDurableDraftAndLeavesNoUnsavedPostcardToDuplicate() throws {
        let suiteName = "QuickCaptureTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            PersistenceService.shared = ContextPersister()
        }

        let now = Date(timeIntervalSince1970: 1_735_689_600)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let draft = QuickCaptureDraft()
        draft.statement = "The release will be calm"
        draft.reasoning = "The checklist is complete"
        draft.confidence = 75
        draft.selectedHorizon = .tomorrow
        let snapshot = draft.snapshot
        QuickCaptureDraftStore.save(snapshot, defaults: defaults)

        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Decision.self, Prediction.self, DecisionOption.self, OutcomeReview.self,
            configurations: configuration
        )
        let context = container.mainContext
        let postcard = try XCTUnwrap(draft.makeDecision(now: now, calendar: calendar))
        PersistenceService.shared = QuickCaptureFailingPersister()
        context.insert(postcard)

        XCTAssertFalse(PersistenceService.saveOrReport(context))
        // Mirrors the capture boundary's removal of an uncommitted graph.
        context.delete(postcard)

        XCTAssertEqual(QuickCaptureDraftStore.load(defaults: defaults), snapshot)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
    }
}

private struct QuickCaptureFailingPersister: Persisting {
    func save(_ context: ModelContext) throws {
        throw NSError(domain: "QuickCaptureTests", code: 1)
    }
}
