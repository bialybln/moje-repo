import SwiftUI

struct GlassCard<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
            content()
                .padding()
        }
    }
}
