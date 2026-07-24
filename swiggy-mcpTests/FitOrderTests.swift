import XCTest
@testable import swiggy_mcp

final class FitOrderTests: XCTestCase {
    func testGoldenPromptExtractionIsDeterministic() throws {
        let intent = try DeterministicFuelPlanner().parse(
            DeterministicFuelPlanner.goldenPrompt
        )

        XCTAssertEqual(intent.event, "HYROX")
        XCTAssertEqual(intent.eventTimelineDays, 9)
        XCTAssertEqual(intent.diet, "Vegetarian")
        XCTAssertEqual(intent.mealPurpose, "Recovery")
        XCTAssertEqual(intent.requestedMealTime, "Tonight")
        XCTAssertEqual(intent.refillDays, 5)
        XCTAssertEqual(intent.budgetRupees, 900)
    }

    func testUnsupportedPromptExplainsMissingConstraints() {
        XCTAssertThrowsError(
            try DeterministicFuelPlanner().parse("Find me dinner")
        ) { error in
            guard case FuelPlannerError.unsupportedPrompt(let missing) = error else {
                return XCTFail("Expected the deterministic unsupported-prompt error")
            }
            XCTAssertTrue(missing.contains("an event"))
            XCTAssertTrue(missing.contains("a budget"))
        }
    }

    @MainActor
    func testGoldenPathBudgetToolOrderAndConfirmationGate() async {
        let session = DemoSession()
        await session.setDebugScenario(.goldenPath)
        await session.planFuel()

        XCTAssertEqual(session.phase, .planReady)
        XCTAssertEqual(session.foodCart?.total, 343)
        XCTAssertEqual(session.foodCart?.taxes, 14)
        XCTAssertEqual(session.foodCart?.address.line2, "Indiranagar")
        XCTAssertEqual(session.instamartCart?.total, 396)
        XCTAssertFalse(session.canReview)
        XCTAssertFalse(session.canConfirm)
        XCTAssertNil(session.foodOrder)
        XCTAssertNil(session.instamartOrder)

        await session.acceptProposedSubstitution()

        XCTAssertTrue(session.hasAcceptedSubstitution)
        XCTAssertEqual(session.instamartCart?.total, 485)
        XCTAssertEqual(session.combinedTotal, 828)
        XCTAssertEqual(session.remainingBudget, 72)
        XCTAssertTrue(session.isWithinBudget)
        XCTAssertTrue(session.canReview)
        XCTAssertFalse(session.canConfirm)

        let foodCalls = session.toolTrace
            .filter { $0.server == .food }
            .map(\.toolName)
        XCTAssertEqual(
            Array(foodCalls.prefix(7)),
            [
                "get_addresses",
                "search_menu",
                "get_restaurant_menu",
                "update_food_cart",
                "fetch_food_coupons",
                "apply_food_coupon",
                "get_food_cart"
            ]
        )

        let instamartCalls = session.toolTrace
            .filter { $0.server == .instamart }
            .map(\.toolName)
        XCTAssertEqual(
            Array(instamartCalls.prefix(4)),
            [
                "your_go_to_items",
                "search_products",
                "update_cart",
                "get_cart"
            ]
        )

        await session.beginReview()

        XCTAssertEqual(session.phase, .reviewing)
        XCTAssertTrue(session.cartsAreAuthoritative)
        XCTAssertTrue(session.canConfirm)
        XCTAssertTrue(session.canReview)
        XCTAssertNil(session.foodOrder)
        XCTAssertNil(session.instamartOrder)

        let traceCountBeforeReopening = session.toolTrace.count
        await session.beginReview()
        XCTAssertEqual(session.toolTrace.count, traceCountBeforeReopening)

        await session.confirmOrders()

        XCTAssertEqual(session.phase, .tracking)
        XCTAssertNotNil(session.foodOrder)
        XCTAssertNotNil(session.instamartOrder)
        XCTAssertTrue(session.hasBothTrackingSnapshots)
        XCTAssertEqual(session.foodOrder?.total, 343)
        XCTAssertEqual(session.instamartOrder?.total, 485)
    }

    @MainActor
    func testUnavailableScenarioIsPolishedAndRetryable() async {
        let session = DemoSession()
        await session.setDebugScenario(.serverUnavailable)
        await session.planFuel()

        XCTAssertEqual(session.phase, .failed)
        XCTAssertTrue(session.failure?.isRetryable == true)
        XCTAssertTrue(
            session.failure?.message.contains("demo service is unavailable") == true
        )
        XCTAssertFalse(session.failure?.message.contains("jsonrpc") == true)
    }

    @MainActor
    func testCartChangeRequiresFreshConsent() async {
        let session = DemoSession()
        await session.setDebugScenario(.cartChanged)
        await session.planFuel()
        await session.acceptProposedSubstitution()
        await session.beginReview()

        XCTAssertEqual(session.phase, .reviewing)
        XCTAssertFalse(session.canConfirm)
        XCTAssertTrue(session.requiresCartReconfirmation)
        XCTAssertEqual(session.cartChanges.count, 2)
        XCTAssertEqual(session.combinedTotal, 848)

        session.acceptRefreshedCartChanges()

        XCTAssertTrue(session.hasAcceptedCartChanges)
        XCTAssertTrue(session.canConfirm)
    }

    @MainActor
    func testAmbiguousPlacementRecoversWithoutDuplicateOrders() async {
        let session = DemoSession()
        await session.setDebugScenario(.ambiguousCheckout)
        await session.planFuel()
        await session.acceptProposedSubstitution()
        await session.beginReview()
        await session.confirmOrders()

        XCTAssertEqual(session.phase, .tracking)
        XCTAssertNotNil(session.foodOrder)
        XCTAssertNotNil(session.instamartOrder)
        XCTAssertEqual(
            session.toolTrace.filter { $0.toolName == "get_food_order_history" }.count,
            1
        )
        XCTAssertEqual(
            session.toolTrace.filter { $0.toolName == "get_order_history" }.count,
            1
        )
        XCTAssertEqual(
            session.toolTrace.filter { $0.toolName == "place_food_order" }.count,
            1
        )
        XCTAssertEqual(
            session.toolTrace.filter { $0.toolName == "checkout" }.count,
            1
        )
    }
}
