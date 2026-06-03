import UIKit

@MainActor
final class ImageSessionStore {
    static let shared = ImageSessionStore()

    private var images: [UUID: UIImage] = [:]
    private var livePhotoIDs: [UUID: String] = [:]

    private init() {}

    func store(image: UIImage, livePhotoIdentifier: String? = nil) -> UUID {
        let id = UUID()
        images[id] = image
        if let livePhotoIdentifier {
            livePhotoIDs[id] = livePhotoIdentifier
        }
        return id
    }

    func storeExport(image: UIImage, projectID: UUID) {
        images[projectID] = image
    }

    func image(for id: UUID) -> UIImage? {
        images[id]
    }

    func livePhotoIdentifier(for id: UUID) -> String? {
        livePhotoIDs[id]
    }

    func remove(id: UUID) {
        images.removeValue(forKey: id)
        livePhotoIDs.removeValue(forKey: id)
    }
}
