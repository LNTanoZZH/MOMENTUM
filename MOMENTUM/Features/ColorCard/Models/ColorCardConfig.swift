import Foundation
import UIKit
import SwiftUI

enum CardPlacement: String, CaseIterable, Codable, Identifiable {
    case top, bottom, left, right, center

    var id: String { rawValue }

    var label: String {
        switch self {
        case .top: return "上"
        case .bottom: return "下"
        case .left: return "左"
        case .right: return "右"
        case .center: return "居中"
        }
    }

    var systemImage: String {
        switch self {
        case .top: return "rectangle.topthird.inset.filled"
        case .bottom: return "rectangle.bottomthird.inset.filled"
        case .left: return "rectangle.leadingthird.inset.filled"
        case .right: return "rectangle.trailingthird.inset.filled"
        case .center: return "square.inset.filled"
        }
    }
}

enum FillStyle: String, CaseIterable, Codable, Identifiable {
    case solid, gradient, stripes

    var id: String { rawValue }

    var label: String {
        switch self {
        case .solid: return "纯色"
        case .gradient: return "渐变"
        case .stripes: return "条纹"
        }
    }
}

enum GradientDirection: String, CaseIterable, Codable, Identifiable {
    case up, down, left, right
    case upLeft, upRight, downLeft, downRight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .up: return "向上"
        case .down: return "向下"
        case .left: return "向左"
        case .right: return "向右"
        case .upLeft: return "左上"
        case .upRight: return "右上"
        case .downLeft: return "左下"
        case .downRight: return "右下"
        }
    }

    var points: (start: CGPoint, end: CGPoint) {
        switch self {
        case .up: return (CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0))
        case .down: return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
        case .left: return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
        case .right: return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .upLeft: return (CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 0))
        case .upRight: return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        case .downLeft: return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
        case .downRight: return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        }
    }
}

enum StripeDirection: String, CaseIterable, Codable, Identifiable {
    case horizontal, vertical

    var id: String { rawValue }

    var label: String {
        switch self {
        case .horizontal: return "水平"
        case .vertical: return "竖直"
        }
    }
}

struct CardText: Hashable {
    var content: String
    var fontStyleName: String
    var color: PaletteColor
    var alignment: TextAlignmentOption
    var letterSpacing: Double

    static let empty = CardText(
        content: "",
        fontStyleName: "System Rounded",
        color: PaletteColor(red: 0.24, green: 0.22, blue: 0.19),
        alignment: .center,
        letterSpacing: 0
    )
}

enum TextAlignmentOption: String, CaseIterable, Codable, Identifiable {
    case leading, center, trailing

    var id: String { rawValue }

    var swiftUIAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    var nsAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        }
    }
}

struct ColorCardConfig: Hashable {
    var placement: CardPlacement
    var cardSizeRatio: CGFloat
    var fill: FillStyle
    var primaryColor: PaletteColor
    var secondaryColor: PaletteColor?
    var gradientDirection: GradientDirection
    var stripeWidth: CGFloat
    var stripeDirection: StripeDirection
    var grainIntensity: Double
    var text: CardText?

    static func `default`(primary: PaletteColor) -> ColorCardConfig {
        ColorCardConfig(
            placement: .bottom,
            cardSizeRatio: 0.28,
            fill: .solid,
            primaryColor: primary,
            secondaryColor: nil,
            gradientDirection: .down,
            stripeWidth: 12,
            stripeDirection: .vertical,
            grainIntensity: 0,
            text: nil
        )
    }
}
