import SwiftUI

extension Color {
    static let swiggyOrange = Color(hex: "#FC8019")
    static let primaryText = Color(hex: "#282C3F")
    static let secondaryText = Color(hex: "#686B78")
    static let mutedText = Color(hex: "#93959F")
    static let appBackground = Color(hex: "#F8F8F8")
    static let cardBackground = Color(hex: "#FFFFFF")
    static let dividerColor = Color(hex: "#E9E9EB")
    static let successGreen = Color(hex: "#48C479")
    static let offerGreen = Color(hex: "#60B246")
    static let warningOrange = Color(hex: "#DB7C38")
    static let errorRed = Color(hex: "#D32F2F")
    static let ratingYellow = Color(hex: "#F2C94C")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        switch hex.count {
        case 6:
            red = (int >> 16) & 0xFF
            green = (int >> 8) & 0xFF
            blue = int & 0xFF
        default:
            red = 0
            green = 0
            blue = 0
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}

enum AppSpacing {
    static let screen: CGFloat = 16
    static let cardRadius: CGFloat = 18
    static let compactRadius: CGFloat = 14
}

struct SoftShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func softShadow() -> some View {
        modifier(SoftShadow())
    }
}
