import SwiftUI

enum MomentumTypography {
    static let largeTitle = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    static let toolLabel = Font.system(size: 11, weight: .medium, design: .rounded)

    static let cardFonts: [CardFontStyle] = [
        .init(name: "System Serif", font: .system(size: 18, weight: .regular, design: .serif)),
        .init(name: "System Rounded", font: .system(size: 18, weight: .medium, design: .rounded)),
        .init(name: "System Mono", font: .system(size: 16, weight: .light, design: .monospaced)),
        .init(name: "Display", font: .system(size: 22, weight: .bold, design: .default)),
        .init(name: "Elegant", font: .system(size: 20, weight: .ultraLight, design: .serif))
    ]
}

struct CardFontStyle: Identifiable {
    let id = UUID()
    let name: String
    let font: Font
}
