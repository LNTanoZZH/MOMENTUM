import CoreGraphics
import UIKit

struct LayoutCalculator {
    struct LayoutRects {
        let canvasSize: CGSize
        let sourceRect: CGRect
        let cardRect: CGRect
        let textRect: CGRect
    }

    func calculate(config: ColorCardConfig, sourceImageSize: CGSize) -> LayoutRects {
        let ratio = config.cardSizeRatio.clamped(to: 0.12...0.45)
        let imageAspect = sourceImageSize.width / max(sourceImageSize.height, 1)

        switch config.placement {
        case .top:
            let cardH = sourceImageSize.height * ratio / (1 - ratio)
            let canvas = CGSize(width: sourceImageSize.width, height: sourceImageSize.height + cardH)
            let cardRect = CGRect(x: 0, y: 0, width: canvas.width, height: cardH)
            let sourceRect = CGRect(x: 0, y: cardH, width: canvas.width, height: sourceImageSize.height)
            let textRect = cardRect.insetBy(dx: 24, dy: 16)
            return LayoutRects(canvasSize: canvas, sourceRect: sourceRect, cardRect: cardRect, textRect: textRect)

        case .bottom:
            let cardH = sourceImageSize.height * ratio / (1 - ratio)
            let canvas = CGSize(width: sourceImageSize.width, height: sourceImageSize.height + cardH)
            let sourceRect = CGRect(x: 0, y: 0, width: canvas.width, height: sourceImageSize.height)
            let cardRect = CGRect(x: 0, y: sourceRect.maxY, width: canvas.width, height: cardH)
            let textRect = cardRect.insetBy(dx: 24, dy: 16)
            return LayoutRects(canvasSize: canvas, sourceRect: sourceRect, cardRect: cardRect, textRect: textRect)

        case .left:
            let cardW = sourceImageSize.width * ratio / (1 - ratio)
            let canvas = CGSize(width: sourceImageSize.width + cardW, height: sourceImageSize.height)
            let cardRect = CGRect(x: 0, y: 0, width: cardW, height: canvas.height)
            let sourceRect = CGRect(x: cardW, y: 0, width: sourceImageSize.width, height: canvas.height)
            let textRect = cardRect.insetBy(dx: 12, dy: 24)
            return LayoutRects(canvasSize: canvas, sourceRect: sourceRect, cardRect: cardRect, textRect: textRect)

        case .right:
            let cardW = sourceImageSize.width * ratio / (1 - ratio)
            let canvas = CGSize(width: sourceImageSize.width + cardW, height: sourceImageSize.height)
            let sourceRect = CGRect(x: 0, y: 0, width: sourceImageSize.width, height: canvas.height)
            let cardRect = CGRect(x: sourceRect.maxX, y: 0, width: cardW, height: canvas.height)
            let textRect = cardRect.insetBy(dx: 12, dy: 24)
            return LayoutRects(canvasSize: canvas, sourceRect: sourceRect, cardRect: cardRect, textRect: textRect)

        case .center:
            let padding = min(sourceImageSize.width, sourceImageSize.height) * ratio
            let canvas = CGSize(
                width: sourceImageSize.width + padding * 2,
                height: sourceImageSize.height + padding * 2
            )
            let cardRect = CGRect(origin: .zero, size: canvas)
            let sourceRect = CGRect(
                x: padding,
                y: padding,
                width: sourceImageSize.width,
                height: sourceImageSize.height
            )
            let bandHeight = padding * 0.8
            let textRect = CGRect(x: padding, y: padding * 0.1, width: sourceImageSize.width, height: bandHeight)
            _ = imageAspect
            return LayoutRects(canvasSize: canvas, sourceRect: sourceRect, cardRect: cardRect, textRect: textRect)
        }
    }

    func normalizedPoint(_ point: CGPoint, canvasSize: CGSize) -> CGPoint {
        CGPoint(
            x: point.x / max(canvasSize.width, 1),
            y: point.y / max(canvasSize.height, 1)
        )
    }

    func region(for normalizedPoint: CGPoint, layout: LayoutRects) -> DotRegion {
        let point = CGPoint(
            x: normalizedPoint.x * layout.canvasSize.width,
            y: normalizedPoint.y * layout.canvasSize.height
        )
        return layout.sourceRect.contains(point) ? .onPhoto : .onCard
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
