import XCTest

final class FitOrderUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGoldenPathFromResetThroughDualTracking() throws {
        let app = XCUIApplication()
        app.launch()

        let planButton = app.buttons["Plan my fuel"]
        XCTAssertTrue(planButton.waitForExistence(timeout: 8))
        planButton.tap()

        let swapPrompt = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "One smart swap needs approval")
        ).firstMatch
        XCTAssertTrue(swapPrompt.waitForExistence(timeout: 20))
        swapPrompt.tap()

        let acceptSwap = app.buttons["Accept high-protein curd"]
        XCTAssertTrue(acceptSwap.waitForExistence(timeout: 8))
        acceptSwap.tap()

        let review = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Review 2 carts")
        ).firstMatch
        XCTAssertTrue(review.waitForExistence(timeout: 12))
        review.tap()

        let confirm = app.buttons["Confirm two demo orders"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 12))
        XCTAssertTrue(confirm.isEnabled)
        let sliderStart = confirm.coordinate(
            withNormalizedOffset: CGVector(dx: 0.08, dy: 0.5)
        )
        let sliderEnd = confirm.coordinate(
            withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)
        )
        sliderStart.press(forDuration: 0.12, thenDragTo: sliderEnd)

        XCTAssertTrue(
            app.staticTexts["118/130g"].waitForExistence(timeout: 20)
        )
        XCTAssertTrue(
            app.staticTexts["Two demo orders confirmed independently."]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.staticTexts["Swiggy Food"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Instamart"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCinematicDemoTake() throws {
        let app = XCUIApplication()
        app.launch()

        let planButton = app.buttons["Plan my fuel"]
        XCTAssertTrue(planButton.waitForExistence(timeout: 8))
        pause(4)
        planButton.tap()

        let planTitle = app.staticTexts["Recovery now. Breakfast handled."]
        XCTAssertTrue(planTitle.waitForExistence(timeout: 20))
        pause(5)

        let swapPrompt = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "One smart swap needs approval")
        ).firstMatch
        XCTAssertTrue(swapPrompt.waitForExistence(timeout: 5))
        swapPrompt.tap()

        let acceptSwap = app.buttons["Accept high-protein curd"]
        XCTAssertTrue(acceptSwap.waitForExistence(timeout: 8))
        pause(5)
        acceptSwap.tap()

        let review = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Review 2 carts")
        ).firstMatch
        XCTAssertTrue(review.waitForExistence(timeout: 12))
        pause(4)
        app.swipeUp()
        pause(5)
        app.swipeUp()
        pause(5)
        review.tap()

        let combinedTotal = app.staticTexts["₹828"]
        XCTAssertTrue(combinedTotal.waitForExistence(timeout: 12))
        pause(5)
        app.swipeUp()
        pause(5)

        let receipt = app.buttons["How FitOrder prepared this"].firstMatch
        XCTAssertTrue(receipt.waitForExistence(timeout: 5))
        receipt.tap()
        XCTAssertTrue(app.navigationBars["MCP receipt"].waitForExistence(timeout: 5))
        pause(5)
        app.swipeUp()
        pause(5)
        app.buttons["Done"].tap()

        let confirm = app.buttons["Confirm two demo orders"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 8))
        pause(3)
        let sliderStart = confirm.coordinate(
            withNormalizedOffset: CGVector(dx: 0.08, dy: 0.5)
        )
        let sliderEnd = confirm.coordinate(
            withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)
        )
        sliderStart.press(forDuration: 0.12, thenDragTo: sliderEnd)

        XCTAssertTrue(app.staticTexts["118/130g"].waitForExistence(timeout: 20))
        pause(7)
        app.swipeUp()
        pause(8)
        app.swipeUp()
        pause(8)

        XCTAssertTrue(
            app.staticTexts["A repeatable performance-commerce loop."]
                .waitForExistence(timeout: 5)
        )
    }

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
}
