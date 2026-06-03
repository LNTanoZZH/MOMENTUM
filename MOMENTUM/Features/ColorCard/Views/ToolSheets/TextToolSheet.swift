import SwiftUI

struct TextToolSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var draftText: CardText

    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        _draftText = State(initialValue: viewModel.project.colorCard.text ?? .empty)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("输入文字", text: $draftText.content, axis: .vertical)
                    .font(MomentumTypography.body)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(MomentumColors.backgroundSecondary))
                    .lineLimit(3...6)

                Text("字体")
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MomentumTypography.cardFonts) { style in
                            Button {
                                draftText.fontStyleName = style.name
                            } label: {
                                Text(style.name)
                                    .font(MomentumTypography.caption)
                                    .foregroundStyle(
                                        draftText.fontStyleName == style.name
                                            ? MomentumColors.surface
                                            : MomentumColors.textPrimary
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(
                                            draftText.fontStyleName == style.name
                                                ? MomentumColors.accentWarm
                                                : MomentumColors.backgroundSecondary
                                        )
                                    )
                            }
                        }
                    }
                }

                Picker("对齐", selection: $draftText.alignment) {
                    Text("左").tag(TextAlignmentOption.leading)
                    Text("中").tag(TextAlignmentOption.center)
                    Text("右").tag(TextAlignmentOption.trailing)
                }
                .pickerStyle(.segmented)

                HStack {
                    ForEach(viewModel.project.palette) { color in
                        ColorChip(color: color, isSelected: draftText.color == color) {
                            draftText.color = color
                        }
                    }
                }

                SliderRail(
                    title: "字间距",
                    value: $draftText.letterSpacing,
                    range: -2...8,
                    step: 0.5
                )

                Spacer()
            }
            .padding(20)
            .background(MomentumColors.backgroundPrimary)
            .navigationTitle("文字")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        viewModel.showTextEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        viewModel.updateText(draftText)
                        viewModel.showTextEditor = false
                    }
                }
            }
        }
    }
}
