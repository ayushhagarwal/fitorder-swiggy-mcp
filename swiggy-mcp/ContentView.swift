import SwiftUI

enum AppRoute: Hashable {
    case dailyMacroMeal
    case cookWithInstamart
    case eventPrepInput
    case goalSetup
    case recommendations(FitnessPreferences)
    case foodCart(MealRecommendation)
    case instamartCart(GroceryPlan)
    case eventPlan(EventPrepPlan)
    case goalTimeline(TrainingGoal)
    case todayFuelPlan(TrainingGoal)
    case preparedCartReview(PreparedCart)
    case weeklyRefill(TrainingGoal)
    case progressInsight
    case success(SuccessContext)
}

enum AppTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case goal = "Goal"
    case carts = "Carts"
    case mcp = "MCP"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .today:
            return "bolt.fill"
        case .goal:
            return "trophy.fill"
        case .carts:
            return "cart.fill"
        case .mcp:
            return "point.3.connected.trianglepath.dotted"
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var selectedTab: AppTab = .today

    var body: some View {
        NavigationStack(path: $path) {
            AppShellView(selectedTab: $selectedTab)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(.swiggyOrange)
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .dailyMacroMeal:
            DailyMacroMealView()
        case .cookWithInstamart:
            CookWithInstamartView()
        case .eventPrepInput:
            EventPrepInputView()
        case .goalSetup:
            GoalSetupView()
        case .recommendations(let preferences):
            RecommendationsView(preferences: preferences)
        case .foodCart(let meal):
            CartView(meal: meal)
        case .instamartCart(let plan):
            InstamartCartView(plan: plan)
        case .eventPlan(let plan):
            EventPrepView(plan: plan)
        case .goalTimeline(let goal):
            GoalTimelineView(goal: goal)
        case .todayFuelPlan(let goal):
            TodayFuelPlanView(goal: goal)
        case .preparedCartReview(let cart):
            PreparedCartReviewView(cart: cart)
        case .weeklyRefill(let goal):
            WeeklyRefillView(goal: goal)
        case .progressInsight:
            ProgressInsightView()
        case .success(let context):
            OrderSuccessView(context: context) {
                path = NavigationPath()
            }
        }
    }
}

private struct AppShellView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .today:
                    HomeView()
                case .goal:
                    GoalHubView()
                case .carts:
                    CartBuildersHubView()
                case .mcp:
                    MCPHubView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomPillNavigation(selectedTab: $selectedTab)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

private struct BottomPillNavigation: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.caption.weight(.bold))
                        Text(tab.rawValue)
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .foregroundStyle(selectedTab == tab ? .white : Color.secondaryText)
                    .background(selectedTab == tab ? Color.swiggyOrange : Color.cardBackground)
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            Color.appBackground
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}
