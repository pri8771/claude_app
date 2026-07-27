//
//  HindsightCaptureFlowUITests.swift
//  HindsightUITests
//
//  A basic end-to-end smoke test for the actual capture flow: launch a
//  freshly reset app, create a new decision through all four wizard steps,
//  save it, then open its outcome review ("review later") and save that too.
//
//  The app is launched with "-uiTestReset", which HindsightApp.swift uses to
//  swap in an in-memory SwiftData store, pre-complete onboarding, and turn
//  off review reminders (so a system notification-permission alert can never
//  interrupt the run). This keeps the test fully isolated from any real
//  on-disk data and fully deterministic.
//

import XCTest

final class HindsightCaptureFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()
        return app
    }

    func testCaptureNewDecisionThenReviewIt() throws {
        let app = launchApp()

        let decisionTitle = "UI test: switch to a 4-day week"

        // MARK: Launch past the splash screen to Today's empty state.
        let newDecisionButton = app.buttons["New Decision"]
        XCTAssertTrue(newDecisionButton.waitForExistence(timeout: 10),
                      "Today's empty-state 'New Decision' button should appear once the splash screen dismisses")
        newDecisionButton.tap()

        // MARK: Step 1 — Basics
        let titleField = app.textFields["newDecision.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(decisionTitle)

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.isEnabled, "Next should be enabled once the title is non-empty")
        nextButton.tap()

        // MARK: Step 2 — Options (two are pre-added; both need a title)
        let option0 = app.textFields["newDecision.option.title.0"]
        let option1 = app.textFields["newDecision.option.title.1"]
        XCTAssertTrue(option0.waitForExistence(timeout: 5))
        option0.tap()
        option0.typeText("Negotiate a 4-day week")
        option1.tap()
        option1.typeText("Keep the current schedule")

        app.buttons["Next"].tap()

        // MARK: Step 3 — Predictions (one is pre-added)
        let predictionField = app.textViews["newDecision.prediction.statement.0"]
        XCTAssertTrue(predictionField.waitForExistence(timeout: 5))
        predictionField.tap()
        predictionField.typeText("I'll still feel just as productive")

        app.buttons["Next"].tap()

        // MARK: Step 4 — Review date + save
        let saveButton = app.buttons["Save Decision"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // MARK: Back on Today — the new decision should now be visible.
        let decisionText = app.staticTexts[decisionTitle]
        XCTAssertTrue(decisionText.waitForExistence(timeout: 5),
                      "The saved decision should appear in Today's list")
        decisionText.tap()

        // MARK: Decision detail — trigger "review later" via "Review early".
        let reviewEarlyButton = app.buttons["Review early"]
        XCTAssertTrue(reviewEarlyButton.waitForExistence(timeout: 5))
        reviewEarlyButton.tap()

        // MARK: Outcome review — fill the one required field and save.
        let whatHappenedField = app.textViews["outcomeReview.whatHappened"]
        XCTAssertTrue(whatHappenedField.waitForExistence(timeout: 5))
        whatHappenedField.tap()
        whatHappenedField.typeText("Negotiated it, energy levels went up.")

        app.buttons["Save Review"].tap()

        // MARK: Back on decision detail — the review should now be recorded.
        let reviewedTimestamp = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH 'Reviewed '")
        ).firstMatch
        XCTAssertTrue(reviewedTimestamp.waitForExistence(timeout: 5),
                      "The outcome summary card should show a 'Reviewed <date>' timestamp once saved")
    }
}
