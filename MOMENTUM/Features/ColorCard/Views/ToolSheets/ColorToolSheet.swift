import SwiftUI

struct ColorToolSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var showPanel = true

    var body: some View {
        ToolPanel(title: "颜色", isPresented: $showPanel) {
            HStack(spacing: 12) {
                ForEach(viewModel.project.palette) { color in
                    ColorChip(color: color, isSelected: isSelected(color)) {
                        applyColor(color)
                    }
                }
            }

            HStack(spacing: 8) {
                colorTargetButton(.primary, label: "主色")
                colorTargetButton(.secondary, label: "副色")
                Spacer()
                Button {
                    viewModel.isEyedropperActive.toggle()
                } label: {
                    Label("吸管", systemImage: "eyedropper")
                        .font(MomentumTypography.caption)
                        .foregroundStyle(viewModel.isEyedropperActive ? MomentumColors.surface : MomentumColors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(viewModel.isEyedropperActive ? MomentumColors.accentWarm : MomentumColors.backgroundSecondary)
                        )
                }
            }

            Picker("选色方式", selection: $viewModel.colorPickerMode) {
                ForEach(ColorPickerMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            switch viewModel.colorPickerMode {
            case .grid:
                GridColorPicker { color in
                    applyColor(color)
                }
            case .spectrum:
                SpectrumColorPicker(
                    color: bindingForTarget()
                ) { color in
                    applyPaletteColor(color)
                }
            case .rgb:
                RGBColorPicker(
                    color: bindingForTarget()
                ) { color in
                    applyPaletteColor(color)
                }
            }
        }
        .onAppear { showPanel = true }
    }

    private func colorTargetButton(_ target: ColorSelectionTarget, label: String) -> some View {
        Button {
            viewModel.colorSelectionTarget = target
        } label: {
            Text(label)
                .font(MomentumTypography.caption)
                .foregroundStyle(viewModel.colorSelectionTarget == target ? MomentumColors.surface : MomentumColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(viewModel.colorSelectionTarget == target ? MomentumColors.accentWarm : MomentumColors.backgroundSecondary)
                )
        }
    }

    private func isSelected(_ color: PaletteColor) -> Bool {
        let target: PaletteColor?
        switch viewModel.colorSelectionTarget {
        case .primary:
            target = viewModel.project.colorCard.primaryColor
        case .secondary:
            target = viewModel.project.colorCard.secondaryColor
        }
        guard let target else { return false }
        return target.isSimilar(to: color)
    }

    private func applyColor(_ color: PaletteColor) {
        switch viewModel.colorSelectionTarget {
        case .primary:
            viewModel.setPrimaryColor(color)
        case .secondary:
            viewModel.setSecondaryColor(color)
        }
    }

    private func applyPaletteColor(_ color: Color) {
        applyColor(color.toPaletteColor())
    }

    private func bindingForTarget() -> Binding<Color> {
        Binding(
            get: {
                switch viewModel.colorSelectionTarget {
                case .primary:
                    return viewModel.project.colorCard.primaryColor.swiftUIColor
                case .secondary:
                    return (viewModel.project.colorCard.secondaryColor ?? viewModel.project.colorCard.primaryColor).swiftUIColor
                }
            },
            set: { newColor in
                applyPaletteColor(newColor)
            }
        )
    }
}
