import SwiftUI

struct DailyMacroMealView: View {
    @State private var goal = MockData.defaultPreferences.goal
    @State private var diet = MockData.defaultPreferences.diet
    @State private var cuisine = MockData.defaultPreferences.cuisine
    @State private var budget = MockData.defaultPreferences.budget
    @State private var proteinTarget = MockData.defaultPreferences.proteinTarget
    @State private var calories = MockData.defaultPreferences.calories

    private var preferences: FitnessPreferences {
        FitnessPreferences(
            goal: goal,
            diet: diet,
            cuisine: cuisine,
            budget: budget,
            proteinTarget: proteinTarget,
            calories: calories
        )
    }

    var body: some View {
        DemoScreen(
            title: "Daily Macro Meal",
            subtitle: "Tell FitOrder the fitness target. The demo maps it to mocked Swiggy Food recommendations."
        ) {
            CardView {
                VStack(alignment: .leading, spacing: 18) {
                    OptionPicker(title: "Goal", options: MockData.goals, selection: $goal)
                    OptionPicker(title: "Diet", options: MockData.diets, selection: $diet)
                    OptionPicker(title: "Cuisine", options: MockData.cuisines, selection: $cuisine)
                    OptionPicker(title: "Budget", options: MockData.budgets, selection: $budget)
                    OptionPicker(title: "Protein target", options: MockData.proteinTargets, selection: $proteinTarget)
                    OptionPicker(title: "Calories", options: MockData.calorieTargets, selection: $calories)
                }
            }

            NavigationLink(value: AppRoute.recommendations(preferences)) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Swiggy Meals")
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

            DisclaimerFooter()
        }
    }
}

struct RecommendationsView: View {
    let preferences: FitnessPreferences

    var body: some View {
        DemoScreen(
            title: "Best matches for your goal",
            subtitle: "\(preferences.diet) meals \(preferences.budget.lowercased()) · Bangalore"
        ) {
            insightCard

            VStack(spacing: 16) {
                ForEach(Array(MockData.meals.enumerated()), id: \.element.id) { index, meal in
                    MealCard(meal: meal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.82).delay(Double(index) * 0.04), value: meal.id)
                }
            }

            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("MCP mapping preview")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    ForEach(MockData.meals[0].mcpFlow, id: \.self) { step in
                        MCPFlowRow(title: step)
                    }
                }
            }

            DisclaimerFooter(text: "Prices, availability and delivery time are placeholders for this demo.")
        }
    }

    private var insightCard: some View {
        CardView {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "bolt.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.swiggyOrange)
                    .frame(width: 38, height: 38)
                    .background(Color.swiggyOrange.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text("Recommended plan")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text("Paneer protein bowl + curd side gets you closest to your \(preferences.goal.lowercased()) target.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
