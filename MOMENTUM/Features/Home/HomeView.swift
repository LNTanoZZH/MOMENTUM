import PhotosUI
import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @Query(sort: \WorkCollectionItem.createdAt, order: .reverse) private var works: [WorkCollectionItem]
    @State private var selectedItem: PhotosPickerItem?
    @State private var isImporting = false

    var body: some View {
        ZStack {
            MomentumColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 32) {
                header
                Spacer()
                importButton
                recentWorks
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            importPhoto(newItem)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("MOMENTUM")
                .font(MomentumTypography.largeTitle)
                .foregroundStyle(MomentumColors.textPrimary)
                .tracking(4)
            Text("把日子，精致地对待")
                .font(MomentumTypography.caption)
                .foregroundStyle(MomentumColors.textSecondary)
        }
        .padding(.top, 48)
    }

    private var importButton: some View {
        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .livePhotos])) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(MomentumColors.surface)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.8), MomentumColors.backgroundSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .momentumShadow(MomentumShadow.card)

                    if isImporting {
                        ProgressView()
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(MomentumColors.textPrimary)
                    }
                }
                Text("导入图片")
                    .font(MomentumTypography.caption)
                    .foregroundStyle(MomentumColors.textSecondary)
            }
        }
        .disabled(isImporting)
    }

    private var recentWorks: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !works.isEmpty {
                Text("典藏册")
                    .font(MomentumTypography.title)
                    .foregroundStyle(MomentumColors.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(works) { work in
                            if let image = work.thumbnailImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 72, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .momentumShadow(MomentumShadow.inset)
                            }
                        }
                    }
                }
            } else {
                GlassCard {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(MomentumColors.textSecondary)
                        Text("还没有作品")
                            .font(MomentumTypography.caption)
                            .foregroundStyle(MomentumColors.textSecondary)
                        Text("导入一张照片，开始玩")
                            .font(MomentumTypography.toolLabel)
                            .foregroundStyle(MomentumColors.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private func importPhoto(_ item: PhotosPickerItem) {
        isImporting = true
        Task {
            do {
                let result = try await PhotoImportService().loadImage(from: item)
                FeedbackService.shared.play(.shutter)
                let imageID = ImageSessionStore.shared.store(image: result.0, livePhotoIdentifier: result.1)
                navigationPath.append(EditorRoute(imageID: imageID))
            } catch {
                FeedbackService.shared.play(.lightTap)
            }
            isImporting = false
            selectedItem = nil
        }
    }
}
