import Photos
import UIKit

final class LivePhotoService {
    static let shared = LivePhotoService()

    func fetchLivePhoto(identifier: String, targetSize: CGSize) async -> PHLivePhoto? {
        await withCheckedContinuation { continuation in
            PHLivePhoto.request(
                withLocalIdentifier: identifier,
                targetSize: targetSize,
                contentMode: .aspectFit
            ) { livePhoto, _ in
                continuation.resume(returning: livePhoto)
            }
        }
    }
}
