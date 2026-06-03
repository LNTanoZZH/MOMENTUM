import Foundation
import SwiftData
import UIKit

@Model
final class WorkCollectionItem {
    var id: UUID
    var createdAt: Date
    var thumbnailData: Data?
    var fullImageData: Data?
    var livePhotoIdentifier: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        thumbnailData: Data? = nil,
        fullImageData: Data? = nil,
        livePhotoIdentifier: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.thumbnailData = thumbnailData
        self.fullImageData = fullImageData
        self.livePhotoIdentifier = livePhotoIdentifier
    }

    var thumbnailImage: UIImage? {
        guard let thumbnailData else { return nil }
        return UIImage(data: thumbnailData)
    }

    var fullImage: UIImage? {
        guard let fullImageData else { return nil }
        return UIImage(data: fullImageData)
    }
}
