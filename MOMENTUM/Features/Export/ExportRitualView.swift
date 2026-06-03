import SwiftData
import SwiftUI

struct ExportRitualView: View {
    let renderedImage: UIImage
    let projectID: UUID
    @Binding var navigationPath: NavigationPath

    @Environment(\.modelContext) private var modelContext
    @State private var phase: ExportPhase = .preview
    @State private var flyProgress: CGFloat = 0
    @State private var errorMessage: String?

    enum ExportPhase {
        case preview, flying, archived
    }

    var body: some View {
        ZStack {
            MomentumColors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(uiImage: renderedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .momentumShadow(MomentumShadow.card)
                    .scaleEffect(phase == .flying ? 0.3 : 1.0)
                    .offset(y: phase == .flying ? 200 * flyProgress : 0)
                    .opacity(phase == .archived ? 0 : 1)
                    .padding(.horizontal, 32)
                    .animation(MomentumMotion.exportFly, value: phase)

                if phase == .archived {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(MomentumColors.accentWarm)
                        Text("已妥善收藏")
                            .font(MomentumTypography.title)
                            .foregroundStyle(MomentumColors.textPrimary)
                        Text("你的日子被精致地对待了")
                            .font(MomentumTypography.caption)
                            .foregroundStyle(MomentumColors.textSecondary)
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer()

                if phase == .archived {
                    TactileButton(title: "回到首页", systemImage: "house") {
                        navigationPath = NavigationPath()
                    }
                    .padding(.bottom, 40)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(MomentumTypography.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await performExport()
        }
    }

    private func performExport() async {
        try? await Task.sleep(nanoseconds: 500_000_000)

        do {
            try await ExportService().saveToPhotoLibrary(renderedImage)
            saveToCollection()
            FeedbackService.shared.play(.success)

            withAnimation(MomentumMotion.exportFly) {
                phase = .flying
                flyProgress = 1
            }

            try? await Task.sleep(nanoseconds: 600_000_000)

            withAnimation(MomentumMotion.spring) {
                phase = .archived
            }
        } catch {
            errorMessage = error.localizedDescription
            phase = .archived
        }
    }

    private func saveToCollection() {
        let thumbSize = CGSize(width: 200, height: 200 * renderedImage.size.height / max(renderedImage.size.width, 1))
        let renderer = UIGraphicsImageRenderer(size: thumbSize)
        let thumbnail = renderer.image { _ in
            renderedImage.draw(in: CGRect(origin: .zero, size: thumbSize))
        }

        let item = WorkCollectionItem(
            id: projectID,
            thumbnailData: thumbnail.jpegData(compressionQuality: 0.8),
            fullImageData: renderedImage.pngData()
        )
        modelContext.insert(item)
        try? modelContext.save()
    }
}
