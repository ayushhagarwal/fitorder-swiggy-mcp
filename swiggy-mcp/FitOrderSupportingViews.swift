import SwiftUI

struct FitOrderPlanView: View {
    let session: DemoSession

    private let phases = [
        ("DAYS 1–42", "Build capacity", "Consistent protein, balanced training fuel", false),
        ("DAYS 43–54", "Sharpen & recover", "Protect output while recovery demand rises", true),
        ("DAYS 55–60", "Race window", "Simple carbs, hydration, familiar meals", false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                HStack {
                    FitOrderEnvironmentBadge()
                    Spacer()
                    Text("DAY 51 / 60")
                        .font(.caption.weight(.black))
                        .tracking(0.7)
                        .foregroundStyle(FitOrderDesign.Palette.plum)
                }

                FitOrderSectionHeading(
                    eyebrow: "HYROX · 9 days",
                    title: "Your fuel schedule",
                    subtitle: "Commerce adapts to the training phase, while the plan remains understandable and repeatable."
                )

                phaseTimeline
                upcomingSchedule

                if session.foodCart != nil || session.instamartCart != nil {
                    generatedPlan
                } else {
                    emptyGeneratedPlan
                }
            }
            .padding(FitOrderDesign.Spacing.screen)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var phaseTimeline: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    HStack(alignment: .top, spacing: FitOrderDesign.Spacing.md) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(
                                        phase.3
                                            ? FitOrderDesign.Palette.swiggyOrange
                                            : FitOrderDesign.Palette.plumSoft
                                    )
                                Image(systemName: phase.3 ? "bolt.fill" : "checkmark")
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(
                                        phase.3
                                            ? .white
                                            : FitOrderDesign.Palette.plum
                                    )
                            }
                            .frame(width: 34, height: 34)

                            if index < phases.count - 1 {
                                Rectangle()
                                    .fill(FitOrderDesign.Palette.divider)
                                    .frame(width: 2, height: 64)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(phase.0)
                                    .font(.caption2.weight(.black))
                                    .tracking(0.7)
                                    .foregroundStyle(
                                        phase.3
                                            ? FitOrderDesign.Palette.swiggyOrange
                                            : FitOrderDesign.Palette.secondaryInk
                                    )
                                if phase.3 {
                                    Text("NOW")
                                        .font(.caption2.weight(.black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(
                                            FitOrderDesign.Palette.swiggyOrange,
                                            in: Capsule()
                                        )
                                }
                            }
                            Text(phase.1)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(FitOrderDesign.Palette.ink)
                            Text(phase.2)
                                .font(.caption)
                                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                        }
                        .padding(.bottom, FitOrderDesign.Spacing.md)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var upcomingSchedule: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
            Text("NEXT FIVE BREAKFASTS")
                .font(.caption.weight(.black))
                .tracking(0.8)
                .foregroundStyle(FitOrderDesign.Palette.plum)

            ScrollView(.horizontal) {
                HStack(spacing: FitOrderDesign.Spacing.sm) {
                    scheduleDay("SAT", "Oats + banana", "Recovery", isToday: true)
                    scheduleDay("SUN", "Curd oats", "Endurance")
                    scheduleDay("MON", "Banana bowl", "Strength")
                    scheduleDay("TUE", "Overnight oats", "Recovery")
                    scheduleDay("WED", "Oats + salts", "Intervals")
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func scheduleDay(
        _ day: String,
        _ meal: String,
        _ training: String,
        isToday: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) {
            Text(day)
                .font(.caption2.weight(.black))
                .tracking(0.7)
                .foregroundStyle(
                    isToday
                        ? FitOrderDesign.Palette.swiggyOrange
                        : FitOrderDesign.Palette.secondaryInk
                )
            Text(meal)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(FitOrderDesign.Palette.ink)
            Text(training)
                .font(.caption)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
        }
        .frame(width: 132, alignment: .leading)
        .padding(FitOrderDesign.Spacing.sm)
        .background(
            isToday
                ? FitOrderDesign.Palette.swiggyOrange.opacity(0.09)
                : FitOrderDesign.Palette.surface,
            in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
                .stroke(
                    isToday
                        ? FitOrderDesign.Palette.swiggyOrange.opacity(0.28)
                        : FitOrderDesign.Palette.divider
                )
        }
        .accessibilityElement(children: .combine)
    }

    private var generatedPlan: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TODAY’S GENERATED PLAN")
                            .font(.caption.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(FitOrderDesign.Palette.swiggyOrange)
                        Text("Recovery dinner + weekly refill")
                            .font(.headline.weight(.bold))
                    }
                    Spacer()
                    Text("₹\(session.combinedTotal)")
                        .font(.title3.weight(.black))
                }

                if let food = session.foodCart {
                    planRow(
                        service: .food,
                        title: food.title,
                        detail: "\(food.deliveryMinutes) min · ₹\(food.total)"
                    )
                }
                if let instamart = session.instamartCart {
                    planRow(
                        service: .instamart,
                        title: instamart.title,
                        detail: "\(instamart.items.count) items · ₹\(instamart.total)"
                    )
                }

                Label(
                    "₹\(max(session.remainingBudget ?? 0, 0)) remains inside tonight’s budget",
                    systemImage: "checkmark.seal.fill"
                )
                .font(.caption.weight(.bold))
                .foregroundStyle(FitOrderDesign.Palette.success)
            }
        }
    }

    private func planRow(
        service: FitOrderService,
        title: String,
        detail: String
    ) -> some View {
        HStack(spacing: FitOrderDesign.Spacing.sm) {
            Image(systemName: service.symbol)
                .foregroundStyle(service.tint)
                .frame(width: 30, height: 30)
                .background(service.tint.opacity(0.1), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var emptyGeneratedPlan: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(FitOrderDesign.Palette.plum)
                Text("Today’s commerce plan will appear here")
                    .font(.headline.weight(.bold))
                Text("Use the seeded request on Today to build a recovery meal and five-day breakfast refill.")
                    .font(.subheadline)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
        }
    }
}

struct FitOrderActivityView: View {
    let session: DemoSession
    @State private var showsReceipt = false

    var body: some View {
        Group {
            if session.foodOrder != nil || session.instamartOrder != nil {
                FitOrderTrackingDashboard(
                    session: session,
                    showsCloseAction: false,
                    close: {}
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                        FitOrderEnvironmentBadge()
                        FitOrderSectionHeading(
                            eyebrow: "Activity",
                            title: "Two services. One clear record.",
                            subtitle: "Food and Instamart orders will remain independent all the way through tracking."
                        )

                        FitOrderElevatedCard {
                            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(FitOrderDesign.Palette.plumSoft)
                                    Image(systemName: "shippingbox.and.arrow.backward.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(FitOrderDesign.Palette.plum)
                                }
                                .frame(width: 72, height: 72)

                                Text("No demo orders yet")
                                    .font(.title2.weight(.black))
                                Text("Plan tonight’s fuel, review both authoritative carts, then explicitly confirm to start the two tracking timelines.")
                                    .font(.subheadline)
                                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                            }
                        }

                        if !session.toolTrace.isEmpty {
                            Button {
                                showsReceipt = true
                            } label: {
                                Label(
                                    "Inspect \(session.completedToolCount) MCP actions",
                                    systemImage: "terminal.fill"
                                )
                            }
                            .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.plum))
                        }
                    }
                    .padding(FitOrderDesign.Spacing.screen)
                }
                .scrollIndicators(.hidden)
                .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsReceipt) {
            FitOrderReceiptSheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct FitOrderTrackingDashboard: View {
    let session: DemoSession
    let showsCloseAction: Bool
    let close: () -> Void

    @State private var showsReceipt = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                completionHero

                if let food = session.foodTracking {
                    FitOrderTrackingCard(snapshot: food, service: .food)
                } else {
                    trackingPlaceholder(service: .food)
                }

                if let instamart = session.instamartTracking {
                    FitOrderTrackingCard(snapshot: instamart, service: .instamart)
                } else {
                    trackingPlaceholder(service: .instamart)
                }

                Button {
                    showsReceipt = true
                } label: {
                    HStack {
                        Label(
                            "\(session.completedToolCount) traced MCP actions",
                            systemImage: "point.3.connected.trianglepath.dotted"
                        )
                        Spacer()
                        Text("Inspect")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FitOrderDesign.Palette.plum)
                    .padding(FitOrderDesign.Spacing.md)
                    .background(
                        FitOrderDesign.Palette.plumSoft,
                        in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
                    )
                }
                .buttonStyle(.plain)

                architectureClose

                if showsCloseAction {
                    Button("Done", action: close)
                        .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.success))
                }
            }
            .padding(FitOrderDesign.Spacing.screen)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(showsCloseAction)
        .sheet(isPresented: $showsReceipt) {
            FitOrderReceiptSheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var completionHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: FitOrderDesign.Radius.hero, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            FitOrderDesign.Palette.plum,
                            Color.black
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(FitOrderDesign.Palette.swiggyOrange.opacity(0.36))
                .frame(width: 190, height: 190)
                .blur(radius: 42)
                .offset(x: 220, y: -60)

            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.green)
                Text("118/130g")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("protein planned today")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Two demo orders confirmed independently.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(FitOrderDesign.Spacing.lg)
        }
        .frame(height: 250)
        .clipped()
        .accessibilityElement(children: .combine)
    }

    private func trackingPlaceholder(service: FitOrderService) -> some View {
        FitOrderElevatedCard {
            HStack(spacing: FitOrderDesign.Spacing.sm) {
                ProgressView()
                    .tint(service.tint)
                Text("Loading \(service.title) tracking…")
                    .font(.subheadline.weight(.bold))
            }
        }
    }

    private var architectureClose: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                Text("ONE INTENT. TWO SWIGGY SURFACES.")
                    .font(.caption.weight(.black))
                    .tracking(0.9)
                    .foregroundStyle(FitOrderDesign.Palette.swiggyOrange)
                Text("A repeatable performance-commerce loop.")
                    .font(.title2.weight(.black))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: FitOrderDesign.Spacing.xs) {
                        architectureChip("Native SwiftUI")
                        architectureChip("Food + Instamart MCP")
                        architectureChip("Zero PII persisted")
                    }
                    VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) {
                        architectureChip("Native SwiftUI")
                        architectureChip("Food + Instamart MCP")
                        architectureChip("Zero PII persisted")
                    }
                }
                FitOrderEnvironmentBadge()
            }
        }
    }

    private func architectureChip(_ title: String) -> some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundStyle(FitOrderDesign.Palette.plum)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(FitOrderDesign.Palette.plumSoft, in: Capsule())
    }
}

struct FitOrderTrackingCard: View {
    let snapshot: TrackingSnapshot
    let service: FitOrderService

    var body: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                HStack {
                    FitOrderServiceBadge(service: service)
                    Spacer()
                    Text("\(snapshot.etaMinutes) min")
                        .font(.headline.weight(.black))
                        .foregroundStyle(service.tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(snapshot.headline)
                        .font(.title3.weight(.black))
                        .foregroundStyle(FitOrderDesign.Palette.ink)
                    Text(snapshot.orderID)
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                }

                ForEach(Array(snapshot.milestones.enumerated()), id: \.element.id) { index, milestone in
                    HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(milestoneColor(milestone.state))
                                .frame(width: 14, height: 14)
                            if index < snapshot.milestones.count - 1 {
                                Rectangle()
                                    .fill(FitOrderDesign.Palette.divider)
                                    .frame(width: 2, height: 38)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestone.title)
                                .font(.subheadline.weight(
                                    milestone.state == .current ? .bold : .medium
                                ))
                                .foregroundStyle(FitOrderDesign.Palette.ink)
                            if let detail = milestone.detail {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func milestoneColor(_ state: TrackingMilestoneState) -> Color {
        switch state {
        case .completed: FitOrderDesign.Palette.success
        case .current: service.tint
        case .upcoming: FitOrderDesign.Palette.secondaryInk.opacity(0.2)
        }
    }
}

struct FitOrderReceiptSheet: View {
    let session: DemoSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                    FitOrderSectionHeading(
                        eyebrow: "MCP receipt",
                        title: "How FitOrder prepared this",
                        subtitle: "Stable tool order, real localhost latency, concise result summaries, and masked session identifiers."
                    )

                    HStack(spacing: FitOrderDesign.Spacing.sm) {
                        FitOrderMetricChip(
                            value: "\(session.completedToolCount)",
                            label: "completed calls",
                            tint: FitOrderDesign.Palette.success
                        )
                        FitOrderMetricChip(
                            value: "\(foodToolCount)",
                            label: "Food actions",
                            tint: FitOrderDesign.Palette.swiggyOrange
                        )
                        FitOrderMetricChip(
                            value: "\(instamartToolCount)",
                            label: "Instamart actions",
                            tint: FitOrderDesign.Palette.instamartBlue
                        )
                    }

                    if session.toolTrace.isEmpty {
                        Text("Tool calls will appear here once planning starts.")
                            .font(.subheadline)
                            .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(session.toolTrace.sorted(by: { $0.sequence < $1.sequence })) { event in
                                VStack(spacing: FitOrderDesign.Spacing.xs) {
                                    FitOrderToolLifecycleRow(event: event)
                                    HStack {
                                        Text(event.server.displayName)
                                        if let latency = event.latencyMilliseconds {
                                            Text("· \(latency) ms")
                                        }
                                        if let masked = event.maskedSessionIdentifier {
                                            Text("· \(masked)")
                                        }
                                        Spacer()
                                    }
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                                }
                                .padding(.vertical, FitOrderDesign.Spacing.xs)

                                Divider()
                            }
                        }
                        .padding(.horizontal, FitOrderDesign.Spacing.md)
                        .background(
                            FitOrderDesign.Palette.surface,
                            in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.card, style: .continuous)
                        )
                    }

                    FitOrderEnvironmentBadge()
                }
                .padding(FitOrderDesign.Spacing.screen)
            }
            .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
            .navigationTitle("MCP receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var foodToolCount: Int {
        session.toolTrace.filter {
            $0.server == .food && $0.lifecycle == .succeeded
        }.count
    }

    private var instamartToolCount: Int {
        session.toolTrace.filter {
            $0.server == .instamart && $0.lifecycle == .succeeded
        }.count
    }
}

struct FitOrderDebugSheet: View {
    let session: DemoSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                    FitOrderSectionHeading(
                        eyebrow: "Recording controls",
                        title: "Deterministic demo scenarios",
                        subtitle: "These controls stay out of the customer journey and make every take repeatable."
                    )

                    FitOrderElevatedCard {
                        VStack(spacing: FitOrderDesign.Spacing.xs) {
                            ForEach(DemoScenario.allCases) { scenario in
                                Button {
                                    Task {
                                        await session.setDebugScenario(scenario)
                                        FitOrderHaptics.play(.selection)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(scenario.displayName)
                                                .font(.subheadline.weight(.bold))
                                            Text(scenarioDescription(scenario))
                                                .font(.caption)
                                                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                        Image(
                                            systemName:
                                                session.scenario == scenario
                                                ? "checkmark.circle.fill"
                                                : "circle"
                                        )
                                        .foregroundStyle(
                                            session.scenario == scenario
                                                ? FitOrderDesign.Palette.success
                                                : FitOrderDesign.Palette.secondaryInk.opacity(0.35)
                                        )
                                    }
                                    .padding(.vertical, FitOrderDesign.Spacing.xs)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(FitOrderDesign.Palette.ink)
                                .accessibilityValue(
                                    session.scenario == scenario ? "Selected" : "Not selected"
                                )
                            }
                        }
                    }

                    Button {
                        Task {
                            await session.reset()
                            FitOrderHaptics.play(.success)
                            dismiss()
                        }
                    } label: {
                        Label("Reset golden take", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.plum))

                    Text("Reset clears server-side carts, orders, stock, coupons, and tracking for this demo session. The seeded address is never persisted by the app.")
                        .font(.caption)
                        .foregroundStyle(FitOrderDesign.Palette.secondaryInk)

                    FitOrderEnvironmentBadge()
                }
                .padding(FitOrderDesign.Spacing.screen)
            }
            .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
            .navigationTitle("Demo controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func scenarioDescription(_ scenario: DemoScenario) -> String {
        switch scenario {
        case .goldenPath:
            "₹828 total, yogurt substitution, dual tracking"
        case .serverUnavailable:
            "Polished retry state without local fixture fallback"
        case .cartChanged:
            "Authoritative refresh requires reconfirmation"
        case .ambiguousCheckout:
            "Order history is queried before any retry"
        }
    }
}
