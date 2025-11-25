import SwiftUI

/// Central color palette for the FuturesRocket design system.
public enum AppColors {
    public static let primaryBackground = Color(hex: "050509")
    public static let cardBackground = Color(hex: "0A0F1F").opacity(0.9)
    public static let gradientStart = Color(hex: "021B79")
    public static let gradientEnd = Color(hex: "0575E6")
    public static let profit = Color(hex: "16C784")
    public static let loss = Color(hex: "EA3943")
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: "8E8E93")
    public static let divider = Color.white.opacity(0.1)
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
