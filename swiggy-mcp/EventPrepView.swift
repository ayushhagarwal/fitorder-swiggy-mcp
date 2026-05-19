import SwiftUI

struct CookWithInstamartView: View {
    @State private var dish = "Paneer Bhurji"
    @State private var diet = "High protein"

    private var plan: GroceryPlan {
        MockData.groceryPlan(dish: dish, diet: diet)
    }

    var body: some View {
        DemoScreen(
            title: "Cook at home?",
            subtitle: "Turn a dish idea into an Instamart cart."
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 18) {
                    OptionPicker(title: "Dish", options: MockData.dishOptions, selection: $dish)
                    OptionPicker(title: "Diet", options: MockData.groceryDiets, selection: $diet)
                }
            }

            CardView {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.headline)
                        .foregroundStyle(Color.offerGreen)
                        .frame(width: 42, height: 42)
                        .background(Color.offerGreen.opacity(0.12))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Paneer Bhurji cart preview")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Estimated ₹333 · 18 mins · 45g protein total recipe")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }

            NavigationLink(value: AppRoute.instamartCart(plan)) {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Build Instamart Cart")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Groceries via Instamart. Product prices and availability are placeholders.")
        }
    }
}

struct EventPrepInputView: View {
    @State private var event = "10K Run"
    @State private var date = "Tomorrow"
    @State private var goal = "Race morning fuel"

    private var plan: EventPrepPlan {
        MockData.eventPlan(event: event, date: date, goal: goal)
    }

    var body: some View {
        DemoScreen(
            title: "Event Prep",
            subtitle: "Build a Food + Instamart execution plan for a race, swim meet, HYROX, ride or gym session."
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 18) {
                    OptionPicker(title: "Event", options: MockData.events, selection: $event)
                    OptionPicker(title: "Event date", options: MockData.eventDates, selection: $date)
                    OptionPicker(title: "Goal", options: MockData.eventGoals, selection: $goal)
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: "\(event) \(date)",
                        subtitle: "FitOrder turns prep intent into tonight, race morning and recovery carts."
                    )
                    HStack(spacing: 8) {
                        PillView(title: goal, icon: "figure.run", tint: .warningOrange)
                        PillView(title: "Food + Instamart", icon: "bag.fill", tint: .offerGreen)
                    }
                }
            }

            NavigationLink(value: AppRoute.eventPlan(plan)) {
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Create prep plan")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Event prep carts are simulated and require user confirmation.")
        }
    }
}

struct EventPrepView: View {
    let plan: EventPrepPlan

    var body: some View {
        DemoScreen(
            title: "\(plan.event) \(plan.date)",
            subtitle: "A demo prep timeline for \(plan.goal.lowercased()) in Bangalore"
        ) {
            timelineCard
            prepCartsCard
            mcpMappingCard

            NavigationLink(value: AppRoute.success(successContext)) {
                HStack {
                    Text("Generate event prep demo")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "bolt.fill")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Simulated MCP flow. Food and grocery carts are placeholders for demo review.")
        }
    }

    private var timelineCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Prep timeline", subtitle: "Tonight, race morning and recovery mapped to executable carts")
                ForEach(plan.timeline) { item in
                    TimelineRow(item: item)
                }
            }
        }
    }

    private var prepCartsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "One-tap prep carts")
                ForEach(plan.prepCarts) { cart in
                    HStack(spacing: 12) {
                        Image(systemName: cart.icon)
                            .foregroundStyle(Color.swiggyOrange)
                            .frame(width: 34, height: 34)
                            .background(Color.swiggyOrange.opacity(0.11))
                            .clipShape(Circle())
                        Text(cart.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Spacer()
                        Text("₹\(cart.price)")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(Color.primaryText)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var mcpMappingCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "MCP mapping")
                FlowGroup(title: "Food", steps: plan.foodFlow)
                FlowGroup(title: "Instamart", steps: plan.instamartFlow)
                FlowGroup(title: "Tracking", steps: plan.trackingFlow)
            }
        }
    }

    private var successContext: SuccessContext {
        SuccessContext(
            kind: .event,
            title: "Event prep demo generated",
            subtitle: "This shows how MCP can connect fitness intent to Food + Instamart execution.",
            fulfillmentLabel: "Food + Instamart carts simulated",
            detailTitle: "\(plan.event) prep ready",
            detailSubtitle: "\(plan.date) · \(plan.goal)",
            steps: ["Prep plan created", "Food cart mapped", "Instamart cart mapped", "Ready for user confirmation"]
        )
    }
}

private struct TimelineRow: View {
    let item: EventTimelineItem

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            VStack(spacing: 6) {
                Circle()
                    .fill(Color.swiggyOrange)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(Color.dividerColor)
                    .frame(width: 2, height: 58)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(item.time)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.swiggyOrange)
                Text(item.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                Text(item.commerceLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(Color.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    if let price = item.price {
                        PillView(title: "₹\(price)", tint: .primaryText)
                    }
                    if let macros = item.macros {
                        PillView(title: macros, tint: .offerGreen)
                    }
                }
            }
        }
    }
}

private struct FlowGroup: View {
    let title: String
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.secondaryText)
            ForEach(steps, id: \.self) { step in
                MCPFlowRow(title: step)
            }
        }
    }
}

struct GoalSetupView: View {
    @State private var goalType = "HYROX"
    @State private var timeline = "In 2 months"
    @State private var currentWeight = "74"
    @State private var targetDirection = "Lean down"
    @State private var trainingFrequency = "5 days/week"
    @State private var dietPreference = "High-protein veg"
    @State private var budget = "₹400/day"

    private var goal: TrainingGoal {
        MockData.trainingGoal(
            goalType: goalType,
            timeline: timeline,
            currentWeight: Int(currentWeight) ?? 74,
            targetDirection: targetDirection,
            trainingFrequency: trainingFrequency,
            dietPreference: dietPreference,
            budget: budget
        )
    }

    var body: some View {
        DemoScreen(
            title: "Create training goal",
            subtitle: "FitOrder turns your event timeline into daily Swiggy Food + Instamart execution."
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 18) {
                    OptionPicker(title: "Goal type", options: MockData.trainingGoalTypes, selection: $goalType)
                    OptionPicker(title: "Event date or timeline", options: MockData.trainingTimelines, selection: $timeline)
                    weightInput
                    OptionPicker(title: "Target body weight or direction", options: MockData.targetDirections, selection: $targetDirection)
                    OptionPicker(title: "Training frequency", options: MockData.trainingFrequencies, selection: $trainingFrequency)
                    OptionPicker(title: "Diet preference", options: MockData.goalDietPreferences, selection: $dietPreference)
                    OptionPicker(title: "Budget", options: MockData.dailyBudgets, selection: $budget)
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: goal.displayTitle,
                        subtitle: "Estimated macros and carts will adapt to your selected phase."
                    )
                    HStack(spacing: 8) {
                        PillView(title: trainingFrequency, icon: "calendar", tint: .primaryText)
                        PillView(title: dietPreference, icon: "fork.knife", tint: .offerGreen)
                    }
                }
            }

            NavigationLink(value: AppRoute.goalTimeline(goal)) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate goal timeline")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Demo nutrition guidance only. Not medical advice.")
        }
    }

    private var weightInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current body weight")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
            HStack {
                TextField("74", text: $currentWeight)
                    .keyboardType(.numberPad)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                Text("kg")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct GoalTimelineView: View {
    let goal: TrainingGoal

    private var phases: [TrainingPhase] {
        MockData.phases(for: goal)
    }

    var body: some View {
        DemoScreen(
            title: goal.displayTitle,
            subtitle: "Food + Instamart mapped to your training phase."
        ) {
            phaseProgressCard
            phaseSnapshotCards

            VStack(spacing: 16) {
                ForEach(phases) { phase in
                    TrainingPhaseCard(phase: phase)
                }
            }

            NavigationLink(value: AppRoute.todayFuelPlan(goal)) {
                HStack {
                    Text("View today’s execution plan")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "fork.knife")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.swiggyOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Estimated macros and goal-aligned suggestions are simulated.")
        }
    }

    private var phaseProgressCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    PillView(title: "Day \(goal.startDay) of \(goal.totalDays)", icon: "calendar", tint: .offerGreen)
                    PillView(title: "Phase 1", icon: "bolt.fill", tint: .warningOrange)
                    Spacer()
                }
                SectionHeader(
                    title: "Base + Lean Protein",
                    subtitle: "Structured ordering, not impulse ordering."
                )
                ProgressView(value: Double(goal.startDay), total: Double(goal.totalDays))
                    .tint(Color.swiggyOrange)
            }
        }
    }

    private var phaseSnapshotCards: some View {
        HStack(spacing: 10) {
            TimelineSnapshot(title: "Today", subtitle: "\(MockData.proteinTarget(for: goal))g protein", icon: "fork.knife")
            TimelineSnapshot(title: "This Week", subtitle: "Refill staples", icon: "cart.fill")
            TimelineSnapshot(title: "Event Week", subtitle: "Fuel timing", icon: "trophy.fill")
        }
    }
}

private struct TimelineSnapshot: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.swiggyOrange)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
            Text(subtitle)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .softShadow()
    }
}

private struct TrainingPhaseCard: View {
    let phase: TrainingPhase

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Phase · \(phase.label)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.swiggyOrange)
                        Text(phase.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.successGreen)
                }
                Text(phase.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    MacroChip(label: "Protein", value: "\(phase.target.protein)g")
                    MacroChip(label: "Calories", value: "\(phase.target.calories)")
                }
                HStack(spacing: 8) {
                    PillView(title: "Carbs: \(phase.carbNote)", tint: .primaryText)
                    PillView(title: phase.focus, tint: .offerGreen)
                }

                Divider().background(Color.dividerColor)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Swiggy execution")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    ForEach(phase.swiggyExecution, id: \.self) { item in
                        Label(item, systemImage: "bag.fill")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
        }
    }
}

struct TodayFuelPlanView: View {
    let goal: TrainingGoal
    private let service = MockMCPService()

    private var plan: DailyFuelPlan {
        MockData.todayFuelPlan(for: goal)
    }

    var body: some View {
        DemoScreen(
            title: "Today’s Fuel Plan",
            subtitle: "Built for your current training phase"
        ) {
            macroProgressCard

            VStack(spacing: 16) {
                ForEach(plan.meals) { meal in
                    FuelMealCard(meal: meal, cart: preparedCart(for: meal))
                }
            }

            estimatedCostCard

            NavigationLink(value: AppRoute.weeklyRefill(goal)) {
                HStack {
                    Image(systemName: "bag.fill")
                    Text("Prepare Weekly Refill")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.offerGreen)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            Button {
            } label: {
                HStack {
                    Image(systemName: "repeat")
                    Text("Repeat this plan tomorrow")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text("simulated")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(Color.primaryText)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .softShadow()
            }
            .buttonStyle(ScaleButtonStyle())

            DisclaimerFooter(text: "Demo nutrition guidance only. Not medical advice. Review before checkout.")
        }
    }

    private func preparedCart(for meal: FuelMeal) -> PreparedCart {
        if meal.source == .instamart {
            return service.prepareInstamartCart(for: MockData.breakfastItems(for: meal))
        }
        return service.prepareFoodCart(for: meal)
    }

    private var macroProgressCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Daily macro progress")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Turn today’s macros into a Swiggy cart.")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                    Spacer()
                    PillView(title: "Phase 1", icon: "bolt.fill", tint: .warningOrange)
                }
                ProgressView(value: Double(plan.progressProtein), total: Double(plan.phase.target.protein))
                    .tint(Color.swiggyOrange)
                HStack(spacing: 8) {
                    MacroChip(label: "Planned protein", value: "\(plan.progressProtein)g")
                    MacroChip(label: "Target", value: "\(plan.phase.target.protein)g")
                    MacroChip(label: "Calories", value: "\(plan.phase.target.calories)")
                }
            }
        }
    }

    private var estimatedCostCard: some View {
        CardView {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Estimated daily cost")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text("Food + Instamart suggestions for today")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                Spacer()
                Text("₹\(plan.estimatedDailyCost)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.primaryText)
            }
        }
    }
}

private struct FuelMealCard: View {
    let meal: FuelMeal
    let cart: PreparedCart

    private var cta: String {
        switch meal.source {
        case .instamart:
            return "Prepare Instamart Cart"
        case .food:
            return meal.slot == "Dinner" ? "Prepare Dinner Cart" : "Prepare Food Cart"
        }
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(meal.slot) / \(meal.source.rawValue)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.swiggyOrange)
                        Text(meal.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        if let restaurant = meal.restaurant {
                            Text(restaurant)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                    Spacer()
                    Image(systemName: meal.source == .food ? "fork.knife" : "cart.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.swiggyOrange)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(meal.items, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                HStack(spacing: 8) {
                    PillView(title: "₹\(meal.price)", tint: .primaryText)
                    PillView(title: "\(meal.protein)g protein", tint: .offerGreen)
                    PillView(title: "\(meal.calories) kcal", tint: .warningOrange)
                    if let deliveryMinutes = meal.deliveryMinutes {
                        PillView(title: "\(deliveryMinutes) mins", icon: "clock", tint: .primaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("MCP mapping")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.secondaryText)
                    ForEach(meal.mcpMapping, id: \.self) { step in
                        MCPFlowRow(title: step)
                    }
                }

                NavigationLink(value: AppRoute.preparedCartReview(cart)) {
                    HStack {
                        Text(cta)
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "cart.fill")
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.swiggyOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

struct PreparedCartReviewView: View {
    let cart: PreparedCart

    var body: some View {
        DemoScreen(
            title: cart.kind == .food ? "Food cart review" : "Instamart cart review",
            subtitle: "Review before checkout. This is simulated and no real order is placed."
        ) {
            cartReviewCard
            macroCard
            toolCallCard(title: "Prepared cart via MCP", calls: cart.toolCalls)
            toolCallCard(title: "Confirm demo checkout mapping", calls: cart.checkoutToolCalls)

            NavigationLink(value: AppRoute.success(successContext)) {
                HStack {
                    Text("Confirm demo checkout")
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

            DisclaimerFooter(text: "Simulated checkout only. Real checkout would require explicit user review and confirmation.")
        }
    }

    private var cartReviewCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: cart.title,
                    subtitle: cart.restaurant ?? "Groceries via Instamart"
                )
                Divider().background(Color.dividerColor)
                ForEach(cart.items) { item in
                    CartRow(title: item.name, subtitle: item.quantity, amount: item.price == 0 ? "Included" : "₹\(item.price)")
                }
                ForEach(cart.addOns) { item in
                    CartRow(title: item.name, subtitle: "Add-on · \(item.quantity)", amount: "₹\(item.price)")
                }
                Divider().background(Color.dividerColor)
                if let coupon = cart.couponApplied {
                    CartRow(title: "\(coupon) applied", subtitle: "Mock coupon for demo checkout", amount: "-₹\(cart.couponDiscount)", amountColor: .offerGreen)
                }
                CartRow(title: "Delivery estimate", amount: "\(cart.deliveryMinutes) mins")
                Divider().background(Color.dividerColor)
                HStack {
                    Text("Total")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Spacer()
                    Text("₹\(cart.total)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                }
                .padding(.top, 8)
            }
        }
    }

    private var macroCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Macro estimate", subtitle: "Estimated macros from mocked nutrition labels")
                HStack(spacing: 8) {
                    MacroChip(label: "Protein", value: "\(cart.macroEstimate.protein)g")
                    MacroChip(label: "Calories", value: cart.macroEstimate.calories > 0 ? "\(cart.macroEstimate.calories)" : "varies")
                    MacroChip(label: "Focus", value: cart.macroEstimate.focus)
                }
            }
        }
    }

    private func toolCallCard(title: String, calls: [MCPToolCall]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: title)
                ForEach(calls) { call in
                    VStack(alignment: .leading, spacing: 3) {
                        MCPFlowRow(title: call.name)
                        Text(call.purpose)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                            .padding(.leading, 30)
                    }
                }
            }
        }
    }

    private var successContext: SuccessContext {
        switch cart.kind {
        case .food:
            return SuccessContext(
                kind: .food(deliveryMinutes: cart.deliveryMinutes),
                title: "Demo food checkout confirmed",
                subtitle: "This simulates the MCP food checkout after explicit review. No real order was placed.",
                fulfillmentLabel: "Swiggy Food checkout simulated",
                detailTitle: "Delivery estimate \(cart.deliveryMinutes) mins",
                detailSubtitle: cart.title,
                steps: ["Cart reviewed", "Coupon applied", "User confirmed demo checkout", "Ready to track simulated order"]
            )
        case .instamart:
            return SuccessContext(
                kind: .instamart(deliveryMinutes: cart.deliveryMinutes),
                title: "Demo Instamart checkout confirmed",
                subtitle: "This simulates the MCP Instamart checkout after explicit review. No real order was placed.",
                fulfillmentLabel: "Instamart checkout simulated",
                detailTitle: "Delivery estimate \(cart.deliveryMinutes) mins",
                detailSubtitle: cart.title,
                steps: ["Products reviewed", "Cart quantities confirmed", "User confirmed demo checkout", "Ready to track simulated order"]
            )
        }
    }
}

struct WeeklyRefillView: View {
    let goal: TrainingGoal
    private let service = MockMCPService()

    private var items: [GroceryCartItem] {
        MockData.weeklyRefillItems(for: goal)
    }

    private var total: Int {
        items.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        DemoScreen(
            title: "Weekly protein refill",
            subtitle: "Your staples for this training phase"
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(
                        title: "Training staples",
                        subtitle: "Planned Instamart usage for repeat weekly execution."
                    )
                    ForEach(items) { item in
                        CartRow(title: item.name, subtitle: item.quantity, amount: "₹\(item.price)")
                    }
                    Divider().background(Color.dividerColor)
                    HStack {
                        Text("Estimated total")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Spacer()
                        Text("₹\(total)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                    }
                }
            }

            CardView {
                HStack(spacing: 8) {
                    MacroChip(label: "Covers", value: "5 days")
                    MacroChip(label: "Protein support", value: "350g+")
                    MacroChip(label: "Phase", value: "1")
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "MCP")
                    ForEach(["search_products", "update_cart", "checkout"], id: \.self) { step in
                        MCPFlowRow(title: step)
                    }
                }
            }

            NavigationLink(value: AppRoute.preparedCartReview(service.prepareInstamartCart(for: items))) {
                HStack {
                    Text("Prepare weekly Instamart cart")
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

            DisclaimerFooter(text: "Simulated Instamart cart. Checkout requires review and confirmation.")
        }
    }
}

struct ProgressInsightView: View {
    var body: some View {
        DemoScreen(
            title: "Why this helps",
            subtitle: "FitOrder is an execution layer, not a diet tracker."
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    InsightRow(icon: "repeat", title: "Converts fitness intent into repeatable food orders")
                    InsightRow(icon: "checkmark.circle.fill", title: "Supports users who avoid impulse ordering")
                    InsightRow(icon: "fork.knife", title: "Creates planned Swiggy Food + Instamart usage")
                    InsightRow(icon: "cart.fill", title: "Encourages repeat weekly grocery carts")
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(
                        title: "Execution layer",
                        subtitle: "Your plan is only useful if you can execute it."
                    )
                    Text("FitOrder keeps suggestions goal-aligned, estimated, and reviewable before checkout.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            DisclaimerFooter(text: "Demo nutrition guidance only. Not medical advice.")
        }
    }
}

private struct InsightRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.successGreen)
                .frame(width: 34, height: 34)
                .background(Color.successGreen.opacity(0.12))
                .clipShape(Circle())
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
