import Foundation

struct FitnessPreferences: Hashable {
    var goal: String
    var diet: String
    var cuisine: String
    var budget: String
    var proteinTarget: String
    var calories: String
}

struct MealRecommendation: Identifiable, Hashable {
    let id: String
    let name: String
    let restaurant: String
    let price: Int
    let deliveryMinutes: Int
    let rating: Double
    let protein: Int
    let calories: Int
    let carbs: Int
    let fat: Int
    let tags: [String]
    let why: String
    let mcpFlow: [String]
}

struct CartAddon: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
    let protein: Int
    let calories: Int
    let carbs: Int
    let fat: Int
}

struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
}

struct GroceryPlan: Identifiable, Hashable {
    let id: String
    let dish: String
    let diet: String
    let items: [GroceryItem]
    let deliveryMinutes: Int
    let proteinEstimate: Int
    let serves: Int
    let mcpFlow: [String]

    var total: Int {
        items.reduce(0) { $0 + $1.price }
    }
}

struct EventPrepPlan: Identifiable, Hashable {
    let id: String
    let event: String
    let date: String
    let goal: String
    let timeline: [EventTimelineItem]
    let prepCarts: [PrepCart]
    let foodFlow: [String]
    let instamartFlow: [String]
    let trackingFlow: [String]
}

struct EventTimelineItem: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let title: String
    let detail: String
    let commerceLabel: String
    let price: Int?
    let macros: String?
}

struct PrepCart: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
    let icon: String
}

struct SuccessContext: Hashable {
    enum Kind: Hashable {
        case food(deliveryMinutes: Int)
        case instamart(deliveryMinutes: Int)
        case event
    }

    let kind: Kind
    let title: String
    let subtitle: String
    let fulfillmentLabel: String
    let detailTitle: String
    let detailSubtitle: String
    let steps: [String]
}

struct TrainingGoal: Identifiable, Hashable {
    let id: String
    var goalType: String
    var timeline: String
    var currentWeight: Int
    var targetDirection: String
    var trainingFrequency: String
    var dietPreference: String
    var budget: String
    var startDay: Int

    var totalDays: Int {
        switch timeline {
        case "In 2 weeks":
            return 14
        case "In 1 month":
            return 30
        case "In 3 months":
            return 88
        default:
            return 60
        }
    }

    var daysRemaining: Int {
        max(totalDays - startDay + 1, 1)
    }

    var displayTitle: String {
        "\(goalType) in \(daysRemaining) days"
    }
}

struct TrainingPhase: Identifiable, Hashable {
    let id: String
    let label: String
    let title: String
    let description: String
    let target: MacroTarget
    let carbNote: String
    let focus: String
    let swiggyExecution: [String]
}

struct MacroTarget: Hashable {
    let protein: Int
    let calories: Int
    let carbs: String
    let focus: String
}

struct DailyFuelPlan: Identifiable, Hashable {
    let id: String
    let goal: TrainingGoal
    let phase: TrainingPhase
    let meals: [FuelMeal]
    let progressProtein: Int
    let estimatedDailyCost: Int
}

struct FuelMeal: Identifiable, Hashable {
    enum Source: String, Hashable {
        case instamart = "Instamart"
        case food = "Swiggy Food"
    }

    let id: String
    let slot: String
    let source: Source
    let title: String
    let restaurant: String?
    let items: [String]
    let price: Int
    let protein: Int
    let calories: Int
    let deliveryMinutes: Int?
    let mcpMapping: [String]
}

struct GroceryCartItem: Identifiable, Hashable {
    let id: String
    let name: String
    let quantity: String
    let price: Int
}

struct PreparedCartItem: Identifiable, Hashable {
    let id: String
    let name: String
    let quantity: String
    let price: Int
}

struct PreparedCart: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case food
        case instamart
    }

    let id: String
    let kind: Kind
    let title: String
    let restaurant: String?
    let items: [PreparedCartItem]
    let addOns: [PreparedCartItem]
    let couponApplied: String?
    let couponDiscount: Int
    let deliveryMinutes: Int
    let total: Int
    let macroEstimate: MacroTarget
    let toolCalls: [MCPToolCall]
    let checkoutToolCalls: [MCPToolCall]
}

struct MCPToolCall: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let purpose: String
}

enum FoodMCPFlow: String, CaseIterable, Hashable {
    case getAddresses = "get_addresses"
    case searchRestaurants = "search_restaurants"
    case searchMenu = "search_menu"
    case getRestaurantMenu = "get_restaurant_menu"
    case getFoodCart = "get_food_cart"
    case updateFoodCart = "update_food_cart"
    case fetchFoodCoupons = "fetch_food_coupons"
    case applyFoodCoupon = "apply_food_coupon"
    case placeFoodOrder = "place_food_order"
    case trackFoodOrder = "track_food_order"
}

enum InstamartMCPFlow: String, CaseIterable, Hashable {
    case getAddresses = "get_addresses"
    case searchProducts = "search_products"
    case yourGoToItems = "your_go_to_items"
    case getCart = "get_cart"
    case updateCart = "update_cart"
    case clearCart = "clear_cart"
    case checkout = "checkout"
    case trackOrder = "track_order"
}

protocol MCPServiceProtocol {
    func prepareFoodCart(for meal: FuelMeal) -> PreparedCart
    func prepareInstamartCart(for groceryItems: [GroceryCartItem]) -> PreparedCart
    func applyCoupon() -> MCPToolCall
    func checkoutFoodCart() -> [MCPToolCall]
    func checkoutInstamartCart() -> [MCPToolCall]
    func trackOrder() -> MCPToolCall
}

struct MockMCPService: MCPServiceProtocol {
    func prepareFoodCart(for meal: FuelMeal) -> PreparedCart {
        let baseItems = meal.items.isEmpty ? [meal.title] : meal.items
        let items = baseItems.enumerated().map { index, item in
            PreparedCartItem(
                id: "\(meal.id)-item-\(index)",
                name: item,
                quantity: "1",
                price: index == 0 ? meal.price : 0
            )
        }
        let addOns = [
            PreparedCartItem(id: "\(meal.id)-addon-curd", name: "High-protein curd side", quantity: "1", price: 59)
        ]
        let couponDiscount = 40
        let deliveryFee = 29
        let total = meal.price + addOns.reduce(0) { $0 + $1.price } + deliveryFee - couponDiscount

        return PreparedCart(
            id: "food-\(meal.id)",
            kind: .food,
            title: meal.title,
            restaurant: meal.restaurant,
            items: items,
            addOns: addOns,
            couponApplied: "FITFUEL",
            couponDiscount: couponDiscount,
            deliveryMinutes: meal.deliveryMinutes ?? 28,
            total: total,
            macroEstimate: MacroTarget(
                protein: meal.protein + 11,
                calories: meal.calories + 90,
                carbs: "Estimated",
                focus: "\(meal.slot) fuel"
            ),
            toolCalls: [
                MCPToolCall(name: FoodMCPFlow.searchMenu.rawValue, purpose: "Find goal-aligned dishes"),
                MCPToolCall(name: FoodMCPFlow.getRestaurantMenu.rawValue, purpose: "Validate menu items and add-ons"),
                MCPToolCall(name: FoodMCPFlow.updateFoodCart.rawValue, purpose: "Prepare the reviewable cart"),
                MCPToolCall(name: FoodMCPFlow.fetchFoodCoupons.rawValue, purpose: "Find eligible demo coupons"),
                applyCoupon()
            ],
            checkoutToolCalls: checkoutFoodCart()
        )
    }

    func prepareInstamartCart(for groceryItems: [GroceryCartItem]) -> PreparedCart {
        let items = groceryItems.map {
            PreparedCartItem(id: $0.id, name: $0.name, quantity: $0.quantity, price: $0.price)
        }
        let total = items.reduce(0) { $0 + $1.price }

        return PreparedCart(
            id: "instamart-\(groceryItems.map(\.id).joined(separator: "-"))",
            kind: .instamart,
            title: groceryItems.count > 5 ? "Weekly protein refill" : "Breakfast Instamart cart",
            restaurant: nil,
            items: items,
            addOns: [],
            couponApplied: nil,
            couponDiscount: 0,
            deliveryMinutes: 18,
            total: total,
            macroEstimate: MacroTarget(
                protein: groceryItems.count > 5 ? 350 : 35,
                calories: groceryItems.count > 5 ? 0 : 520,
                carbs: "Planned",
                focus: groceryItems.count > 5 ? "5 training days" : "Breakfast prep"
            ),
            toolCalls: [
                MCPToolCall(name: InstamartMCPFlow.getAddresses.rawValue, purpose: "Select delivery address"),
                MCPToolCall(name: InstamartMCPFlow.searchProducts.rawValue, purpose: "Find matching staples"),
                MCPToolCall(name: InstamartMCPFlow.updateCart.rawValue, purpose: "Prepare the reviewable cart")
            ],
            checkoutToolCalls: checkoutInstamartCart()
        )
    }

    func applyCoupon() -> MCPToolCall {
        MCPToolCall(name: FoodMCPFlow.applyFoodCoupon.rawValue, purpose: "Apply the best demo coupon")
    }

    func checkoutFoodCart() -> [MCPToolCall] {
        [
            MCPToolCall(name: FoodMCPFlow.updateFoodCart.rawValue, purpose: "Confirm cart still matches review"),
            MCPToolCall(name: FoodMCPFlow.applyFoodCoupon.rawValue, purpose: "Re-apply demo coupon"),
            MCPToolCall(name: FoodMCPFlow.placeFoodOrder.rawValue, purpose: "Simulated checkout only after confirmation")
        ]
    }

    func checkoutInstamartCart() -> [MCPToolCall] {
        [
            MCPToolCall(name: InstamartMCPFlow.searchProducts.rawValue, purpose: "Confirm product availability"),
            MCPToolCall(name: InstamartMCPFlow.updateCart.rawValue, purpose: "Confirm cart quantities"),
            MCPToolCall(name: InstamartMCPFlow.checkout.rawValue, purpose: "Simulated checkout only after confirmation")
        ]
    }

    func trackOrder() -> MCPToolCall {
        MCPToolCall(name: FoodMCPFlow.trackFoodOrder.rawValue, purpose: "Simulate post-checkout tracking")
    }
}
