import SwiftUI

enum MomentumShadow {
    static let card = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )

    static let button = ShadowStyle(
        color: Color.black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 3
    )

    static let inset = ShadowStyle(
        color: Color.black.opacity(0.04),
        radius: 4,
        x: 0,
        y: 2
    )
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func momentumShadow(_ style: ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func entitySurface(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(MomentumColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .momentumShadow(MomentumShadow.card)
            )
    }
}
