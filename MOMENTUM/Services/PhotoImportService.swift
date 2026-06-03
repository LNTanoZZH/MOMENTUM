import PhotosUI
import SwiftUI
import UIKit

struct PhotoImportService {
    func loadImage(from item: PhotosPickerItem) async throws -> (UIImage, String?) {
        if let liveID = item.itemIdentifier {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                return (image, liveID)
            }
        }

        guard let data = try await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            throw ImportError.failedToLoad
        }
        return (image, item.itemIdentifier)
    }

    enum ImportError: Error {
        case failedToLoad
    }
}
