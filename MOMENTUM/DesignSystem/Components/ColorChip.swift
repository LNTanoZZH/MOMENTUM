import SwiftUI

struct ColorChip: View {
    let color: PaletteColor
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color.swiftUIColor)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? MomentumColors.textPrimary : Color.clear, lineWidth: 2)
                        .padding(-3)
                )
                .momentumShadow(MomentumShadow.inset)
        }
        .buttonStyle(.plain)
    }
}
