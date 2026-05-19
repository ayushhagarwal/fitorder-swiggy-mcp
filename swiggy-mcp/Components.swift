import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(.white)
            .background(Color.swiggyOrange)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(Color.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct CardView<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
        .softShadow()
    }
}

struct PillView: View {
    let title: String
    var icon: String? = nil
    var tint: Color = .swiggyOrange

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
            }
            Text(title)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(tint.opacity(0.11))
        .clipShape(Capsule())
    }
}

struct MacroChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(minWidth: 66, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.primaryText)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MCPFlowRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.successGreen)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryText)
            Spacer()
            Text("simulated")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.mutedText)
        }
        .padding(.vertical, 6)
    }
}

struct OptionPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            selection = option
                        }
                    } label: {
                        Text(option)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(selection == option ? .white : Color.primaryText)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .background(selection == option ? Color.swiggyOrange : Color.appBackground)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: width, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct JourneyCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let cta: String
    let tint: Color
    let route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            CardView {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(tint.opacity(0.13))
                        Image(systemName: icon)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(tint)
                    }
                    .frame(width: 42, height: 42)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                            .lineSpacing(2)
                        Text(cta)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.swiggyOrange)
                            .padding(.top, 2)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.mutedText)
                        .padding(.top, 6)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct MealCard: View {
    let meal: MealRecommendation

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meal.restaurant)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                        Text(meal.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    RatingBadge(rating: meal.rating)
                }

                HStack(spacing: 12) {
                    Label("\(meal.deliveryMinutes) mins", systemImage: "clock")
                    Text("₹\(meal.price)")
                        .font(.caption.weight(.bold))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        MacroChip(label: "Protein", value: "\(meal.protein)g")
                        MacroChip(label: "Calories", value: "\(meal.calories)")
                        MacroChip(label: "Carbs", value: "\(meal.carbs)g")
                        MacroChip(label: "Fat", value: "\(meal.fat)g")
                    }
                }

                FlowLayout(spacing: 8) {
                    ForEach(meal.tags, id: \.self) { tag in
                        PillView(title: tag, tint: tag == "Budget" ? .offerGreen : .swiggyOrange)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Why this works")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                    Text(meal.why)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink(value: AppRoute.foodCart(meal)) {
                    HStack {
                        Text("Add to demo cart")
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

                Text("Order fulfilled via Swiggy")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.mutedText)
            }
        }
    }
}

struct RatingBadge: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(Color.ratingYellow)
            Text(String(format: "%.1f", rating))
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryText)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color.appBackground)
        .clipShape(Capsule())
    }
}

struct CartRow: View {
    let title: String
    var subtitle: String? = nil
    let amount: String
    var amountColor: Color = .primaryText

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryText)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            Spacer()
            Text(amount)
                .font(.caption.weight(.bold))
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 6)
    }
}

struct DisclaimerFooter: View {
    var text: String = "Prices, availability and delivery time are simulated for demo."

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.mutedText)
            Text(text)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

struct DemoScreen<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    PillView(title: "Demo flow · Swiggy MCP simulated", icon: "sparkles")
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 4)

                content
            }
            .padding(AppSpacing.screen)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
