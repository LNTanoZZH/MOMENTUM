import SwiftUI

struct RGBColorPicker: View {
    @Binding var color: Color
    var onChange: (Color) -> Void

    @State private var red: Double = 0.5
    @State private var green: Double = 0.5
    @State private var blue: Double = 0.5

    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: 40)

            rgbSlider(label: "R", value: $red, tint: .red)
            rgbSlider(label: "G", value: $green, tint: .green)
            rgbSlider(label: "B", value: $blue, tint: .blue)
        }
        .onAppear { syncFromBinding() }
    }

    private func rgbSlider(label: String, value: Binding<Double>, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(MomentumTypography.caption)
                .foregroundStyle(MomentumColors.textSecondary)
                .frame(width: 16)
            Slider(value: value, in: 0...1, step: 0.01)
                .tint(tint)
                .onChange(of: value.wrappedValue) { _, _ in updateColor() }
        }
    }

    private func syncFromBinding() {
        let c = color.rgbComponents
        red = c.r
        green = c.g
        blue = c.b
    }

    private func updateColor() {
        color = Color(red: red, green: green, blue: blue)
        onChange(color)
    }
}
