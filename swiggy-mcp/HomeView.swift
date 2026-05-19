import SwiftUI

struct HomeView: View {
    private let activeGoal = MockData.activeTrainingGoal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                activeGoalCard
                todayExecutionCard
                quickActions
                DisclaimerFooter(text: "Demo nutrition guidance only. Not medical advice. Swiggy MCP calls are simulated.")
            }
            .padding(AppSpacing.screen)
            .padding(.top, 6)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FitOrder")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.primaryText)
                    Text("Performance meals via Swiggy MCP")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)
                }
                Spacer()
                PillView(title: "Swiggy MCP Demo", icon: "bolt.fill")
            }
            Text("Turn fitness goals into Food + Instamart execution")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var heroCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What do you want to fuel today?")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Your plan is only useful if you can execute it. Turn today’s macros into a Swiggy cart.")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.swiggyOrange.opacity(0.13))
                        Image(systemName: "fork.knife")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.swiggyOrange)
                    }
                    .frame(width: 46, height: 46)
                }

                HStack(spacing: 8) {
                    PillView(title: "Intent", tint: .primaryText)
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.mutedText)
                    PillView(title: "AI Plan", tint: .warningOrange)
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.mutedText)
                    PillView(title: "Cart", tint: .offerGreen)
                }
            }
        }
    }

    private var activeGoalCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.swiggyOrange.opacity(0.13))
                        Image(systemName: "figure.run")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.swiggyOrange)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            PillView(title: "Day \(activeGoal.startDay) of \(activeGoal.totalDays)", icon: "calendar", tint: .offerGreen)
                            PillView(title: "Phase 1", icon: "bolt.fill", tint: .warningOrange)
                        }
                        Text(activeGoal.displayTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Phase 1 · Base + Lean Protein")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer(minLength: 4)
                }

                HStack(spacing: 8) {
                    MacroChip(label: "Protein", value: "\(MockData.proteinTarget(for: activeGoal))g")
                    MacroChip(label: "Calories", value: "\(MockData.calorieTarget(for: activeGoal))")
                }

                HStack(spacing: 8) {
                    PillView(title: "Strength + conditioning", icon: "bolt.fill", tint: .primaryText)
                    PillView(title: "Review before checkout", icon: "checkmark.circle.fill", tint: .offerGreen)
                }

                NavigationLink(value: AppRoute.todayFuelPlan(activeGoal)) {
                    HStack {
                        Text("View today’s fuel plan")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.swiggyOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())

                NavigationLink(value: AppRoute.goalSetup) {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                        Text("Create training goal")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.swiggyOrange)
                }
            }
        }
    }

    private var todayExecutionCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                SectionHeader(
                    title: "Today’s execution",
                    subtitle: "Breakfast via Instamart, lunch and dinner via Swiggy Food."
                )

                HStack(spacing: 8) {
                    MacroChip(label: "Planned protein", value: "99g")
                    MacroChip(label: "Cost", value: "₹814")
                    MacroChip(label: "Phase", value: "1")
                }

                HStack(spacing: 8) {
                    PillView(title: "Breakfast cart", icon: "cart.fill", tint: .offerGreen)
                    PillView(title: "Food carts", icon: "fork.knife", tint: .swiggyOrange)
                }

                NavigationLink(value: AppRoute.todayFuelPlan(activeGoal)) {
                    HStack {
                        Text("Open fuel plan")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "arrow.right")
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

    private var quickActions: some View {
        HStack(spacing: 10) {
            QuickActionLink(
                title: "Meal",
                subtitle: "Macro match",
                icon: "flame.fill",
                tint: .swiggyOrange,
                route: .dailyMacroMeal
            )
            QuickActionLink(
                title: "Cook",
                subtitle: "Instamart",
                icon: "cart.fill",
                tint: .offerGreen,
                route: .cookWithInstamart
            )
        }
    }

    private var journeys: some View {
        VStack(spacing: 12) {
            JourneyCard(
                title: "Daily Macro Meal",
                subtitle: "Find restaurant meals for your protein, calories and budget",
                icon: "flame.fill",
                cta: "Build meal",
                tint: .swiggyOrange,
                route: .dailyMacroMeal
            )

            JourneyCard(
                title: "Cook With Instamart",
                subtitle: "Turn a dish idea into an Instamart ingredient cart",
                icon: "cart.fill",
                cta: "Create grocery cart",
                tint: .offerGreen,
                route: .cookWithInstamart
            )

            JourneyCard(
                title: "Event Prep",
                subtitle: "Prep meals and essentials for marathon, HYROX, swim or race day",
                icon: "trophy.fill",
                cta: "Plan event",
                tint: .warningOrange,
                route: .eventPrepInput
            )

            JourneyCard(
                title: "Weekly Refill",
                subtitle: "Restock your training staples via Instamart",
                icon: "bag.fill",
                cta: "Build refill cart",
                tint: .offerGreen,
                route: .weeklyRefill(activeGoal)
            )
        }
    }

    private var architectureCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(
                    title: "How MCP fits",
                    subtitle: "Food + Instamart mapped to your training phase. Structured ordering, not impulse ordering."
                )

                HStack(spacing: 8) {
                    FlowStep(title: "Intent", icon: "person.fill.checkmark")
                    FlowArrow()
                    FlowStep(title: "AI Plan", icon: "sparkles")
                    FlowArrow()
                    FlowStep(title: "Food / Cart", icon: "bag.fill")
                    FlowArrow()
                    FlowStep(title: "Confirm", icon: "checkmark.circle.fill")
                }

                NavigationLink(value: AppRoute.progressInsight) {
                    HStack {
                        Text("Why this helps")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(Color.swiggyOrange)
                }
                .padding(.top, 4)
            }
        }
    }

    private var privacyCard: some View {
        CardView {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.headline)
                    .foregroundStyle(Color.successGreen)
                    .frame(width: 30, height: 30)
                    .background(Color.successGreen.opacity(0.12))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Privacy-first demo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text("We only use goal preferences in this prototype. No payment data, no health records, no scraping.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct GoalHubView: View {
    private let activeGoal = MockData.activeTrainingGoal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppPageHeader(
                    title: "Training Goal",
                    subtitle: "Long-term planning, daily fuel, and weekly refill rhythm."
                )
                goalSummaryCard
                phaseCards
                goalActions
                DisclaimerFooter(text: "Demo nutrition guidance only. Not medical advice.")
            }
            .padding(AppSpacing.screen)
            .padding(.top, 6)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var goalSummaryCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.warningOrange)
                        .frame(width: 40, height: 40)
                        .background(Color.warningOrange.opacity(0.12))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activeGoal.displayTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Phase 1 · Base + Lean Protein")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }
                    Spacer()
                }

                ProgressView(value: Double(activeGoal.startDay), total: Double(activeGoal.totalDays))
                    .tint(Color.swiggyOrange)

                HStack(spacing: 8) {
                    PillView(title: "Day \(activeGoal.startDay) of \(activeGoal.totalDays)", icon: "calendar", tint: .offerGreen)
                    PillView(title: activeGoal.trainingFrequency, icon: "bolt.fill", tint: .primaryText)
                }
            }
        }
    }

    private var phaseCards: some View {
        HStack(spacing: 10) {
            PhaseMiniCard(title: "Today", subtitle: "Base fuel", icon: "fork.knife")
            PhaseMiniCard(title: "This Week", subtitle: "Protein refill", icon: "bag.fill")
            PhaseMiniCard(title: "Event Week", subtitle: "Timing", icon: "trophy.fill")
        }
    }

    private var goalActions: some View {
        VStack(spacing: 12) {
            JourneyCard(
                title: "Goal Timeline",
                subtitle: "See phases, targets and Swiggy execution mapped by week",
                icon: "calendar",
                cta: "View timeline",
                tint: .warningOrange,
                route: .goalTimeline(activeGoal)
            )
            JourneyCard(
                title: "Create New Goal",
                subtitle: "Set goal type, timeline, body weight, training days, diet and budget",
                icon: "plus.circle.fill",
                cta: "Create goal",
                tint: .swiggyOrange,
                route: .goalSetup
            )
            JourneyCard(
                title: "Weekly Refill",
                subtitle: "Restock your training staples via Instamart",
                icon: "bag.fill",
                cta: "Build refill cart",
                tint: .offerGreen,
                route: .weeklyRefill(activeGoal)
            )
        }
    }
}

struct CartBuildersHubView: View {
    private let activeGoal = MockData.activeTrainingGoal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppPageHeader(
                    title: "Cart Builders",
                    subtitle: "Choose the demo flow you want to prepare and review."
                )
                reviewRuleCard
                VStack(spacing: 12) {
                    JourneyCard(
                        title: "Daily Macro Meal",
                        subtitle: "Find restaurant meals for your protein, calories and budget",
                        icon: "flame.fill",
                        cta: "Build meal",
                        tint: .swiggyOrange,
                        route: .dailyMacroMeal
                    )
                    JourneyCard(
                        title: "Cook With Instamart",
                        subtitle: "Turn a dish idea into an Instamart ingredient cart",
                        icon: "cart.fill",
                        cta: "Create grocery cart",
                        tint: .offerGreen,
                        route: .cookWithInstamart
                    )
                    JourneyCard(
                        title: "Event Prep",
                        subtitle: "Prep meals and essentials for marathon, HYROX, swim or race day",
                        icon: "trophy.fill",
                        cta: "Plan event",
                        tint: .warningOrange,
                        route: .eventPrepInput
                    )
                    JourneyCard(
                        title: "Today’s Fuel Plan",
                        subtitle: "Prepare breakfast, lunch and dinner carts from the active goal",
                        icon: "fork.knife",
                        cta: "Prepare carts",
                        tint: .swiggyOrange,
                        route: .todayFuelPlan(activeGoal)
                    )
                }
                DisclaimerFooter(text: "All cart creation is simulated and requires review before checkout.")
            }
            .padding(AppSpacing.screen)
            .padding(.top, 6)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var reviewRuleCard: some View {
        CardView {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.successGreen)
                    .frame(width: 36, height: 36)
                    .background(Color.successGreen.opacity(0.12))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Prepare, then review")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text("MCP cart updates are safe to simulate. Checkout appears only after an explicit review screen.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct MCPHubView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppPageHeader(
                    title: "Swiggy MCP",
                    subtitle: "How FitOrder maps fitness intent into Food + Instamart execution."
                )
                architectureCard
                privacyCard
                JourneyCard(
                    title: "Progress Insight",
                    subtitle: "Why planned ordering can become repeat Food + Instamart usage",
                    icon: "chart.line.uptrend.xyaxis",
                    cta: "Read insight",
                    tint: .warningOrange,
                    route: .progressInsight
                )
                DisclaimerFooter(text: "Demo only. Swiggy MCP calls are mocked in this prototype.")
            }
            .padding(AppSpacing.screen)
            .padding(.top, 6)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var architectureCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(
                    title: "How MCP fits",
                    subtitle: "Food + Instamart mapped to your training phase. Structured ordering, not impulse ordering."
                )

                HStack(spacing: 8) {
                    FlowStep(title: "Intent", icon: "person.fill.checkmark")
                    FlowArrow()
                    FlowStep(title: "AI Plan", icon: "sparkles")
                    FlowArrow()
                    FlowStep(title: "Food / Cart", icon: "bag.fill")
                    FlowArrow()
                    FlowStep(title: "Confirm", icon: "checkmark.circle.fill")
                }
            }
        }
    }

    private var privacyCard: some View {
        CardView {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.headline)
                    .foregroundStyle(Color.successGreen)
                    .frame(width: 30, height: 30)
                    .background(Color.successGreen.opacity(0.12))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Privacy-first demo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text("We only use goal preferences in this prototype. No payment data, no health records, no scraping.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct AppPageHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.primaryText)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct QuickActionLink: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
            .softShadow()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct PhaseMiniCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.swiggyOrange)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
            Text(subtitle)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .softShadow()
    }
}

private struct FlowStep: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.swiggyOrange)
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FlowArrow: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.mutedText)
            .frame(width: 10)
    }
}
