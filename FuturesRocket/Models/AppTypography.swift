import SwiftUI

/// Fonts used throughout the app to create a consistent hierarchy.
public enum AppTypography {
    public static let titleLarge = Font.system(size: 36, weight: .semibold, design: .rounded)
    public static let titleMedium = Font.system(size: 26, weight: .semibold, design: .rounded)
    public static let titleSmall = Font.system(size: 18, weight: .medium, design: .rounded)
    public static let bodyPrimary = Font.system(size: 16, weight: .regular, design: .rounded)
    public static let bodySecondary = Font.system(size: 14, weight: .regular, design: .rounded)
    public static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}
