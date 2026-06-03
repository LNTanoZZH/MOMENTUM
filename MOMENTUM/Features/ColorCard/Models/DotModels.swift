import Foundation
import CoreGraphics

enum DotShape: String, CaseIterable, Codable, Identifiable {
    case circle, star, raindrop, line, square

    var id: String { rawValue }

    var label: String {
        switch self {
        case .circle: return "圆点"
        case .star: return "星星"
        case .raindrop: return "雨滴"
        case .line: return "线条"
        case .square: return "方块"
        }
    }

    var systemImage: String {
        switch self {
        case .circle: return "circle.fill"
        case .star: return "star.fill"
        case .raindrop: return "drop.fill"
        case .line: return "minus"
        case .square: return "square.fill"
        }
    }
}

enum DotRegion: String, Codable {
    case onPhoto
    case onCard
}

enum DotGenerationMode: String, CaseIterable, Codable, Identifiable {
    case random, manual, path

    var id: String { rawValue }

    var label: String {
        switch self {
        case .random: return "随机"
        case .manual: return "逐个"
        case .path: return "路径"
        }
    }
}

struct DotElement: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var shape: DotShape
    var center: CGPoint
    var size: CGFloat
    var rotation: Double
    var region: DotRegion
}

struct DotLayer: Codable, Hashable {
    var dots: [DotElement]
    var generationMode: DotGenerationMode
    var randomSeed: UInt64
    var randomCount: Int
    var baseSize: Double
    var sizeVariance: Double
    var selectedShape: DotShape

    init(
        dots: [DotElement] = [],
        generationMode: DotGenerationMode = .random,
        randomSeed: UInt64 = UInt64(Date().timeIntervalSince1970),
        randomCount: Int = 24,
        baseSize: Double = 0.025,
        sizeVariance: Double = 0.5,
        selectedShape: DotShape = .circle
    ) {
        self.dots = dots
        self.generationMode = generationMode
        self.randomSeed = randomSeed
        self.randomCount = randomCount
        self.baseSize = baseSize
        self.sizeVariance = sizeVariance
        self.selectedShape = selectedShape
    }
}

struct CodablePoint: Codable, Hashable {
    var x: Double
    var y: Double

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    init(_ point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
    }
}
