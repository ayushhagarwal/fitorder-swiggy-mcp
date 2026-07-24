import SwiftUI

struct FitOrderFuelPlanView: View {
    let session: DemoSession
    let showSubstitution: () -> Void
    let showReceipt: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
            FitOrderSectionHeading(
                eyebrow: "Tonight’s fuel plan",
                title: "Recovery now. Breakfast handled.",
                subtitle: "Nutrition is a FitOrder estimate. Commerce values come directly from the local Swiggy MCP stub."
            )

            if let meal = session.recommendedMeal, let cart = session.foodCart {
                mealCard(meal: meal, cart: cart)
            }

            if let cart = session.instamartCart {
                groceryCard(cart: cart)
            }

            if let proposal = session.substitutionProposal, !session.hasAcceptedSubstitution {
                Button(action: showSubstitution) {
                    HStack(spacing: FitOrderDesign.Spacing.sm) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("One smart swap needs approval")
                                .font(.subheadline.weight(.bold))
                            Text("\(proposal.original.name) is unavailable")
                                .font(.caption)
                                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(FitOrderDesign.Palette.plum)
                    .padding(FitOrderDesign.Spacing.md)
                    .background(
                        FitOrderDesign.Palette.plumSoft,
                        in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }

            whyThisFits

            Button(action: showReceipt) {
                HStack {
                    Label(
                        "\(session.completedToolCount) MCP actions completed",
                        systemImage: "point.3.connected.trianglepath.dotted"
                    )
                    Spacer()
                    Text("Inspect")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FitOrderDesign.Palette.plum)
                .padding(.vertical, FitOrderDesign.Spacing.xs)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows tool order, result summaries, latency, and masked sessions")
        }
    }

    private func mealCard(
        meal: MealCandidateSnapshot,
        cart: CartSnapshot
    ) -> some View {
        FitOrderElevatedCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image("PaneerBowl")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 188)
                        .clipped()
                    LinearGradient(
                        colors: [.black.opacity(0.24), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    FitOrderServiceBadge(service: .food)
                        .padding(FitOrderDesign.Spacing.md)
                }

                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        FitOrderVegMarker()
                        Text(meal.name)
                            .font(.title3.weight(.black))
                            .foregroundStyle(FitOrderDesign.Palette.ink)
                        Spacer(minLength: FitOrderDesign.Spacing.xs)
                        Label(String(format: "%.1f", meal.rating), systemImage: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(FitOrderDesign.Palette.success, in: Capsule())
                    }

                    Text("\(meal.restaurantName) · with high-protein curd")
                        .font(.subheadline)
                        .foregroundStyle(FitOrderDesign.Palette.secondaryInk)

                    Divider()

                    HStack {
                        FitOrderCommerceMetadata(
                            deliveryText: "\(cart.deliveryMinutes) min",
                            priceText: "₹\(cart.total)"
                        )
                        Spacer()
                        if let nutrition = meal.nutritionEstimate {
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("\(nutrition.proteinGrams)g protein")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(FitOrderDesign.Palette.plum)
                                Text(nutrition.sourceLabel)
                                    .font(.caption2)
                                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                            }
                        }
                    }
                }
                .padding(FitOrderDesign.Spacing.md)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func groceryCard(cart: CartSnapshot) -> some View {
        FitOrderElevatedCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image("PantryRefill")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 188)
                        .clipped()
                    FitOrderServiceBadge(service: .instamart)
                        .padding(FitOrderDesign.Spacing.md)
                }

                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                    Text("Five-day breakfast refill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(FitOrderDesign.Palette.ink)

                    Text(
                        cart.items
                            .map(\.name)
                            .joined(separator: " · ")
                    )
                    .font(.subheadline)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    .lineLimit(3)

                    if session.hasAcceptedSubstitution,
                       let proposal = session.substitutionProposal {
                        Label(
                            "\(proposal.replacement.name) approved · saved ₹\(proposal.savings)",
                            systemImage: "checkmark.circle.fill"
                        )
                        .font(.caption.weight(.bold))
                        .foregroundStyle(FitOrderDesign.Palette.success)
                    }

                    Divider()

                    FitOrderCommerceMetadata(
                        deliveryText: "\(cart.deliveryMinutes) min",
                        priceText: "₹\(cart.total)"
                    )
                }
                .padding(FitOrderDesign.Spacing.md)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var whyThisFits: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                HStack {
                    Image(systemName: "scope")
                        .foregroundStyle(FitOrderDesign.Palette.plum)
                    Text("Why this fits")
                        .font(.headline.weight(.black))
                }

                insight(
                    symbol: "figure.strengthtraining.traditional",
                    title: "Recovery protein",
                    detail: "Paneer and curd close tonight’s protein gap with a vegetarian option."
                )
                insight(
                    symbol: "bolt.horizontal.fill",
                    title: "Easy carbohydrates",
                    detail: "Rice, oats, and bananas replenish glycogen without turning dinner into prep work."
                )
                insight(
                    symbol: "indianrupeesign.circle.fill",
                    title: "Budget protected",
                    detail: "Both authoritative carts total ₹\(session.combinedTotal), leaving ₹\(max(session.remainingBudget ?? 0, 0)) inside the ₹\(session.intent?.budgetRupees ?? 900) cap."
                )

                HStack {
                    Text("NUTRITION")
                    Spacer()
                    Text("FITORDER ESTIMATE")
                }
                .font(.caption2.weight(.black))
                .tracking(0.6)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
        }
    }

    private func insight(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(FitOrderDesign.Palette.swiggyOrange)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct FitOrderSubstitutionSheet: View {
    let proposal: SubstitutionProposal
    let isApplying: Bool
    let accept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
            HStack {
                Image(systemName: "basket.fill")
                    .font(.title2)
                    .foregroundStyle(FitOrderDesign.Palette.instamartBlue)
                Text("Stock changed. Your plan doesn’t have to.")
                    .font(.title2.weight(.black))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
            }

            Text(proposal.reason)
                .font(.subheadline)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)

            VStack(spacing: 0) {
                substitutionRow(
                    title: proposal.original.name,
                    detail: proposal.original.size,
                    price: proposal.original.price,
                    available: false
                )
                Divider()
                substitutionRow(
                    title: proposal.replacement.name,
                    detail: proposal.replacement.size,
                    price: proposal.replacement.price,
                    available: true
                )
            }
            .padding(.horizontal, FitOrderDesign.Spacing.md)
            .background(
                FitOrderDesign.Palette.surface,
                in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.card, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: FitOrderDesign.Radius.card, style: .continuous)
                    .stroke(FitOrderDesign.Palette.divider)
            }

            Label(
                "Same breakfast role · saves ₹\(proposal.savings)",
                systemImage: "arrow.down.right.circle.fill"
            )
            .font(.headline.weight(.bold))
            .foregroundStyle(FitOrderDesign.Palette.success)

            Spacer(minLength: 0)

            Button(action: accept) {
                if isApplying {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Accept high-protein curd", systemImage: "checkmark")
                }
            }
            .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.instamartBlue))
            .disabled(isApplying)
            .accessibilityHint("Updates the authoritative Instamart cart")

            Text("Nothing changes until you approve it.")
                .font(.caption)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                .frame(maxWidth: .infinity)
        }
        .padding(FitOrderDesign.Spacing.screen)
        .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
    }

    private func substitutionRow(
        title: String,
        detail: String,
        price: Int,
        available: Bool
    ) -> some View {
        HStack(spacing: FitOrderDesign.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        available
                            ? FitOrderDesign.Palette.instamartBlue.opacity(0.12)
                            : FitOrderDesign.Palette.failure.opacity(0.08)
                    )
                Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(
                        available
                            ? FitOrderDesign.Palette.success
                            : FitOrderDesign.Palette.failure
                    )
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("₹\(price)")
                    .font(.subheadline.weight(.black))
                Text(available ? "IN STOCK" : "UNAVAILABLE")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(
                        available
                            ? FitOrderDesign.Palette.success
                            : FitOrderDesign.Palette.failure
                    )
            }
        }
        .padding(.vertical, FitOrderDesign.Spacing.md)
        .foregroundStyle(FitOrderDesign.Palette.ink)
        .accessibilityElement(children: .combine)
    }
}

struct FitOrderReviewFlow: View {
    let session: DemoSession
    let close: () -> Void
    let finish: () -> Void

    @State private var showsReceipt = false

    var body: some View {
        NavigationStack {
            Group {
                if session.phase == .tracking {
                    FitOrderTrackingDashboard(
                        session: session,
                        showsCloseAction: true,
                        close: finish
                    )
                } else {
                    reviewContent
                }
            }
            .background(FitOrderDesign.Palette.canvas.ignoresSafeArea())
            .toolbar {
                if session.phase != .tracking {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.subheadline.weight(.black))
                        }
                        .accessibilityLabel("Close cart review")
                    }

                    ToolbarItem(placement: .principal) {
                        Text("Review 2 carts")
                            .font(.headline.weight(.black))
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsReceipt = true
                        } label: {
                            Image(systemName: "terminal")
                        }
                        .accessibilityLabel("How FitOrder prepared this")
                    }
                }
            }
        }
        .tint(FitOrderDesign.Palette.plum)
        .sheet(isPresented: $showsReceipt) {
            FitOrderReceiptSheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var reviewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.lg) {
                reviewHeader

                if session.phase == .refreshing {
                    authoritativeStatus(
                        symbol: "arrow.triangle.2.circlepath",
                        title: "Refreshing both carts",
                        detail: "Confirmation unlocks only after Food and Instamart return authoritative snapshots.",
                        tint: FitOrderDesign.Palette.instamartBlue,
                        showsProgress: true
                    )
                } else if session.requiresCartReconfirmation {
                    cartChangeNotice
                } else if session.cartsAreAuthoritative {
                    authoritativeStatus(
                        symbol: "checkmark.shield.fill",
                        title: "Prices and stock refreshed",
                        detail: "Both carts are authoritative and ready for your explicit confirmation.",
                        tint: FitOrderDesign.Palette.success
                    )
                }

                if let cart = session.foodCart {
                    FitOrderCartCard(cart: cart, service: .food)
                }
                if let cart = session.instamartCart {
                    FitOrderCartCard(cart: cart, service: .instamart)
                }

                if session.failure != nil {
                    FitOrderFailureCard(session: session)
                }

                Button {
                    showsReceipt = true
                } label: {
                    HStack {
                        Label("How FitOrder prepared this", systemImage: "point.3.connected.trianglepath.dotted")
                        Spacer()
                        Image(systemName: "chevron.up")
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

                FitOrderEnvironmentBadge()
                    .frame(maxWidth: .infinity)
            }
            .padding(FitOrderDesign.Spacing.screen)
            .padding(.bottom, 112)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            confirmationArea
        }
    }

    private var reviewHeader: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
            Text("One intent. Two checkouts.")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(FitOrderDesign.Palette.ink)
            Text("Food and Instamart remain separate, with their own address, items, fees, ETA, and order call.")
                .font(.subheadline)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)

            HStack {
                Text("COMBINED")
                    .font(.caption.weight(.black))
                    .tracking(0.8)
                Spacer()
                Text("₹\(session.combinedTotal)")
                    .font(.title.weight(.black))
            }
            .foregroundStyle(FitOrderDesign.Palette.plum)
            .padding(.top, FitOrderDesign.Spacing.xs)
        }
    }

    private func authoritativeStatus(
        symbol: String,
        title: String,
        detail: String,
        tint: Color,
        showsProgress: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
            if showsProgress {
                ProgressView()
                    .tint(tint)
            } else {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FitOrderDesign.Spacing.md)
        .background(
            tint.opacity(0.09),
            in: RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    private var cartChangeNotice: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.sm) {
                Label("A cart changed during refresh", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FitOrderDesign.Palette.failure)
                ForEach(session.cartChanges) { change in
                    Text(
                        "\(change.service.displayName): ₹\(change.previousTotal) → ₹\(change.currentTotal)"
                    )
                    .font(.subheadline.weight(.semibold))
                }
                Text("Review the refreshed amount and reconfirm before the slider unlocks.")
                    .font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                Button("Accept refreshed carts") {
                    session.acceptRefreshedCartChanges()
                }
                .buttonStyle(FitOrderPrimaryActionStyle(tint: FitOrderDesign.Palette.failure))
            }
        }
    }

    @ViewBuilder
    private var confirmationArea: some View {
        VStack(spacing: FitOrderDesign.Spacing.xs) {
            if session.phase == .confirming {
                HStack(spacing: FitOrderDesign.Spacing.sm) {
                    ProgressView()
                    Text("Placing two separate demo orders…")
                        .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(.ultraThinMaterial, in: Capsule())
            } else {
                FitOrderConfirmationSlider(
                    isEnabled: session.canConfirm,
                    action: {
                        Task { await session.confirmOrders() }
                    }
                )
            }

            Text(
                session.canConfirm
                    ? "Explicit confirmation · no real order will be placed"
                    : "Waiting for both authoritative cart refreshes"
            )
            .font(.caption2.weight(.semibold))
            .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
        }
        .padding(.horizontal, FitOrderDesign.Spacing.screen)
        .padding(.top, FitOrderDesign.Spacing.sm)
        .padding(.bottom, FitOrderDesign.Spacing.xs)
        .background(.ultraThinMaterial)
    }
}

struct FitOrderCartCard: View {
    let cart: CartSnapshot
    let service: FitOrderService

    var body: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                HStack {
                    FitOrderServiceBadge(service: service)
                    Spacer()
                    Text("\(cart.deliveryMinutes) min")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(service.tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(cart.title)
                        .font(.title3.weight(.black))
                        .foregroundStyle(FitOrderDesign.Palette.ink)
                    if let merchant = cart.merchantName {
                        Text(merchant)
                            .font(.subheadline)
                            .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    }
                    Label(cart.address.displayLine, systemImage: "house.fill")
                        .font(.caption)
                        .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                        .lineLimit(2)
                }

                Divider()

                ForEach(cart.items) { item in
                    HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
                        FitOrderVegMarker()
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(FitOrderDesign.Palette.ink)
                            if let detail = item.detail {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                            }
                            if let original = item.substitutedFor {
                                Label("Replaces \(original)", systemImage: "arrow.triangle.swap")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(FitOrderDesign.Palette.success)
                            }
                        }
                        Spacer()
                        Text("×\(item.quantity)")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(service.tint.opacity(0.1), in: Capsule())
                        Text("₹\(item.totalPrice)")
                            .font(.subheadline.weight(.bold))
                            .frame(minWidth: 48, alignment: .trailing)
                    }
                    .accessibilityElement(children: .combine)
                }

                Divider()

                amountRow("Item subtotal", cart.subtotal)
                if cart.discount > 0 {
                    amountRow("Savings \(cart.couponCode.map { "· \($0)" } ?? "")", -cart.discount)
                        .foregroundStyle(FitOrderDesign.Palette.success)
                }
                amountRow("Delivery fee", cart.deliveryFee)
                amountRow("Handling fee", cart.handlingFee)
                if cart.taxes > 0 {
                    amountRow("Taxes", cart.taxes)
                }

                HStack {
                    Text("Total")
                    Spacer()
                    Text("₹\(cart.total)")
                }
                .font(.headline.weight(.black))
                .foregroundStyle(FitOrderDesign.Palette.ink)

                HStack {
                    Text("REVISION \(cart.revision)")
                    Spacer()
                    Text("SWIGGY MCP DATA")
                }
                .font(.caption2.weight(.black))
                .tracking(0.6)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            }
        }
    }

    private func amountRow(_ label: String, _ amount: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(amount < 0 ? "−₹\(abs(amount))" : "₹\(amount)")
        }
        .font(.caption)
    }
}

struct FitOrderConfirmationSlider: View {
    let isEnabled: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGFloat = 0
    @State private var hasTriggered = false

    private let controlSize: CGFloat = 54
    private let inset: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            let maximum = max(proxy.size.width - controlSize - (inset * 2), 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        isEnabled
                            ? FitOrderDesign.Palette.plum
                            : FitOrderDesign.Palette.secondaryInk.opacity(0.22)
                    )

                Text("Slide to confirm 2 demo orders")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(isEnabled ? 0.96 : 0.62))
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 42)

                ZStack {
                    Circle().fill(.white)
                    Image(systemName: isEnabled ? "chevron.right.2" : "lock.fill")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(
                            isEnabled
                                ? FitOrderDesign.Palette.swiggyOrange
                                : FitOrderDesign.Palette.secondaryInk
                        )
                }
                .frame(width: controlSize, height: controlSize)
                .offset(x: inset + min(max(dragOffset, 0), maximum))
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onChanged { value in
                            guard isEnabled, !hasTriggered else { return }
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            guard isEnabled, !hasTriggered else { return }
                            let finalOffset = min(max(value.translation.width, 0), maximum)
                            if finalOffset >= maximum * 0.78 {
                                hasTriggered = true
                                dragOffset = maximum
                                FitOrderHaptics.play(.success)
                                action()
                            } else {
                                withAnimation(
                                    reduceMotion
                                        ? nil
                                        : .spring(response: 0.34, dampingFraction: 0.72)
                                ) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .frame(height: controlSize + inset * 2)
        .accessibilityRepresentation {
            Button {
                guard isEnabled, !hasTriggered else { return }
                hasTriggered = true
                FitOrderHaptics.play(.success)
                action()
            } label: {
                Text("Confirm two demo orders")
            }
            .disabled(!isEnabled)
            .accessibilityValue(isEnabled ? "Ready" : "Locked until both carts refresh")
            .accessibilityHint("Confirms both seeded demo orders; no real order is placed")
        }
    }
}
