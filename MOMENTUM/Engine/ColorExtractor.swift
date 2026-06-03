import CoreImage
import UIKit

extension PaletteColor {
    func isSimilar(to other: PaletteColor, threshold: Double = 0.02) -> Bool {
        abs(red - other.red) < threshold
            && abs(green - other.green) < threshold
            && abs(blue - other.blue) < threshold
    }
}

struct ColorExtractor {
    private let context = CIContext(options: [.useSoftwareRenderer: false])

    func extractPalette(from image: UIImage, count: Int = 5) -> [PaletteColor] {
        guard let ciImage = CIImage(image: image) else {
            return defaultPalette(count: count)
        }

        if isGrayscale(image: image, ciImage: ciImage) {
            return topGrays(from: ciImage, count: count)
        }
        return kMeansColors(from: downsample(ciImage, to: 128), count: count)
    }

    func colorAt(point: CGPoint, in image: UIImage) -> PaletteColor {
        guard let cgImage = image.cgImage else {
            return PaletteColor(red: 0.5, green: 0.5, blue: 0.5)
        }

        let x = Int(point.x * CGFloat(cgImage.width))
        let y = Int(point.y * CGFloat(cgImage.height))
        guard x >= 0, y >= 0, x < cgImage.width, y < cgImage.height else {
            return PaletteColor(red: 0.5, green: 0.5, blue: 0.5)
        }

        var pixel: [UInt8] = [0, 0, 0, 0]
        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return PaletteColor(red: 0.5, green: 0.5, blue: 0.5)
        }

        context.draw(cgImage, in: CGRect(x: -x, y: -y, width: cgImage.width, height: cgImage.height))
        return PaletteColor(
            red: Double(pixel[0]) / 255,
            green: Double(pixel[1]) / 255,
            blue: Double(pixel[2]) / 255
        )
    }

    private func isGrayscale(image: UIImage, ciImage: CIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let width = min(cgImage.width, 64)
        let height = min(cgImage.height, 64)
        let resized = downsample(ciImage, to: max(width, height))
        guard let data = pixelData(from: resized) else { return false }

        var totalDiff = 0.0
        var count = 0
        for i in stride(from: 0, to: data.count, by: 4) {
            let r = Double(data[i])
            let g = Double(data[i + 1])
            let b = Double(data[i + 2])
            totalDiff += max(abs(r - g), abs(g - b), abs(r - b))
            count += 1
        }
        return count > 0 && (totalDiff / Double(count)) < 15
    }

    private func topGrays(from ciImage: CIImage, count: Int) -> [PaletteColor] {
        guard let data = pixelData(from: ciImage) else {
            return defaultPalette(count: count)
        }

        var histogram = [Int: Int]()
        for i in stride(from: 0, to: data.count, by: 4) {
            let gray = Int(0.299 * Double(data[i]) + 0.587 * Double(data[i + 1]) + 0.114 * Double(data[i + 2]))
            histogram[gray, default: 0] += 1
        }

        let sorted = histogram.sorted { $0.value > $1.value }
        var result: [PaletteColor] = []
        var usedBuckets: [Int] = []

        for (gray, weight) in sorted {
            if usedBuckets.contains(where: { abs($0 - gray) < 20 }) { continue }
            usedBuckets.append(gray)
            let v = Double(gray) / 255
            result.append(PaletteColor(red: v, green: v, blue: v, weight: Double(weight)))
            if result.count >= count { break }
        }

        while result.count < count {
            let step = 1.0 / Double(count + 1)
            let v = step * Double(result.count + 1)
            result.append(PaletteColor(red: v, green: v, blue: v))
        }
        return result
    }

    private func kMeansColors(from ciImage: CIImage, count: Int) -> [PaletteColor] {
        guard let data = pixelData(from: ciImage) else {
            return defaultPalette(count: count)
        }

        var points: [(r: Double, g: Double, b: Double)] = []
        for i in stride(from: 0, to: data.count, by: 4) {
            let r = Double(data[i])
            let g = Double(data[i + 1])
            let b = Double(data[i + 2])
            let brightness = (r + g + b) / 3
            if brightness < 15 || brightness > 240 { continue }
            points.append((r / 255, g / 255, b / 255))
        }

        guard !points.isEmpty else { return defaultPalette(count: count) }

        var centroids = initializeCentroids(from: points, k: count)
        var assignments = Array(repeating: 0, count: points.count)

        for _ in 0..<12 {
            for (i, point) in points.enumerated() {
                var best = 0
                var bestDist = Double.greatestFiniteMagnitude
                for (j, c) in centroids.enumerated() {
                    let d = dist(point, c)
                    if d < bestDist {
                        bestDist = d
                        best = j
                    }
                }
                assignments[i] = best
            }

            var sums = Array(repeating: (r: 0.0, g: 0.0, b: 0.0, n: 0), count: count)
            for (i, point) in points.enumerated() {
                let a = assignments[i]
                sums[a].r += point.r
                sums[a].g += point.g
                sums[a].b += point.b
                sums[a].n += 1
            }

            for j in 0..<count {
                if sums[j].n > 0 {
                    centroids[j] = (
                        r: sums[j].r / Double(sums[j].n),
                        g: sums[j].g / Double(sums[j].n),
                        b: sums[j].b / Double(sums[j].n)
                    )
                }
            }
        }

        var clusterWeights = Array(repeating: 0, count: count)
        for a in assignments { clusterWeights[a] += 1 }

        var palette = centroids.enumerated().map { index, c in
            PaletteColor(red: c.r, green: c.g, blue: c.b, weight: Double(clusterWeights[index]))
        }
        palette.sort { $0.weight > $1.weight }
        palette = mergeSimilarColors(palette)

        while palette.count < count {
            palette.append(PaletteColor(red: 0.5, green: 0.5, blue: 0.5))
        }
        return Array(palette.prefix(count))
    }

    private func mergeSimilarColors(_ colors: [PaletteColor]) -> [PaletteColor] {
        var result: [PaletteColor] = []
        for color in colors {
            if result.contains(where: { deltaE(color, $0) < 0.08 }) { continue }
            result.append(color)
        }
        return result
    }

    private func deltaE(_ a: PaletteColor, _ b: PaletteColor) -> Double {
        sqrt(pow(a.red - b.red, 2) + pow(a.green - b.green, 2) + pow(a.blue - b.blue, 2))
    }

    private func dist(_ a: (r: Double, g: Double, b: Double), _ b: (r: Double, g: Double, b: Double)) -> Double {
        pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2)
    }

    private func initializeCentroids(from points: [(r: Double, g: Double, b: Double)], k: Int) -> [(r: Double, g: Double, b: Double)] {
        guard let first = points.randomElement() else { return [] }
        var centroids = [first]
        while centroids.count < k {
            var distances: [Double] = []
            for point in points {
                let minD = centroids.map { dist(point, $0) }.min() ?? 0
                distances.append(minD)
            }
            let total = distances.reduce(0, +)
            var pick = Double.random(in: 0..<max(total, 0.0001))
            for (i, d) in distances.enumerated() {
                pick -= d
                if pick <= 0 {
                    centroids.append(points[i])
                    break
                }
            }
            if centroids.count == points.count { break }
        }
        return centroids
    }

    private func downsample(_ image: CIImage, to size: Int) -> CIImage {
        let extent = image.extent
        let scale = CGFloat(size) / max(extent.width, extent.height)
        return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }

    private func pixelData(from ciImage: CIImage) -> [UInt8]? {
        let extent = ciImage.extent.integral
        guard extent.width > 0, extent.height > 0 else { return nil }
        var data = [UInt8](repeating: 0, count: Int(extent.width * extent.height * 4))
        context.render(
            ciImage,
            toBitmap: &data,
            rowBytes: Int(extent.width) * 4,
            bounds: extent,
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return data
    }

    private func defaultPalette(count: Int) -> [PaletteColor] {
        let defaults: [PaletteColor] = [
            PaletteColor(red: 0.77, green: 0.66, blue: 0.51, weight: 1),
            PaletteColor(red: 0.55, green: 0.48, blue: 0.42, weight: 0.8),
            PaletteColor(red: 0.89, green: 0.84, blue: 0.78, weight: 0.6),
            PaletteColor(red: 0.35, green: 0.32, blue: 0.29, weight: 0.4),
            PaletteColor(red: 0.95, green: 0.93, blue: 0.90, weight: 0.2)
        ]
        return Array(defaults.prefix(count))
    }
}
