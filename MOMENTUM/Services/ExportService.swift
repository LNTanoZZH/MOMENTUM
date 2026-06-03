import Photos
import UIKit

struct ExportService {
    func saveToPhotoLibrary(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw ExportError.permissionDenied
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ExportError.saveFailed)
                }
            }
        }
    }

    func pngData(from image: UIImage) -> Data? {
        image.pngData()
    }

    enum ExportError: Error, LocalizedError {
        case saveFailed
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .saveFailed: return "保存到相册失败"
            case .permissionDenied: return "需要相册写入权限"
            }
        }
    }
}
