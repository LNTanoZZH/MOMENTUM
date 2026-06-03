import SwiftUI

struct SpectrumColorPicker: View {
    @Binding var color: Color
    var onChange: (Color) -> Void

    @State private var hue: Double = 0.5
    @State private var saturation: Double = 0.3
    @State private var brightness: Double = 0.85

    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(MomentumColors.backgroundSecondary, lineWidth: 1)
                )

            ZStack {
                LinearGradient(
                    colors: (0...10).map { Color(hue: Double($0) / 10, saturation: 1, brightness: 1) },
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                GeometryReader { geo in
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .position(x: hue * geo.size.width, y: geo.size.height / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    hue = min(max(value.location.x / geo.size.width, 0), 1)
                                    updateColor()
                                }
                        )
                }
            }
            .frame(height: 32)

            SliderRail(title: "饱和度", value: $saturation, onEditingChanged: { _ in updateColor() })
            SliderRail(title: "亮度", value: $brightness, onEditingChanged: { _ in updateColor() })
        }
        .onAppear { syncFromBinding() }
    }

    private func syncFromBinding() {
        let ui = UIColor(color)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(b)
    }

    private func updateColor() {
        color = Color(hue: hue, saturation: saturation, brightness: brightness)
        onChange(color)
    }
}
