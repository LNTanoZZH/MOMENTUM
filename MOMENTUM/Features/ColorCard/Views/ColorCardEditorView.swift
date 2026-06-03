import PhotosUI
import SwiftUI
import UIKit

struct ColorCardEditorView: View {
    let sourceImage: UIImage
    let livePhotoIdentifier: String?
    @Binding var navigationPath: NavigationPath

    @StateObject private var viewModel: EditorViewModel
    @State private var isExporting = false

    init(sourceImage: UIImage, livePhotoIdentifier: String?, navigationPath: Binding<NavigationPath>) {
        self.sourceImage = sourceImage
        self.livePhotoIdentifier = livePhotoIdentifier
        self._navigationPath = navigationPath
        self._viewModel = StateObject(wrappedValue: EditorViewModel(
            sourceImage: sourceImage,
            livePhotoIdentifier: livePhotoIdentifier
        ))
    }

    var body: some View {
        ZStack {
            MomentumColors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                EditorCanvasView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                toolBar
                toolPanel
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showTextEditor) {
            TextToolSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                navigationPath.removeLast()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MomentumColors.textPrimary)
                    .padding(10)
                    .background(Circle().fill(MomentumColors.surface))
            }

            Spacer()

            HStack(spacing: 8) {
                Button { viewModel.undo() } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .opacity(viewModel.canUndo ? 1 : 0.3)
                }
                .disabled(!viewModel.canUndo)

                Button { viewModel.redo() } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .opacity(viewModel.canRedo ? 1 : 0.3)
                }
                .disabled(!viewModel.canRedo)
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(MomentumColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(MomentumColors.surface))

            Spacer()

            Button {
                exportWork()
            } label: {
                if isExporting {
                    ProgressView()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                } else {
                    Text("完成")
                        .font(MomentumTypography.body)
                        .foregroundStyle(MomentumColors.surface)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(MomentumColors.accentWarm))
                }
            }
            .disabled(isExporting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var toolBar: some View {
        HStack(spacing: 0) {
            ForEach(EditorTool.allCases) { tool in
                Button {
                    withAnimation(MomentumMotion.panelEnter) {
                        if tool == .text {
                            viewModel.showTextEditor = true
                        } else {
                            viewModel.selectTool(tool)
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tool.systemImage)
                            .font(.system(size: 20, weight: .medium))
                        Text(tool.label)
                            .font(MomentumTypography.toolLabel)
                    }
                    .foregroundStyle(viewModel.activeTool == tool ? MomentumColors.accentWarm : MomentumColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(MomentumColors.surface)
                .momentumShadow(MomentumShadow.card)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var toolPanel: some View {
        switch viewModel.activeTool {
        case .layout:
            LayoutToolSheet(viewModel: viewModel)
        case .color:
            ColorToolSheet(viewModel: viewModel)
        case .fill:
            FillToolSheet(viewModel: viewModel)
        case .dots:
            DotToolSheet(viewModel: viewModel)
        case .text, .none:
            EmptyView()
        }
    }

    private func exportWork() {
        isExporting = true
        Task { @MainActor in
            if let image = await viewModel.renderFullResolution() {
                let exportID = ImageSessionStore.shared.store(image: image)
                navigationPath.append(ExportRoute(imageID: exportID, projectID: viewModel.project.id))
            }
            isExporting = false
        }
    }
}
