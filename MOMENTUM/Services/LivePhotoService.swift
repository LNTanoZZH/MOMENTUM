import Photos
import UIKit

final class LivePhotoService {
    static let shared = LivePhotoService()

    func fetchLivePhoto(identifier: String, targetSize: CGSize) async -> PHLivePhoto? {
        await withCheckedContinuation { continuation in
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            PHLivePhoto.request(
                withLocalIdentifier: identifier,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { livePhoto, _ in
                continuation.resume(returning: livePhoto)
            }
        }
    }
}
