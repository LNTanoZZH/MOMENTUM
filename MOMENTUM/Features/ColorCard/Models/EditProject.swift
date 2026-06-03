import Foundation
import SwiftUI
import UIKit

struct PaletteColor: Codable, Hashable, Identifiable {
    let id: UUID
    var red: Double
    var green: Double
    var blue: Double
    var weight: Double

    init(id: UUID = UUID(), red: Double, green: Double, blue: Double, weight: Double = 0) {
        self.id = id
        self.red = red
        self.green = green
        self.blue = blue
        self.weight = weight
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    var cgColor: CGColor {
        uiColor.cgColor
    }
}

struct ImageAsset: Codable, Hashable {
    var imageData: Data?
    var livePhotoIdentifier: String?
    var width: Int
    var height: Int

    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}

struct EditProject: Identifiable {
    var id: UUID = UUID()
    var sourceImage: UIImage
    var livePhotoIdentifier: String?
    var colorCard: ColorCardConfig
    var dotLayer: DotLayer
    var palette: [PaletteColor]
    var createdAt: Date = Date()

    init(sourceImage: UIImage, livePhotoIdentifier: String? = nil, palette: [PaletteColor] = []) {
        self.sourceImage = sourceImage
        self.livePhotoIdentifier = livePhotoIdentifier
        self.palette = palette
        self.colorCard = ColorCardConfig.default(primary: palette.first ?? PaletteColor(red: 0.77, green: 0.66, blue: 0.51))
        self.dotLayer = DotLayer()
    }
}
