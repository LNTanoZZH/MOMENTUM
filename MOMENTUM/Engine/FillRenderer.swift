import CoreImage
import UIKit

struct FillRenderer {
    private let context = CIContext(options: [.useSoftwareRenderer: false])

    func renderCardFill(config: ColorCardConfig, size: CGSize) -> CIImage? {
        guard size.width > 0, size.height > 0 else { return nil }

        let rect = CGRect(origin: .zero, size: size)
        var base: CIImage?

        switch config.fill {
        case .solid:
            base = solidImage(color: config.primaryColor, size: size)
        case .gradient:
            let secondary = config.secondaryColor ?? config.primaryColor.adjusted(brightness: 0.15)
            base = gradientImage(
                primary: config.primaryColor,
                secondary: secondary,
                direction: config.gradientDirection,
                size: size
            )
        case .stripes:
            let secondary = config.secondaryColor ?? config.primaryColor.adjusted(brightness: -0.12)
            base = stripeImage(
                primary: config.primaryColor,
                secondary: secondary,
                width: config.stripeWidth,
                direction: config.stripeDirection,
                size: size
            )
        }

        guard var image = base else { return nil }

        if config.grainIntensity > 0.01 {
            image = applyGrain(to: image, intensity: config.grainIntensity, extent: rect)
        }

        return image
    }

    private func solidImage(color: PaletteColor, size: CGSize) -> CIImage? {
        let uiColor = color.uiColor
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer { UIGraphicsEndImageContext() }
        uiColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return CIImage(image: img)
    }

    private func gradientImage(
        primary: PaletteColor,
        secondary: PaletteColor,
        direction: GradientDirection,
        size: CGSize
    ) -> CIImage? {
        let points = direction.points
        let filter = CIFilter.linearGradient()
        filter.color0 = CIColor(color: primary.uiColor)
        filter.color1 = CIColor(color: secondary.uiColor)
        filter.point0 = CGPoint(x: points.start.x * size.width, y: points.start.y * size.height)
        filter.point1 = CGPoint(x: points.end.x * size.width, y: points.end.y * size.height)
        return filter.outputImage?.cropped(to: CGRect(origin: .zero, size: size))
    }

    private func stripeImage(
        primary: PaletteColor,
        secondary: PaletteColor,
        width: CGFloat,
        direction: StripeDirection,
        size: CGSize
    ) -> CIImage? {
        let stripe = max(width, 2)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        secondary.uiColor.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))

        primary.uiColor.setFill()
        switch direction {
        case .vertical:
            var x: CGFloat = 0
            while x < size.width {
                ctx.fill(CGRect(x: x, y: 0, width: stripe, height: size.height))
                x += stripe * 2
            }
        case .horizontal:
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(CGRect(x: 0, y: y, width: size.width, height: stripe))
                y += stripe * 2
            }
        }

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return CIImage(image: img)
    }

    private func applyGrain(to image: CIImage, intensity: Double, extent: CGRect) -> CIImage {
        guard let noise = CIFilter(name: "CIRandomGenerator")?.outputImage else { return image }
        let scaledNoise = noise
            .cropped(to: extent)
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity * 0.35)),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
            ])

        return scaledNoise.applyingFilter("CIOverlayBlendMode", parameters: [
            kCIInputBackgroundImageKey: image
        ]).cropped(to: extent)
    }

    func uiImage(from ciImage: CIImage) -> UIImage? {
        guard let cg = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

extension PaletteColor {
    func adjusted(brightness delta: Double) -> PaletteColor {
        PaletteColor(
            red: min(max(red + delta, 0), 1),
            green: min(max(green + delta, 0), 1),
            blue: min(max(blue + delta, 0), 1),
            weight: weight
        )
    }
}
