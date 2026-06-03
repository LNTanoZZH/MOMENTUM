import Photos
import PhotosUI
import SwiftUI

struct LivePhotoBadge: View {
    var body: some View {
        Label("实况", systemImage: "livephoto")
            .font(MomentumTypography.toolLabel)
            .foregroundStyle(MomentumColors.surface)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(MomentumColors.textPrimary.opacity(0.6)))
    }
}

struct LivePhotoPreviewOverlay: UIViewRepresentable {
    let livePhoto: PHLivePhoto

    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.livePhoto = livePhoto
        view.contentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
    }
}
