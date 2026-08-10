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

    private func launchFileBackedApp(reset: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [reset ? "-uiTestFileBackedReset" : "-uiTestFileBacked"]
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

        let scrollView = app.scrollViews.firstMatch
        for attempt in 0..<5 {
            if element.isHittable {
                element.tap()
                if app.keyboards.firstMatch.waitForExistence(timeout: 2) {
                    element.typeText(text)
                    return
                }
            }

            if attempt < 4, scrollView.exists {
                scrollView.swipeUp()
            }
        }

        XCTFail("Expected the keyboard to appear before entering text", file: file, line: line)
    }

    private func scrollUntilHittable(
        _ element: XCUIElement,
        in scrollView: XCUIElement,
        maximumSwipes: Int = 8,
        topClearance: CGFloat = 100,
        bottomClearance: CGFloat = 260,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for attempt in 0...maximumSwipes {
            // The accessibility-size bottom CTA is substantially taller than
            // its standard-size counterpart. SwiftUI keeps content underneath
            // that safe-area inset in the ScrollView hierarchy, and XCTest can
            // report an underneath element as hittable even though the CTA wins
            // the synthesized gesture. Require a conservative unobscured band.
            let viewport = scrollView.frame
            let safeMinY = viewport.minY + topClearance
            let safeMaxY = viewport.maxY - bottomClearance
            let elementFrame = element.frame
            let isInSafeInteractionBand = elementFrame.minY >= safeMinY &&
                elementFrame.maxY <= safeMaxY
            if element.exists, element.isHittable, isInSafeInteractionBand { return }
            guard attempt < maximumSwipes else { break }

            let shouldMoveContentDown = elementFrame.minY < safeMinY
            let start = scrollView.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: shouldMoveContentDown ? 0.30 : 0.70)
            )
            let end = scrollView.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: shouldMoveContentDown ? 0.60 : 0.40)
            )
            start.press(forDuration: 0.01, thenDragTo: end)
        }
        XCTFail("Expected \(element) to become hittable after scrolling", file: file, line: line)
    }

    private func chooseConfidence(
        _ slider: XCUIElement,
        preferredPosition: CGFloat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let selected = NSPredicate(format: "value != %@", "Not selected")
        let candidates = [preferredPosition, 0.65, 0.85]
        for position in candidates {
            // `adjust(toNormalizedSliderPosition:)` derives its gesture from the
            // accessibility value. Before an intentional choice this slider
            // truthfully reports "Not selected", so that XCTest convenience API
            // can synthesize a no-op at very large Dynamic Type. Drag the visible
            // neutral thumb instead; this is the same interaction a person makes
            // and exercises the production binding without a test-only seam.
            let restingThumb = slider.coordinate(
                withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)
            )
            let destination = slider.coordinate(
                withNormalizedOffset: CGVector(dx: position, dy: 0.5)
            )
            restingThumb.press(forDuration: 0.1, thenDragTo: destination)
            let expectation = XCTNSPredicateExpectation(predicate: selected, object: slider)
            if XCTWaiter.wait(for: [expectation], timeout: 2) == .completed { return }
        }
        XCTFail("Expected an explicit confidence after dragging the slider", file: file, line: line)
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

        let confidenceSlider = app.sliders["quickCapture.confidenceSlider"]
        XCTAssertTrue(confidenceSlider.waitForExistence(timeout: 5))
        chooseConfidence(confidenceSlider, preferredPosition: 0.75)

        let tomorrowButton = app.buttons["Tomorrow"]
        let captureScrollView = app.scrollViews["quickCapture.scroll"]
        XCTAssertTrue(captureScrollView.waitForExistence(timeout: 5))
        select(tomorrowButton, in: captureScrollView)

        let saveButton = app.buttons["Save Prediction"]
        XCTAssertTrue(waitForEnabled(saveButton),
                      "Save should become enabled after statement, confidence, and horizon are selected")
        saveButton.tap()

        XCTAssertTrue(app.staticTexts[statement].waitForExistence(timeout: 5),
                      "The saved prediction should appear on Today")
    }

    func testLockedForecastSurvivesTerminationAndRelaunch() throws {
        let statement = "UI test: this forecast survives a relaunch"
        var app = launchFileBackedApp(reset: true)

        let quickCaptureButton = app.buttons["Quick Capture"].firstMatch
        XCTAssertTrue(quickCaptureButton.waitForExistence(timeout: 10))
        quickCaptureButton.tap()

        let statementField = app.textFields["Quick capture statement"]
        XCTAssertTrue(statementField.waitForExistence(timeout: 5))
        statementField.tap()
        statementField.typeText(statement)
        app.buttons["quickCapture.keyboardDone"].tap()

        let captureScrollView = app.scrollViews["quickCapture.scroll"]
        let confidenceSlider = app.sliders["quickCapture.confidenceSlider"]
        XCTAssertTrue(confidenceSlider.waitForExistence(timeout: 5))
        chooseConfidence(confidenceSlider, preferredPosition: 0.64)
        select(app.buttons["Tomorrow"], in: captureScrollView)

        let saveButton = app.buttons["Save Prediction"]
        XCTAssertTrue(waitForEnabled(saveButton))
        saveButton.tap()
        XCTAssertTrue(app.staticTexts[statement].waitForExistence(timeout: 5))

        app.terminate()
        app = launchFileBackedApp(reset: false)
        XCTAssertTrue(app.staticTexts[statement].waitForExistence(timeout: 10),
                      "A locked forecast must survive a real file-backed process relaunch")
    }

    func testAdultPersonalShellCenterCaptureAndSettings() throws {
        let app = launchApp()

        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Capture"].exists)
        XCTAssertTrue(app.tabBars.buttons["Insights"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)

        app.tabBars.buttons["Capture"].tap()
        XCTAssertTrue(app.textFields["Quick capture statement"].waitForExistence(timeout: 5),
                      "The center Capture action should open the one-screen forecast composer")
        app.buttons["Cancel"].tap()

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.tabBars.buttons["Circles"].exists,
                       "Unreleased social functionality must not appear as a production destination")
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

        let captureScrollView = app.scrollViews["quickCapture.scroll"]
        XCTAssertTrue(captureScrollView.waitForExistence(timeout: 5))

        let confidenceSlider = app.sliders["quickCapture.confidenceSlider"]
        XCTAssertTrue(confidenceSlider.waitForExistence(timeout: 5))
        scrollUntilHittable(confidenceSlider, in: captureScrollView)
        chooseConfidence(confidenceSlider, preferredPosition: 0.75)

        let tomorrowButton = app.buttons["Tomorrow"]
        scrollUntilHittable(tomorrowButton, in: captureScrollView)
        select(tomorrowButton, in: captureScrollView)

        let saveButton = app.buttons["Save Prediction"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isHittable)
        XCTAssertTrue(waitForEnabled(saveButton))
        saveButton.tap()
        XCTAssertTrue(app.staticTexts["UI test: large text remains usable"].waitForExistence(timeout: 5))
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
        let firstOptionKeyboardDone = app.buttons["newDecision.option.title.0.keyboardDone"]
        XCTAssertTrue(firstOptionKeyboardDone.waitForExistence(timeout: 5))
        firstOptionKeyboardDone.tap()
        enterText("Keep the current schedule", into: option1, in: app)
        let secondOptionKeyboardDone = app.buttons["newDecision.option.title.1.keyboardDone"]
        XCTAssertTrue(secondOptionKeyboardDone.waitForExistence(timeout: 5))
        secondOptionKeyboardDone.tap()

        app.buttons["Next"].tap()

        // MARK: Step 3 — Predictions (one is pre-added)
        let predictionField = app.textViews["newDecision.prediction.statement.0"]
        enterText("I'll still feel just as productive", into: predictionField, in: app)
        let predictionKeyboardDone = app.buttons["newDecision.prediction.statement.0.keyboardDone"]
        XCTAssertTrue(predictionKeyboardDone.waitForExistence(timeout: 5))
        predictionKeyboardDone.tap()

        let predictionConfidence = app.sliders["newDecision.prediction.confidence.0"]
        XCTAssertTrue(predictionConfidence.waitForExistence(timeout: 5))
        XCTAssertEqual(predictionConfidence.value as? String, "Not selected")
        chooseConfidence(predictionConfidence, preferredPosition: 0.63)

        XCTAssertTrue(waitForEnabled(app.buttons["Next"]))
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
        let reviewKeyboardDone = app.buttons["outcomeReview.whatHappened.keyboardDone"]
        XCTAssertTrue(reviewKeyboardDone.waitForExistence(timeout: 5))
        reviewKeyboardDone.tap()

        let happenedButton = app.buttons["Happened"]
        XCTAssertTrue(happenedButton.waitForExistence(timeout: 5))
        happenedButton.tap()
        app.buttons["Save review"].tap()

        // MARK: Back on decision detail — the review should now be recorded.
        let reviewedTimestamp = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH 'Reviewed '")
        ).firstMatch
        XCTAssertTrue(reviewedTimestamp.waitForExistence(timeout: 5),
                      "The outcome summary card should show a 'Reviewed <date>' timestamp once saved")
    }

    func testDetailedWizardDismissesKeyboardBetweenStepsAtLargestAccessibilityTextSize() throws {
        let app = launchApp(additionalArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL"
        ])

        let addDetailButton = app.buttons["Add detail"].firstMatch
        XCTAssertTrue(addDetailButton.waitForExistence(timeout: 10))
        addDetailButton.tap()

        let titleField = app.textFields["newDecision.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        titleField.typeText("UI test: accessible detailed decision")

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(waitForEnabled(nextButton))
        nextButton.tap()
        XCTAssertTrue(
            app.keyboards.firstMatch.waitForNonExistence(timeout: 5),
            "Advancing the wizard must dismiss the prior page's keyboard"
        )

        let optionsScroll = app.scrollViews["newDecision.options.scroll"]
        XCTAssertTrue(optionsScroll.waitForExistence(timeout: 5))
        let firstOption = app.textFields["newDecision.option.title.0"]
        XCTAssertTrue(firstOption.waitForExistence(timeout: 5))
        scrollUntilHittable(
            firstOption,
            in: optionsScroll,
            topClearance: 24,
            bottomClearance: 24
        )
        firstOption.tap()
        XCTAssertTrue(
            app.keyboards.firstMatch.waitForExistence(timeout: 5),
            "The first option must remain reachable after the accessibility-size transition"
        )
    }
}
