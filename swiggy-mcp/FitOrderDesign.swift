import CoreHaptics
import SwiftUI
import UIKit
// MARK: - Semantic tokens
enum FitOrderDesign {
    enum Palette {
        static let canvas = Color(red: 1, green: 0.97, blue: 0.93)
        static let surface = Color.white
        static let plum = Color(red: 0.24, green: 0.07, blue: 0.22)
        static let plumSoft = Color(red: 0.95, green: 0.90, blue: 0.94)
        static let swiggyOrange = Color(red: 0.99, green: 0.42, blue: 0.09)
        static let instamartBlue = Color(red: 0.10, green: 0.48, blue: 0.91)
        static let success = Color(red: 0.08, green: 0.55, blue: 0.32)
        static let failure = Color(red: 0.78, green: 0.16, blue: 0.19)
        static let ink = Color(red: 0.14, green: 0.11, blue: 0.15)
        static let secondaryInk = Color(red: 0.39, green: 0.35, blue: 0.40)
        static let divider = Color.black.opacity(0.08)
    }
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let screen: CGFloat = 20
    }
    enum Radius {
        static let compact: CGFloat = 12
        static let chip: CGFloat = 14
        static let card: CGFloat = 24
        static let hero: CGFloat = 30
    }
    enum Shadow {
        static let color = Color.black.opacity(0.09)
        static let radius: CGFloat = 18
        static let y: CGFloat = 8
    }
}
// MARK: - Shared components
struct FitOrderEnvironmentBadge: View {
    var body: some View {
        Label("Local MCP · Seeded data · No real orders", systemImage: "terminal.fill")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(FitOrderDesign.Palette.plum)
            .padding(.horizontal, FitOrderDesign.Spacing.sm)
            .padding(.vertical, FitOrderDesign.Spacing.xs)
            .background(FitOrderDesign.Palette.plumSoft, in: Capsule())
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Demo environment. Local MCP, seeded data, no real orders.")
    }
}
struct FitOrderSectionHeading: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(FitOrderDesign.Palette.swiggyOrange)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(FitOrderDesign.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
struct FitOrderConstraintChip: View {
    let title: String
    var symbol: String? = nil
    var tint = FitOrderDesign.Palette.plum

    var body: some View {
        HStack(spacing: FitOrderDesign.Spacing.xs) {
            if let symbol {
                Image(systemName: symbol).imageScale(.small).accessibilityHidden(true)
            }
            Text(title).fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint)
        .padding(.horizontal, FitOrderDesign.Spacing.sm)
        .padding(.vertical, FitOrderDesign.Spacing.xs)
        .background(tint.opacity(0.10), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}
struct FitOrderMetricChip: View {
    let value: String
    let label: String
    var progress: Double? = nil
    var tint = FitOrderDesign.Palette.plum

    var body: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) {
            Text(value).font(.headline.weight(.bold))
                .foregroundStyle(FitOrderDesign.Palette.ink)
            Text(label).font(.caption)
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
            if let progress {
                ProgressView(value: min(max(progress, 0), 1))
                    .tint(tint).accessibilityHidden(true)
            }
        }
        .padding(FitOrderDesign.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.08), in: RoundedRectangle(
            cornerRadius: FitOrderDesign.Radius.compact, style: .continuous
        ))
        .accessibilityElement(children: .combine)
        .accessibilityValue(progress.map { "\(Int(min(max($0, 0), 1) * 100)) percent" } ?? "")
    }
}
enum FitOrderService: Equatable {
    case food, instamart
    var title: String { self == .food ? "Swiggy Food" : "Instamart" }
    var symbol: String { self == .food ? "takeoutbag.and.cup.and.straw.fill" : "basket.fill" }
    var tint: Color {
        self == .food ? FitOrderDesign.Palette.swiggyOrange : FitOrderDesign.Palette.instamartBlue
    }
}
struct FitOrderServiceBadge: View {
    let service: FitOrderService
    var body: some View {
        Label(service.title, systemImage: service.symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(service.tint)
            .padding(.horizontal, FitOrderDesign.Spacing.sm)
            .padding(.vertical, FitOrderDesign.Spacing.xs)
            .background(service.tint.opacity(0.11), in: Capsule())
            .accessibilityLabel(service.title)
    }
}
struct FitOrderElevatedCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = FitOrderDesign.Spacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    var body: some View {
        content.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FitOrderDesign.Palette.surface, in: RoundedRectangle(
                cornerRadius: FitOrderDesign.Radius.card, style: .continuous
            ))
            .overlay {
                RoundedRectangle(cornerRadius: FitOrderDesign.Radius.card, style: .continuous)
                    .stroke(FitOrderDesign.Palette.divider, lineWidth: 1)
            }
            .shadow(color: FitOrderDesign.Shadow.color,
                    radius: FitOrderDesign.Shadow.radius, y: FitOrderDesign.Shadow.y)
    }
}
struct FitOrderVegMarker: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(FitOrderDesign.Palette.success, lineWidth: 1.5)
            Circle().fill(FitOrderDesign.Palette.success).padding(3.5)
        }
        .frame(width: 16, height: 16)
        .accessibilityLabel("Vegetarian")
    }
}
struct FitOrderCommerceMetadata: View {
    let deliveryText: String
    let priceText: String
    var source = "Swiggy MCP data"

    var body: some View {
        VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: FitOrderDesign.Spacing.md) { metadata }
                VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xs) { metadata }
            }
            Text(source).font(.caption2.weight(.medium))
                .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
        }
        .accessibilityElement(children: .combine)
    }
    @ViewBuilder private var metadata: some View {
        Label(deliveryText, systemImage: "clock.fill")
        Label(priceText, systemImage: "indianrupeesign.circle.fill")
    }
}
// MARK: - Loading and tool lifecycle
struct FitOrderSkeletonCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        FitOrderElevatedCard {
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.md) {
                RoundedRectangle(cornerRadius: FitOrderDesign.Radius.compact)
                    .fill(FitOrderDesign.Palette.plumSoft).frame(height: 116)
                Text("Preparing a high protein recovery meal").font(.headline)
                Text("Checking price, availability, and delivery").font(.subheadline)
                HStack { Text("28 minute delivery"); Spacer(); Text("₹343") }.font(.caption)
            }
            .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
            .redacted(reason: .placeholder)
        }
        .overlay {
            if !reduceMotion {
                shimmer
                    .clipShape(RoundedRectangle(
                        cornerRadius: FitOrderDesign.Radius.card, style: .continuous
                    ))
                    .allowsHitTesting(false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preparing your fuel plan")
    }
    private var shimmer: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            GeometryReader { proxy in
                let time = context.date.timeIntervalSinceReferenceDate
                let cycle = time.truncatingRemainder(dividingBy: 1.6) / 1.6
                LinearGradient(colors: [.clear, .white.opacity(0.55), .clear],
                               startPoint: .top, endPoint: .bottom)
                    .frame(width: proxy.size.width * 0.55)
                    .rotationEffect(.degrees(12))
                    .offset(x: -proxy.size.width + (proxy.size.width * 2.5 * CGFloat(cycle)))
            }
        }
    }
}
struct FitOrderToolLifecycleRow: View {
    let event: ToolTraceEvent
    var body: some View {
        HStack(alignment: .top, spacing: FitOrderDesign.Spacing.sm) {
            statusIcon.frame(width: 22, height: 22).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: FitOrderDesign.Spacing.xxs) {
                Text(event.toolName).font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(FitOrderDesign.Palette.ink)
                Text(event.friendlySummary).font(.caption)
                    .foregroundStyle(FitOrderDesign.Palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, FitOrderDesign.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.toolName), \(statusLabel)")
        .accessibilityValue(event.friendlySummary)
    }
    @ViewBuilder private var statusIcon: some View {
        switch event.state {
        case .running:
            ProgressView().controlSize(.small).tint(FitOrderDesign.Palette.swiggyOrange)
        case .succeeded:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(FitOrderDesign.Palette.success)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(FitOrderDesign.Palette.failure)
        }
    }
    private var statusLabel: String {
        switch event.state {
        case .running: "running"
        case .succeeded: "completed"
        case .failed: "failed"
        }
    }
}
// MARK: - Glass, actions, and haptics
private struct FitOrderFloatingCapsuleModifier: ViewModifier {
    let tint: Color
    let interactive: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.tint(tint.opacity(0.14)).interactive(interactive),
                             in: .capsule)
                .shadow(color: .black.opacity(0.13), radius: 16, y: 8)
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
                .background(tint.opacity(0.09), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))
                .shadow(color: .black.opacity(0.13), radius: 16, y: 8)
        }
    }
}
extension View {
    func fitOrderFloatingCapsule(
        tint: Color = FitOrderDesign.Palette.plum,
        interactive: Bool = true
    ) -> some View {
        modifier(FitOrderFloatingCapsuleModifier(tint: tint, interactive: interactive))
    }
}
struct FitOrderPrimaryActionStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var tint = FitOrderDesign.Palette.swiggyOrange
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold)).foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, FitOrderDesign.Spacing.md)
            .background(tint, in: RoundedRectangle(
                cornerRadius: FitOrderDesign.Radius.chip, style: .continuous
            ))
            .contentShape(Rectangle()).opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.78),
                       value: configuration.isPressed)
    }
}
@MainActor
enum FitOrderHaptics {
    enum Feedback { case selection, softImpact, success, warning, error }
    static func play(_ feedback: Feedback, isEnabled: Bool = true) {
        guard isEnabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        switch feedback {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare(); generator.selectionChanged()
        case .softImpact:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare(); generator.impactOccurred()
        case .success: notify(.success)
        case .warning: notify(.warning)
        case .error: notify(.error)
        }
    }
    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare(); generator.notificationOccurred(type)
    }
}
