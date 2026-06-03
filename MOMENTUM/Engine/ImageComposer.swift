import CoreGraphics
import UIKit

struct ImageComposer {
    private let layoutCalculator = LayoutCalculator()
    private let fillRenderer = FillRenderer()
    private let dotRenderer = DotRenderer()

    func compose(project: EditProject, previewScale: CGFloat = 1.0) -> UIImage? {
        let source = project.sourceImage
        let sourceSize = source.size
        let layout = layoutCalculator.calculate(
            config: project.colorCard,
            sourceImageSize: sourceSize
        )

        let scale = previewScale.clamped(to: 0.2...1.0)
        let canvasSize = CGSize(
            width: layout.canvasSize.width * scale,
            height: layout.canvasSize.height * scale
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        return renderer.image { ctx in
            let context = ctx.cgContext
            let sx = canvasSize.width / layout.canvasSize.width
            let sy = canvasSize.height / layout.canvasSize.height
            context.scaleBy(x: sx, y: sy)

            drawBackingImage(source, in: layout, context: context)
            drawCardFill(config: project.colorCard, layout: layout, context: context)
            drawSourceImage(source, in: layout.sourceRect, context: context)

            context.saveGState()
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            dotRenderer.drawDots(
                in: context,
                dots: project.dotLayer.dots,
                layout: layout,
                cardColor: project.colorCard.primaryColor
            )
            context.endTransparencyLayer()
            context.restoreGState()

            if let text = project.colorCard.text, !text.content.isEmpty {
                drawText(text, config: project.colorCard, layout: layout, context: context)
            }
        }
    }

    func layout(for project: EditProject) -> LayoutCalculator.LayoutRects {
        layoutCalculator.calculate(config: project.colorCard, sourceImageSize: project.sourceImage.size)
    }

    private func drawBackingImage(_ image: UIImage, in layout: LayoutCalculator.LayoutRects, context: CGContext) {
        context.saveGState()
        context.addRect(layout.cardRect)
        context.clip()
        drawImage(image, filling: layout.cardRect, context: context)
        context.restoreGState()
    }

    private func drawCardFill(
        config: ColorCardConfig,
        layout: LayoutCalculator.LayoutRects,
        context: CGContext
    ) {
        guard let fill = fillRenderer.renderCardFill(config: config, size: layout.cardRect.size),
              let fillImage = fillRenderer.uiImage(from: fill) else { return }

        context.saveGState()
        context.translateBy(x: layout.cardRect.minX, y: layout.cardRect.minY)
        context.clip(to: CGRect(origin: .zero, size: layout.cardRect.size))
        fillImage.draw(in: CGRect(origin: .zero, size: layout.cardRect.size))
        context.restoreGState()
    }

    private func drawSourceImage(_ image: UIImage, in rect: CGRect, context: CGContext) {
        drawImage(image, filling: rect, context: context)
    }

    private func drawImage(_ image: UIImage, filling rect: CGRect, context: CGContext) {
        let imageSize = image.size
        let scale = max(rect.width / imageSize.width, rect.height / imageSize.height)
        let scaled = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: rect.midX - scaled.width / 2,
            y: rect.midY - scaled.height / 2
        )
        image.draw(in: CGRect(origin: origin, size: scaled))
    }

    private func drawText(
        _ text: CardText,
        config: ColorCardConfig,
        layout: LayoutCalculator.LayoutRects,
        context: CGContext
    ) {
        let targetRect: CGRect
        if config.placement == .center {
            targetRect = layout.textRect
        } else {
            targetRect = layout.textRect
        }

        let font = fontForStyle(text.fontStyleName, size: 22)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = text.alignment.nsAlignment
        paragraph.lineBreakMode = .byWordWrapping

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: text.color.uiColor,
            .paragraphStyle: paragraph,
            .kern: text.letterSpacing
        ]

        let attributed = NSAttributedString(string: text.content, attributes: attrs)
        let bounding = attributed.boundingRect(
            with: CGSize(width: targetRect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let drawRect = CGRect(
            x: targetRect.minX,
            y: targetRect.midY - bounding.height / 2,
            width: targetRect.width,
            height: bounding.height
        )
        attributed.draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }

    private func fontForStyle(_ name: String, size: CGFloat) -> UIFont {
        switch name {
        case "System Serif":
            return UIFont.systemFont(ofSize: size, weight: .regular)
        case "System Mono":
            return UIFont.monospacedSystemFont(ofSize: size, weight: .light)
        case "Display":
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case "Elegant":
            return UIFont.systemFont(ofSize: size, weight: .ultraLight)
        default:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        }
    }
}
