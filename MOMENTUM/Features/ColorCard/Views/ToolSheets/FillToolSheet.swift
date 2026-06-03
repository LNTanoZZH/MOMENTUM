import SwiftUI

struct FillToolSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showPanel = true

    var body: some View {
        ToolPanel(title: "填充", isPresented: $showPanel) {
            Picker("填充模式", selection: Binding(
                get: { viewModel.project.colorCard.fill },
                set: { viewModel.setFillStyle($0) }
            )) {
                ForEach(FillStyle.allCases) { style in
                    Text(style.label).tag(style)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.project.colorCard.fill == .gradient {
                gradientControls
            }

            if viewModel.project.colorCard.fill == .stripes {
                stripeControls
            }

            SliderRail(
                title: "颗粒质感",
                value: Binding(
                    get: { viewModel.project.colorCard.grainIntensity },
                    set: { viewModel.setGrainIntensity($0) }
                ),
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.commitGrainIntensity(viewModel.project.colorCard.grainIntensity)
                    }
                }
            )
        }
        .onAppear { showPanel = true }
    }

    private var gradientControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("渐变方向")
                .font(MomentumTypography.caption)
                .foregroundStyle(MomentumColors.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(GradientDirection.allCases) { direction in
                    Button {
                        viewModel.setGradientDirection(direction)
                    } label: {
                        Text(direction.label)
                            .font(MomentumTypography.toolLabel)
                            .foregroundStyle(
                                viewModel.project.colorCard.gradientDirection == direction
                                    ? MomentumColors.accentWarm
                                    : MomentumColors.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(MomentumColors.backgroundSecondary)
                            )
                    }
                }
            }

            Text("在「颜色」面板选择副色以启用双色渐变")
                .font(MomentumTypography.toolLabel)
                .foregroundStyle(MomentumColors.textSecondary.opacity(0.8))
        }
    }

    private var stripeControls: some View {
        VStack(spacing: 12) {
            Picker("条纹方向", selection: Binding(
                get: { viewModel.project.colorCard.stripeDirection },
                set: { viewModel.setStripeDirection($0) }
            )) {
                ForEach(StripeDirection.allCases) { dir in
                    Text(dir.label).tag(dir)
                }
            }
            .pickerStyle(.segmented)

            SliderRail(
                title: "条纹宽度",
                value: Binding(
                    get: { Double(viewModel.project.colorCard.stripeWidth) },
                    set: { viewModel.setStripeWidth($0) }
                ),
                range: 4...40,
                step: 1,
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.commitStripeWidth(Double(viewModel.project.colorCard.stripeWidth))
                    }
                }
            )
        }
    }
}
