import SwiftUI

struct TactileButton: View {
    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    var action: () -> Void

    enum Style {
        case primary, secondary, icon
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackService.shared.play(.lightTap)
            action()
        } label: {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: style == .icon ? 22 : 16, weight: .medium))
                }
                if style != .icon {
                    Text(title)
                        .font(MomentumTypography.body)
                }
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, style == .icon ? 16 : 20)
            .padding(.vertical, style == .icon ? 16 : 12)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(MomentumMotion.spring, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return MomentumColors.surface
        case .secondary, .icon: return MomentumColors.textPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [MomentumColors.accentWarm, MomentumColors.accentWarm.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .momentumShadow(MomentumShadow.button)
        case .secondary:
            Capsule(style: .continuous)
                .fill(MomentumColors.surface)
                .overlay(Capsule(style: .continuous).stroke(MomentumColors.backgroundSecondary, lineWidth: 1))
                .momentumShadow(MomentumShadow.button)
        case .icon:
            Circle()
                .fill(MomentumColors.surface)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.7), MomentumColors.backgroundSecondary],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .momentumShadow(MomentumShadow.button)
        }
    }
}
