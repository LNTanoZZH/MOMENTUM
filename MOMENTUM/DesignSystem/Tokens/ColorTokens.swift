import SwiftUI

enum MomentumColors {
    static let backgroundPrimary = Color(hex: 0xF7F3EE)
    static let backgroundSecondary = Color(hex: 0xEDE8E1)
    static let surface = Color(hex: 0xFFFCF8)
    static let textPrimary = Color(hex: 0x3D3832)
    static let textSecondary = Color(hex: 0x6B645C)
    static let accentWarm = Color(hex: 0xC4A882)
    static let glassTint = Color(hex: 0xF7F3EE).opacity(0.08)

    static func dynamicAccent(from palette: [PaletteColor]) -> Color {
        palette.first?.swiftUIColor ?? accentWarm
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    var rgbComponents: (r: Double, g: Double, b: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Double(r), Double(g), Double(b))
    }

    func toPaletteColor() -> PaletteColor {
        let c = rgbComponents
        return PaletteColor(red: c.r, green: c.g, blue: c.b)
    }
}
