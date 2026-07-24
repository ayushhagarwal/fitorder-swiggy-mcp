import SwiftUI

enum FitOrderTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case plan = "Plan"
    case activity = "Activity"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .today: "bolt.fill"
        case .plan: "calendar.badge.clock"
        case .activity: "waveform.path.ecg"
        }
    }
}

struct FitOrderRootView: View {
    @State private var session = DemoSession()
    @State private var selectedTab: FitOrderTab = .today
    @State private var showsDebugControls = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FitOrderTodayView(
                    session: session,
                    showsDebugControls: $showsDebugControls,
                    openActivity: { selectedTab = .activity }
                )
            }
            .tag(FitOrderTab.today)
            .tabItem { Label(FitOrderTab.today.rawValue, systemImage: FitOrderTab.today.symbol) }

            NavigationStack {
                FitOrderPlanView(session: session)
            }
            .tag(FitOrderTab.plan)
            .tabItem { Label(FitOrderTab.plan.rawValue, systemImage: FitOrderTab.plan.symbol) }

            NavigationStack {
                FitOrderActivityView(session: session)
            }
            .tag(FitOrderTab.activity)
            .tabItem { Label(FitOrderTab.activity.rawValue, systemImage: FitOrderTab.activity.symbol) }
        }
        .tint(FitOrderDesign.Palette.swiggyOrange)
        .preferredColorScheme(.light)
        .task {
            await session.reset()
        }
        .sheet(isPresented: $showsDebugControls) {
            FitOrderDebugSheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct FitOrderTodayView: View {
    let session: DemoSession
    @Binding var showsDebugControls: Bool
    let openActivity: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsSubstitution = false
    @State private var showsReview = false
    @State private var showsReceipt = false

    var body: some View {
        ZStack {
            FitOrderDesign.Palette.canvas.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: FitOrderDesign.Spacing.lg) {
                    topBar
                    performanceHero

                    if session.intent != nil {
                        pinnedIntent
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        requestComposer
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }

                    phaseContent
                }
                .padding(.horizontal, FitOrderDesign.Spacing.screen)
                .padding(.bottom, session.canReview ? 112 : 30)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if session.canReview {
                reviewCapsule
                    .padding(.horizontal, FitOrderDesign.Spacing.screen)
                    .padding(.bottom, FitOrderDesign.Spacing.xs)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.84),
            value: session.phase
        )
        .onChange(of: session.phase) { _, phase in
            if phase == .tracking {
                FitOrderHaptics.play(.success)
            }
        }
        .sheet(isPresented: $showsSubstitution) {
            if let proposal = session.substitutionProposal {
                FitOrderSubstitutionSheet(
                    proposal: proposal,
                    isApplying: session.phase.isWorking,
                    accept: {
                        Task {
                            await session.acceptProposedSubstitution()
                            if session.hasAcceptedSubstitution {
                                FitOrderHaptics.play(.success)
                                showsSubstitution = false
                            }
                        }
                    }
                )
                .presentationDetents([.height(510), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(!session.hasAcceptedSubstitution)
            }
        }
        .fullScreenCover(isPresented: $showsReview) {
            FitOrderReviewFlow(
                session: session,
                close: { showsReview = false },
                finish: {
                    showsReview = false
                    openActivity()
                }
            )
        }
        .sheet(isPresented: $showsReceipt) {
            FitOrderReceiptSheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Good evening, Ayush")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                Label("Home · Indiranagar, Bengaluru", systemImage: "house.fill")
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }

            Spacer()

            Button {
                showsDebugControls = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FitOrderDesign.Palette.plum)
                    .frame(width: 42, height: 42)
                    .fitOrderFloatingCapsule(interactive: true)
            }
            .accessibilityLabel("Open demo controls")
        }
        .padding(.top, FitOrderDesign.Spacing.xs)
    }

    private var performanceHero: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HeroEnergy")
                .resizable()
                .scaledToFill()
                .frame(height: 310)
                .clipped()

            LinearGradient(
                colors: [.clear, FitOrderDesign.Palette.plum.opacity(0.18), .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                HStack {
                    Label("DAY 51 OF 60", systemImage: "figure.run")
                        .font(.caption.weight(.black))
                        .tracking(0.9)
                    Spacer()
                    Text("RECOVERY")
                        .font(.caption2.weight(.black))
                        .tracking(0.9)
                }
                .foregroundStyle(.white.opacity(0.9))

                Text("HYROX in 9 days")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tonight is about rebuilding, not guessing.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: FitOrderDesign.Spacing.sm) {
                    heroMetric(value: "34/130g", label: "protein")
                    heroMetric(value: "₹900", label: "budget")
                }
            }
            .padding(FitOrderDesign.Spacing.lg)
        }
        .frame(height: 310)
        .clipShape(RoundedRectangle(cornerRadius: FitOrderDesign.Radius.hero, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 74, height: 74)
                .blur(radius: 14)
                .offset(x: 16, y: -8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "HYROX in 9 days. Day 51 of 60. Recovery session. 34 of 130 grams protein, 900 rupee budget."
        )
    }

    private func heroMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.black))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.64))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, FitOrderDesign.Spacing.sm)
        .padding(.vertical, FitOrderDesign.Spacing.xs)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private var requestComposer: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                FitOrderSectionHeading(
                    eyebrow: "Your performance concierge",
                    title: "What should tonight solve?",
                    subtitle: "FitOrder turns one supported request into two separate, inspectable carts."
                )

                TextEditor(
                    text: Binding(
                        get: { session.prompt },
                        set: { session.updatePrompt($0) }
                    )
                )
                .font(.body.weight(.medium))
                .foregroundStyle(FitOrderDesign.Palette.ink)
                .scrollContentBackground(.hidden)
                .padding(FitOrderDesign.Spacing.sm)
                .frame(minHeight: 112)
                .background(
                    FitOrderDesign.Palette.plum.opacity(0.055),
                    in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
                )
                .accessibilityLabel("Fuel planning request")

                Button {
                    FitOrderHaptics.play(.softImpact)
                    Task { await session.planFuel() }
                } label: {
                    Label("Plan my fuel", systemImage: "sparkles")
                }
                .buttonStyle(FitOrderPrimaryActionStyle())
                .disabled(session.phase.isWorking)
                .accessibilityHint("Builds separate Food and Instamart demo carts using the local MCP server")

                FitOrderEnvironmentBadge()
            }
        }
    }

    private var pinnedIntent: some View {
        FitOrderElevatedCard(padding: FitOrderDesign.Spacing.sm) {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundStyle(FitOrderDesign.Palette.plum)
                    Text(session.intent?.originalText ?? session.prompt)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FitOrderDesign.Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let intent = session.intent {
                    ScrollView(.horizontal) {
                        HStack(spacing: FitOrderDesign.Spacing.xs) {
                            ForEach(intent.displayTokens, id: \.self) { token in
                                FitOrderConstraintChip(title: token)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch session.phase {
        case .idle:
            EmptyView()
        case .understanding, .planning:
            FitOrderPlanningView(session: session)
        case .planReady:
            FitOrderFuelPlanView(
                session: session,
                showSubstitution: { showsSubstitution = true },
                showReceipt: { showsReceipt = true }
            )
        case .reviewing, .refreshing, .confirming:
            FitOrderFuelPlanView(
                session: session,
                showSubstitution: { showsSubstitution = true },
                showReceipt: { showsReceipt = true }
            )
        case .tracking:
            FitOrderTodayPayoffCard(openActivity: openActivity)
        case .failed:
            FitOrderFailureCard(session: session)
        }

        if session.failure != nil, session.phase != .failed {
            FitOrderFailureCard(session: session)
        }
    }

    private var reviewCapsule: some View {
        Button {
            FitOrderHaptics.play(.softImpact)
            showsReview = true
            Task { await session.beginReview() }
        } label: {
            HStack(spacing: FitOrderDesign.Spacing.sm) {
                ZStack {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .offset(x: -5)
                    Image(systemName: "basket.fill")
                        .offset(x: 6, y: 1)
                }
                .font(.subheadline)
                .foregroundStyle(FitOrderDesign.Palette.swiggyOrange)

                Text("Review 2 carts")
                    .font(.headline.weight(.bold))
                Spacer()
                Text("₹\(session.combinedTotal)")
                    .font(.headline.weight(.black))
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.black))
            }
            .foregroundStyle(FitOrderDesign.Palette.ink)
            .padding(.horizontal, FitOrderDesign.Spacing.lg)
            .frame(height: 62)
            .contentShape(Capsule())
            .fitOrderFloatingCapsule(tint: FitOrderDesign.Palette.swiggyOrange)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Review 2 carts, total ₹\(session.combinedTotal)")
    }
}

private struct FitOrderPlanningView: View {
    let session: DemoSession

    private let steps = [
        ("Resolving Home", "house.fill", "get_addresses"),
        ("Matching recovery meals", "fork.knife", "search_menu"),
        ("Checking frequently ordered groceries", "clock.arrow.circlepath", "your_go_to_items"),
        ("Validating availability", "checkmark.shield.fill", "search_products"),
        ("Building separate carts", "square.split.2x1.fill", "update_cart")
    ]

    var body: some View {
        VStack(spacing: FitOrderDesign.Spacing.lg) {
            FitOrderSectionHeading(
                eyebrow: "Intent understood",
                title: "Food and Instamart are planning in parallel",
                subtitle: "The animation follows genuine localhost tool calls and deterministic latency."
            )

            FitOrderElevatedCard {
                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: FitOrderDesign.Spacing.sm) {
                            status(for: step.2, index: index)
                            Image(systemName: step.1)
                                .frame(width: 22)
                                .foregroundStyle(FitOrderDesign.Palette.plum)
                            Text(step.0)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                        }
                        .padding(.vertical, FitOrderDesign.Spacing.sm)

                        if index < steps.count - 1 {
                            Divider().overlay(FitOrderDesign.Palette.divider)
                        }
                    }
                }
                .foregroundStyle(FitOrderDesign.Palette.ink)
            }

            HStack(spacing: FitOrderDesign.Spacing.md) {
                FitOrderSkeletonCard()
                FitOrderSkeletonCard()
            }
        }
    }

    @ViewBuilder
    private func status(for tool: String, index: Int) -> some View {
        let matching = session.toolTrace.first {
            $0.toolName == tool
                || (tool == "update_cart" && $0.toolName.contains("update"))
        }

        if let matching {
            switch matching.lifecycle {
            case .running:
                ProgressView().controlSize(.small)
            case .succeeded:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(FitOrderDesign.Palette.success)
            case .failed:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(FitOrderDesign.Palette.failure)
            }
        } else {
            Image(systemName: index == 0 ? "circle.dotted" : "circle")
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk.opacity(0.4))
        }
    }
}

struct FitOrderFailureCard: View {
    let session: DemoSession

    var body: some View {
        if let failure = session.failure {
            FitOrderElevatedCard {
                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(FitOrderDesign.Palette.failure)
                    Text(failure.title)
                        .font(.headline.weight(.bold))
                    Text(failure.message)
                        .font(.subheadline)
                        .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    Text(failure.recoverySuggestion)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FitOrderDesign.Palette.plum)

                    if failure.isRetryable {
                        Button {
                            Task { await session.retryLastAction() }
                        } label: {
                            Label("Retry safely", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.plum))
                    }
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

private struct FitOrderTodayPayoffCard: View {
    let openActivity: () -> Void

    var body: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(FitOrderDesign.Palette.success)
                Text("118/130g protein planned today")
                    .font(.title2.weight(.black))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                Text("One intent. Two Swiggy surfaces. A repeatable performance-commerce loop.")
                    .font(.subheadline)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                Button("View both demo orders", action: openActivity)
                    .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.success))
            }
        }
    }
}

#Preview {
    FitOrderRootView()
}
