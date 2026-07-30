//
//  HindsightCaptureFlowUITests.swift
//  HindsightUITests
//
//  End-to-end smoke coverage for the primary Quick Capture path and the
//  retained detailed-decision path.
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

    private func launchApp(additionalArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"] + additionalArguments
        app.launch()
        return app
    }

    private func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "enabled == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func select(
        _ element: XCUIElement,
        in scrollView: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let selected = NSPredicate(format: "value == %@", "Selected")

        for attempt in 0..<4 {
            if element.waitForExistence(timeout: 5), element.isHittable {
                element.tap()
                let selectionExpectation = XCTNSPredicateExpectation(
                    predicate: selected,
                    object: element
                )
                if XCTWaiter.wait(for: [selectionExpectation], timeout: 2) == .completed {
                    return
                }
            }

            if attempt < 3 {
                scrollView.swipeUp()
            }
        }

        XCTFail("Expected \(element) to become selected after scrolling into view", file: file, line: line)
    }

    private func enterText(
        _ text: String,
        into element: XCUIElement,
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard element.waitForExistence(timeout: 5) else {
            XCTFail("Expected text input to exist before entering text", file: file, line: line)
            return
        }

        element.tap()
        guard app.keyboards.firstMatch.waitForExistence(timeout: 5) else {
            XCTFail("Expected the keyboard to appear before entering text", file: file, line: line)
            return
        }
        element.typeText(text)
    }

    func testQuickCaptureCreatesOneVisiblePrediction() throws {
        let app = launchApp()
        let statement = "UI test: the launch will stay on schedule"

        let quickCaptureButton = app.buttons["Quick Capture"].firstMatch
        XCTAssertTrue(quickCaptureButton.waitForExistence(timeout: 10),
                      "Today's primary Quick Capture action should appear after launch")
        quickCaptureButton.tap()

        let statementField = app.textFields["Quick capture statement"]
        XCTAssertTrue(statementField.waitForExistence(timeout: 5))
        statementField.tap()
        statementField.typeText(statement)

        let keyboardDoneButton = app.buttons["quickCapture.keyboardDone"]
        XCTAssertTrue(keyboardDoneButton.waitForExistence(timeout: 5))
        keyboardDoneButton.tap()

        let confidenceButton = app.buttons["quickCapture.confidence.75"]
        XCTAssertTrue(confidenceButton.waitForExistence(timeout: 5))
        confidenceButton.tap()

        let tomorrowButton = app.buttons["Tomorrow"]
        XCTAssertTrue(tomorrowButton.waitForExistence(timeout: 5))
        tomorrowButton.tap()

        let saveButton = app.buttons["Save Prediction"]
        XCTAssertTrue(waitForEnabled(saveButton),
                      "Save should become enabled after statement, confidence, and horizon are selected")
        saveButton.tap()

        XCTAssertTrue(app.staticTexts[statement].waitForExistence(timeout: 5),
                      "The saved prediction should appear on Today")
    }

    func testQuickCaptureCompletesAtLargestAccessibilityTextSize() throws {
        let app = launchApp(additionalArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL"
        ])

        let quickCaptureButton = app.buttons["Quick Capture"].firstMatch
        XCTAssertTrue(quickCaptureButton.waitForExistence(timeout: 10))
        quickCaptureButton.tap()

        let statementField = app.textFields["Quick capture statement"]
        XCTAssertTrue(statementField.waitForExistence(timeout: 5))
        statementField.tap()
        statementField.typeText("UI test: large text remains usable")

        let keyboardDoneButton = app.buttons["quickCapture.keyboardDone"]
        XCTAssertTrue(keyboardDoneButton.waitForExistence(timeout: 5))
        keyboardDoneButton.tap()

        let captureScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(captureScrollView.waitForExistence(timeout: 5))

        let confidenceButton = app.buttons["quickCapture.confidence.75"]
        select(confidenceButton, in: captureScrollView)

        let tomorrowButton = app.buttons["Tomorrow"]
        select(tomorrowButton, in: captureScrollView)

        let saveButton = app.buttons["Save Prediction"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isHittable)
        XCTAssertTrue(waitForEnabled(saveButton))
    }

    func testDetailedDecisionFlowRemainsAvailable() throws {
        let app = launchApp()

        let decisionTitle = "UI test: switch to a 4-day week"

        // MARK: Launch past the splash screen to Today's empty state.
        let addDetailButton = app.buttons["Add detail"].firstMatch
        XCTAssertTrue(addDetailButton.waitForExistence(timeout: 10),
                      "The detailed wizard should remain available as a secondary action")
        addDetailButton.tap()

        // MARK: Step 1 — Basics
        let titleField = app.textFields["newDecision.title"]
        enterText(decisionTitle, into: titleField, in: app)

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(
            waitForEnabled(nextButton),
            "Next should be enabled once the title is non-empty"
        )
        nextButton.tap()

        // MARK: Step 2 — Options (two are pre-added; both need a title)
        let option0 = app.textFields["newDecision.option.title.0"]
        let option1 = app.textFields["newDecision.option.title.1"]
        enterText("Negotiate a 4-day week", into: option0, in: app)
        enterText("Keep the current schedule", into: option1, in: app)

        app.buttons["Next"].tap()

        // MARK: Step 3 — Predictions (one is pre-added)
        let predictionField = app.textViews["newDecision.prediction.statement.0"]
        enterText("I'll still feel just as productive", into: predictionField, in: app)

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
        enterText("Negotiated it, energy levels went up.", into: whatHappenedField, in: app)

        app.buttons["Save Review"].tap()

        // MARK: Back on decision detail — the review should now be recorded.
        let reviewedTimestamp = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH 'Reviewed '")
        ).firstMatch
        XCTAssertTrue(reviewedTimestamp.waitForExistence(timeout: 5),
                      "The outcome summary card should show a 'Reviewed <date>' timestamp once saved")
    }
}
