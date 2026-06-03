import Photos
import UIKit

final class LivePhotoService {
    static let shared = LivePhotoService()

    func fetchLivePhoto(identifier: String, targetSize: CGSize) async -> PHLivePhoto? {
        await withCheckedContinuation { continuation in
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                continuation.resume(returning: nil)
                return
            }

            let options = PHLivePhotoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestLivePhoto(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { livePhoto, _ in
                continuation.resume(returning: livePhoto)
            }
        }
    }
}
