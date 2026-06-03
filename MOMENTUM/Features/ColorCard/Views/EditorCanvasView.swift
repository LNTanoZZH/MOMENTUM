import SwiftUI

struct EditorCanvasView: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(MomentumColors.backgroundSecondary)

                if let preview = viewModel.renderedPreview {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .momentumShadow(MomentumShadow.card)
                            .overlay {
                                if viewModel.isRendering {
                                    ProgressView()
                                        .tint(MomentumColors.accentWarm)
                                }
                            }
                            .overlay {
                                canvasInteractionLayer
                            }

                        if viewModel.livePhoto != nil {
                            LivePhotoBadge()
                                .padding(8)
                        }
                    }
                } else {
                    ProgressView()
                        .tint(MomentumColors.accentWarm)
                }

                if viewModel.isEyedropperActive {
                    eyedropperHint
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(canvasAspectRatio, contentMode: .fit)
        .animation(MomentumMotion.layoutMorph, value: viewModel.project.colorCard.placement)
    }

    private var canvasAspectRatio: CGFloat {
        guard let preview = viewModel.renderedPreview else { return 3 / 4 }
        return preview.size.width / max(preview.size.height, 1)
    }

    @ViewBuilder
    private var canvasInteractionLayer: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .modifier(CanvasGestureModifier(viewModel: viewModel, size: geo.size))
        }
    }

    private var eyedropperHint: some View {
        VStack {
            Text("点击取色")
                .font(MomentumTypography.caption)
                .foregroundStyle(MomentumColors.surface)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(MomentumColors.textPrimary.opacity(0.75)))
            Spacer()
        }
        .padding(.top, 12)
    }
}

private struct CanvasGestureModifier: ViewModifier {
    @ObservedObject var viewModel: EditorViewModel
    let size: CGSize

    func body(content: Content) -> some View {
        if viewModel.isEyedropperActive {
            content.onTapGesture { location in
                viewModel.pickColor(at: normalized(location))
            }
        } else if viewModel.activeTool == .dots && viewModel.project.dotLayer.generationMode == .manual {
            content.onTapGesture { location in
                viewModel.addDot(at: normalized(location))
                FeedbackService.shared.play(.lightTap)
            }
        } else if viewModel.activeTool == .dots && viewModel.project.dotLayer.generationMode == .path {
            content.gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        let point = normalized(value.location)
                        if !viewModel.isDrawingDotPath {
                            viewModel.beginDotPath(at: point)
                        } else {
                            viewModel.appendDotPath(point: point)
                        }
                    }
                    .onEnded { _ in
                        viewModel.finishDotPath()
                    }
            )
        } else {
            content
        }
    }

    private func normalized(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x / max(size.width, 1), 0), 1),
            y: min(max(point.y / max(size.height, 1), 0), 1)
        )
    }
}
