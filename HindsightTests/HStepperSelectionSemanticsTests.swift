import XCTest
@testable import Hindsight

final class HStepperSelectionSemanticsTests: XCTestCase {
    func testExactlyOneScaleValueIsSemanticallySelected() {
        let range = 1...5

        for currentValue in range {
            let selected = range.filter {
                HStepperSelectionSemantics.isSelected($0, currentValue: currentValue)
            }

            XCTAssertEqual(selected, [currentValue])
        }
    }

    func testAdjustmentClampsAtBothScaleBoundaries() {
        let range = 1...5

        XCTAssertEqual(
            HStepperSelectionSemantics.adjustedValue(currentValue: 1, delta: -1, range: range),
            1
        )
        XCTAssertEqual(
            HStepperSelectionSemantics.adjustedValue(currentValue: 5, delta: 1, range: range),
            5
        )
        XCTAssertEqual(
            HStepperSelectionSemantics.adjustedValue(currentValue: 3, delta: 1, range: range),
            4
        )
    }

    func testAccessibilityValueDescribesCurrentSelectionAndScale() {
        XCTAssertEqual(
            HStepperSelectionSemantics.accessibilityValue(currentValue: 3, range: 1...5),
            "3 out of 5"
        )
        XCTAssertEqual(
            HStepperSelectionSemantics.accessibilityValue(currentValue: 20, range: 10...30),
            "20, range 10 to 30"
        )
    }
}
