import SwiftUI

struct LayoutToolSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showPanel = true

    var body: some View {
        ToolPanel(title: "布局", isPresented: $showPanel) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(CardPlacement.allCases) { placement in
                    Button {
                        viewModel.setPlacement(placement)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: placement.systemImage)
                                .font(.system(size: 20))
                            Text(placement.label)
                                .font(MomentumTypography.toolLabel)
                        }
                        .foregroundStyle(
                            viewModel.project.colorCard.placement == placement
                                ? MomentumColors.accentWarm
                                : MomentumColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    viewModel.project.colorCard.placement == placement
                                        ? MomentumColors.accentWarm.opacity(0.12)
                                        : MomentumColors.backgroundSecondary
                                )
                        )
                    }
                }
            }

            SliderRail(
                title: "色卡比例",
                value: Binding(
                    get: { Double(viewModel.project.colorCard.cardSizeRatio) },
                    set: { viewModel.setCardSizeRatio($0) }
                ),
                range: 0.12...0.45,
                step: 0.01,
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.commitCardSizeRatio(Double(viewModel.project.colorCard.cardSizeRatio))
                    }
                }
            )
        }
        .onAppear { showPanel = true }
    }
}
