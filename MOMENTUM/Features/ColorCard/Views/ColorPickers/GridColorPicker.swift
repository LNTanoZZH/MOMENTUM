import SwiftUI

struct GridColorPicker: View {
    var onSelect: (PaletteColor) -> Void

    private let presetColors: [PaletteColor] = [
        PaletteColor(red: 0.95, green: 0.93, blue: 0.90),
        PaletteColor(red: 0.89, green: 0.84, blue: 0.78),
        PaletteColor(red: 0.77, green: 0.66, blue: 0.51),
        PaletteColor(red: 0.65, green: 0.55, blue: 0.48),
        PaletteColor(red: 0.55, green: 0.48, blue: 0.42),
        PaletteColor(red: 0.45, green: 0.42, blue: 0.38),
        PaletteColor(red: 0.35, green: 0.32, blue: 0.29),
        PaletteColor(red: 0.78, green: 0.72, blue: 0.68),
        PaletteColor(red: 0.82, green: 0.76, blue: 0.70),
        PaletteColor(red: 0.70, green: 0.62, blue: 0.55),
        PaletteColor(red: 0.60, green: 0.52, blue: 0.46),
        PaletteColor(red: 0.50, green: 0.44, blue: 0.40),
        PaletteColor(red: 0.88, green: 0.80, blue: 0.72),
        PaletteColor(red: 0.72, green: 0.64, blue: 0.58),
        PaletteColor(red: 0.58, green: 0.50, blue: 0.44),
        PaletteColor(red: 0.42, green: 0.38, blue: 0.34)
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
            ForEach(presetColors) { color in
                Button {
                    onSelect(color)
                    FeedbackService.shared.play(.lightTap)
                } label: {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.swiftUIColor)
                        .frame(height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                        )
                }
            }
        }
    }
}
