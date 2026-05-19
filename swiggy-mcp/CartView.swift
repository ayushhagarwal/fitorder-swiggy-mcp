import SwiftUI

struct CartView: View {
    let meal: MealRecommendation
    private let addon = MockData.curdAddon
    private let coupon = 40
    private let deliveryFee = 29
    private let platformFee = 6

    private var subtotal: Int { meal.price + addon.price }
    private var total: Int { subtotal - coupon + deliveryFee + platformFee }
    private var protein: Int { meal.protein + addon.protein }
    private var calories: Int { meal.calories + addon.calories }
    private var carbs: Int { meal.carbs + addon.carbs }
    private var fat: Int { meal.fat + addon.fat }

    var body: some View {
        DemoScreen(
            title: "Demo Swiggy Cart",
            subtitle: "Review before placing a simulated order"
        ) {
            cartSummary
            macroSummary
            mcpFlowCard

            NavigationLink(value: AppRoute.success(successContext)) {
                HStack {
                    Text("Generate demo order")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Demo only. A real Swiggy order is not placed from this prototype.")
        }
    }

    private var cartSummary: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: meal.restaurant, subtitle: "Order fulfilled via Swiggy")
                Divider().background(Color.dividerColor)
                CartRow(title: meal.name, subtitle: "\(meal.protein)g protein · \(meal.calories) kcal", amount: "₹\(meal.price)")
                CartRow(title: addon.name, subtitle: "\(addon.protein)g protein add-on", amount: "₹\(addon.price)")
                Divider().background(Color.dividerColor)
                CartRow(title: "FITFUEL applied", subtitle: "Mock coupon for demo checkout", amount: "-₹\(coupon)", amountColor: .offerGreen)
                CartRow(title: "Delivery fee", amount: "₹\(deliveryFee)")
                CartRow(title: "Platform fee", amount: "₹\(platformFee)")
                Divider().background(Color.dividerColor)
                HStack {
                    Text("Total")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Spacer()
                    Text("₹\(total)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                }
                .padding(.top, 8)
            }
        }
    }

    private var macroSummary: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Macro summary", subtitle: "Estimated from mocked nutrition labels")
                HStack(spacing: 8) {
                    MacroChip(label: "Protein", value: "\(protein)g")
                    MacroChip(label: "Calories", value: "\(calories)")
                }
                HStack(spacing: 8) {
                    MacroChip(label: "Carbs", value: "\(carbs)g")
                    MacroChip(label: "Fat", value: "\(fat)g")
                }
            }
        }
    }

    private var mcpFlowCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "MCP flow simulated")
                ForEach(["search_menu", "update_food_cart", "fetch_food_coupons", "apply_food_coupon", "place_food_order"], id: \.self) { step in
                    MCPFlowRow(title: step)
                }
            }
        }
    }

    private var successContext: SuccessContext {
        SuccessContext(
            kind: .food(deliveryMinutes: meal.deliveryMinutes),
            title: "Demo order generated",
            subtitle: "This simulates how Swiggy MCP would execute the meal order after user confirmation.",
            fulfillmentLabel: "Order fulfilled via Swiggy",
            detailTitle: "Arrives in \(meal.deliveryMinutes) mins",
            detailSubtitle: meal.name,
            steps: ["Cart created", "Coupon applied", "User confirmed", "Ready for MCP checkout"]
        )
    }
}

struct InstamartCartView: View {
    let plan: GroceryPlan

    var body: some View {
        DemoScreen(
            title: "Instamart Demo Cart",
            subtitle: "A mocked ingredient cart for \(plan.dish)"
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: plan.dish, subtitle: "Groceries via Instamart")
                    Divider().background(Color.dividerColor)
                    ForEach(plan.items) { item in
                        CartRow(title: item.name, amount: "₹\(item.price)")
                    }
                    Divider().background(Color.dividerColor)
                    HStack {
                        Text("Estimated total")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Spacer()
                        Text("₹\(plan.total)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                    }
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Recipe estimate", subtitle: "Simulated nutrition and delivery data")
                    HStack(spacing: 8) {
                        MacroChip(label: "Delivery", value: "\(plan.deliveryMinutes)m")
                        MacroChip(label: "Protein", value: "\(plan.proteinEstimate)g")
                        MacroChip(label: "Serves", value: "\(plan.serves)")
                    }
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "MCP flow simulated")
                    ForEach(plan.mcpFlow, id: \.self) { step in
                        MCPFlowRow(title: step)
                    }
                }
            }

            NavigationLink(value: AppRoute.success(successContext)) {
                HStack {
                    Text("Generate Instamart demo cart")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "cart.fill")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Prices, availability and delivery time are simulated for demo.")
        }
    }

    private var successContext: SuccessContext {
        SuccessContext(
            kind: .instamart(deliveryMinutes: plan.deliveryMinutes),
            title: "Instamart demo cart generated",
            subtitle: "This simulates how Swiggy MCP would build an Instamart grocery cart after user confirmation.",
            fulfillmentLabel: "Groceries via Instamart",
            detailTitle: "Arrives in \(plan.deliveryMinutes) mins",
            detailSubtitle: "\(plan.dish) ingredients · serves \(plan.serves)",
            steps: ["Address selected", "Products found", "Cart updated", "Ready for MCP checkout"]
        )
    }
}
