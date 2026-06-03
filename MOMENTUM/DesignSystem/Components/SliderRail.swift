import SwiftUI

struct SliderRail: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var step: Double = 0.01
    var onEditingChanged: ((Bool) -> Void)? = nil

    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textSecondary)
                Spacer()
                Text(formattedValue)
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textPrimary)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                let width = geo.size.width
                let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                let thumbX = width * progress

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MomentumColors.backgroundSecondary)
                        .frame(height: 8)
                        .overlay(
                            Capsule()
                                .stroke(Color.black.opacity(0.04), lineWidth: 0.5)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [MomentumColors.accentWarm.opacity(0.7), MomentumColors.accentWarm],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, thumbX), height: 8)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [MomentumColors.surface, MomentumColors.backgroundSecondary],
                                center: .topLeading,
                                startRadius: 2,
                                endRadius: 14
                            )
                        )
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                        .momentumShadow(MomentumShadow.inset)
                        .scaleEffect(isDragging ? 1.08 : 1.0)
                        .offset(x: thumbX - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    if !isDragging {
                                        isDragging = true
                                        onEditingChanged?(true)
                                    }
                                    let p = min(max(gesture.location.x / width, 0), 1)
                                    let raw = range.lowerBound + p * (range.upperBound - range.lowerBound)
                                    value = (raw / step).rounded() * step
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    onEditingChanged?(false)
                                }
                        )
                }
            }
            .frame(height: 24)
        }
    }

    private var formattedValue: String {
        if range.upperBound <= 1 && range.lowerBound >= 0 {
            return String(format: "%.0f%%", value * 100)
        }
        return String(format: "%.0f", value)
    }
}
