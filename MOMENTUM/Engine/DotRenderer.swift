import CoreGraphics
import UIKit

struct DotRenderer {
    private let layoutCalculator = LayoutCalculator()

    func generateRandomDots(
        layer: DotLayer,
        layout: LayoutCalculator.LayoutRects,
        seed: UInt64? = nil
    ) -> [DotElement] {
        var rng = SeededRandomNumberGenerator(seed: seed ?? layer.randomSeed)
        let shapes = DotShape.allCases
        var dots: [DotElement] = []

        for _ in 0..<layer.randomCount {
            let nx = Double.random(in: 0.02...0.98, using: &rng)
            let ny = Double.random(in: 0.02...0.98, using: &rng)
            let center = CGPoint(x: nx, y: ny)
            let variance = layer.sizeVariance
            let sizeFactor = layer.baseSize * (1 + (Double.random(in: -1...1, using: &rng) * variance))
            let shape = shapes[Int.random(in: 0..<shapes.count, using: &rng)]
            let region = layoutCalculator.region(for: center, layout: layout)
            dots.append(DotElement(
                shape: shape,
                center: center,
                size: CGFloat(sizeFactor),
                rotation: Double.random(in: 0..<360, using: &rng),
                region: region
            ))
        }
        return dots
    }

    func generatePathDots(
        path: [CGPoint],
        layer: DotLayer,
        layout: LayoutCalculator.LayoutRects
    ) -> [DotElement] {
        guard path.count >= 2 else { return [] }
        var rng = SeededRandomNumberGenerator(seed: layer.randomSeed)
        var dots: [DotElement] = []
        let steps = max(path.count * 3, 8)

        for i in 0..<steps {
            let t = Double(i) / Double(steps - 1)
            let index = min(Int(t * Double(path.count - 1)), path.count - 2)
            let localT = (t * Double(path.count - 1)) - Double(index)
            let p0 = path[index]
            let p1 = path[index + 1]
            let x = p0.x + (p1.x - p0.x) * localT + CGFloat.random(in: -0.015...0.015, using: &rng)
            let y = p0.y + (p1.y - p0.y) * localT + CGFloat.random(in: -0.015...0.015, using: &rng)
            let center = CGPoint(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
            let sizeFactor = layer.baseSize * (1 + Double.random(in: -0.3...0.3, using: &rng) * layer.sizeVariance)
            dots.append(DotElement(
                shape: layer.selectedShape,
                center: center,
                size: CGFloat(sizeFactor),
                rotation: Double.random(in: 0..<360, using: &rng),
                region: layoutCalculator.region(for: center, layout: layout)
            ))
        }
        return dots
    }

    func drawDots(
        in context: CGContext,
        dots: [DotElement],
        layout: LayoutCalculator.LayoutRects,
        cardColor: PaletteColor
    ) {
        for dot in dots {
            let canvasPoint = CGPoint(
                x: dot.center.x * layout.canvasSize.width,
                y: dot.center.y * layout.canvasSize.height
            )
            let radius = CGFloat(dot.size) * min(layout.canvasSize.width, layout.canvasSize.height)
            let rect = CGRect(
                x: canvasPoint.x - radius / 2,
                y: canvasPoint.y - radius / 2,
                width: radius,
                height: radius
            )

            context.saveGState()
            context.translateBy(x: canvasPoint.x, y: canvasPoint.y)
            context.rotate(by: CGFloat(dot.rotation * .pi / 180))
            context.translateBy(x: -canvasPoint.x, y: -canvasPoint.y)

            switch dot.region {
            case .onPhoto:
                context.setFillColor(cardColor.cgColor)
                drawShape(dot.shape, in: context, rect: rect)
                context.fillPath()
            case .onCard:
                context.saveGState()
                context.clip(to: layout.cardRect)
                context.setBlendMode(.destinationOut)
                drawShape(dot.shape, in: context, rect: rect)
                context.fillPath()
                context.setBlendMode(.normal)
                context.restoreGState()
            }
            context.restoreGState()
        }
    }

    private func drawShape(_ shape: DotShape, in context: CGContext, rect: CGRect) {
        switch shape {
        case .circle:
            context.addEllipse(in: rect)
        case .square:
            context.addRect(rect)
        case .star:
            context.addPath(starPath(in: rect).cgPath)
        case .raindrop:
            context.addPath(raindropPath(in: rect).cgPath)
        case .line:
            let h = rect.height * 0.2
            context.addRect(CGRect(x: rect.minX, y: rect.midY - h / 2, width: rect.width, height: h))
        }
    }

    private func starPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 5
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let p = CGPoint(x: center.x + CGFloat(cos(angle)) * r, y: center.y + CGFloat(sin(angle)) * r)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.close()
        return path
    }

    private func raindropPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            controlPoint: CGPoint(x: rect.maxX + rect.width * 0.2, y: rect.midY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            controlPoint: CGPoint(x: rect.minX - rect.width * 0.2, y: rect.midY)
        )
        return path
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

extension Double {
    static func random(in range: ClosedRange<Double>, using generator: inout SeededRandomNumberGenerator) -> Double {
        let value = Double(generator.next()) / Double(UInt64.max)
        return range.lowerBound + (range.upperBound - range.lowerBound) * value
    }
}

extension CGFloat {
    static func random(in range: ClosedRange<CGFloat>, using generator: inout SeededRandomNumberGenerator) -> CGFloat {
        CGFloat(Double.random(in: Double(range.lowerBound)...Double(range.upperBound), using: &generator))
    }
}

extension Int {
    static func random(in range: Range<Int>, using generator: inout SeededRandomNumberGenerator) -> Int {
        let value = Double.random(in: Double(range.lowerBound)...Double(range.upperBound - 1), using: &generator)
        return Int(value)
    }
}
