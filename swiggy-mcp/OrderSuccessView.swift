import SwiftUI

struct OrderSuccessView: View {
    let context: SuccessContext
    let onBackHome: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                successHero
                detailCard
                trackingCard
                PrimaryButton(title: "Back to Home", icon: "house.fill", action: onBackHome)
                DisclaimerFooter(text: "Demo only. No payment is collected and no real order is placed.")
            }
            .padding(AppSpacing.screen)
            .padding(.top, 18)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var successHero: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Color.successGreen)
            VStack(spacing: 6) {
                Text(context.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.primaryText)
                    .multilineTextAlignment(.center)
                Text(context.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var detailCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(context.detailTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.primaryText)
                        Text(context.detailSubtitle)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.swiggyOrange)
                        .frame(width: 40, height: 40)
                        .background(Color.swiggyOrange.opacity(0.12))
                        .clipShape(Circle())
                }
                PillView(title: context.fulfillmentLabel, icon: "bag.fill", tint: .offerGreen)
            }
        }
    }

    private var trackingCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Tracking simulation")
                ForEach(context.steps, id: \.self) { step in
                    MCPFlowRow(title: step)
                }
            }
        }
    }

    private var icon: String {
        switch context.kind {
        case .food:
            return "fork.knife"
        case .instamart:
            return "cart.fill"
        case .event:
            return "trophy.fill"
        }
    }
}
