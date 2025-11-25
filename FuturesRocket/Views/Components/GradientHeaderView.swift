import SwiftUI
import UIKit

struct GradientHeaderView: View {
    var title: String
    var subtitle: String
    var amount: String

    var body: some View {
        LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
            .mask(
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(AppTypography.titleSmall)
                        .foregroundColor(.white.opacity(0.8))
                    Text(amount)
                        .font(AppTypography.titleLarge)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.4), radius: 10, x: 0, y: 6)
                        .minimumScaleFactor(0.6)
                    Text(subtitle)
                        .font(AppTypography.bodySecondary)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            )
            .background(
                LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.9)
            )
            .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
