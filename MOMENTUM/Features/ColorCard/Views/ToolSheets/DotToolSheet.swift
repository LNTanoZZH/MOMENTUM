import SwiftUI

struct DotToolSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showPanel = true

    var body: some View {
        ToolPanel(title: "波点", isPresented: $showPanel) {
            Picker("模式", selection: Binding(
                get: { viewModel.project.dotLayer.generationMode },
                set: { viewModel.setDotMode($0) }
            )) {
                ForEach(DotGenerationMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 8) {
                ForEach(DotShape.allCases) { shape in
                    Button {
                        viewModel.setDotShape(shape)
                    } label: {
                        Image(systemName: shape.systemImage)
                            .font(.system(size: 16))
                            .foregroundStyle(
                                viewModel.project.dotLayer.selectedShape == shape
                                    ? MomentumColors.accentWarm
                                    : MomentumColors.textSecondary
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                Circle().fill(MomentumColors.backgroundSecondary)
                            )
                    }
                }
            }

            if viewModel.project.dotLayer.generationMode == .random {
                SliderRail(
                    title: "数量",
                    value: Binding(
                        get: { Double(viewModel.project.dotLayer.randomCount) },
                        set: { viewModel.setDotCount($0) }
                    ),
                    range: 4...80,
                    step: 1,
                    onEditingChanged: { editing in
                        if !editing {
                            viewModel.commitDotCount(Double(viewModel.project.dotLayer.randomCount))
                        }
                    }
                )

                SliderRail(
                    title: "大小",
                    value: Binding(
                        get: { viewModel.project.dotLayer.baseSize },
                        set: { viewModel.setDotBaseSize($0) }
                    ),
                    range: 0.008...0.06,
                    step: 0.001,
                    onEditingChanged: { editing in
                        if !editing {
                            viewModel.commitDotBaseSize(viewModel.project.dotLayer.baseSize)
                        }
                    }
                )

                SliderRail(
                    title: "大小差异",
                    value: Binding(
                        get: { viewModel.project.dotLayer.sizeVariance },
                        set: { viewModel.setDotSizeVariance($0) }
                    ),
                    onEditingChanged: { editing in
                        if !editing {
                            viewModel.commitDotSizeVariance(viewModel.project.dotLayer.sizeVariance)
                        }
                    }
                )

                Button {
                    viewModel.regenerateRandomDots()
                    FeedbackService.shared.play(.filmAdvance)
                } label: {
                    Label("重新随机", systemImage: "dice")
                        .font(MomentumTypography.caption)
                        .foregroundStyle(MomentumColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(MomentumColors.backgroundSecondary))
                }
            } else if viewModel.project.dotLayer.generationMode == .manual {
                Text("点击画布添加波点")
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textSecondary)
            } else {
                Text("在画布上拖动绘制路径")
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textSecondary)
            }
        }
        .onAppear {
            showPanel = true
            if viewModel.project.dotLayer.dots.isEmpty {
                viewModel.regenerateRandomDots()
            }
        }
    }
}
