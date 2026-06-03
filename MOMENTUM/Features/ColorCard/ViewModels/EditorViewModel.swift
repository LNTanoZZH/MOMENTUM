import Combine
import Photos
import PhotosUI
import SwiftUI
import UIKit

enum EditorTool: String, CaseIterable, Identifiable {
    case layout, color, fill, text, dots

    var id: String { rawValue }

    var label: String {
        switch self {
        case .layout: return "布局"
        case .color: return "颜色"
        case .fill: return "填充"
        case .text: return "文字"
        case .dots: return "波点"
        }
    }

    var systemImage: String {
        switch self {
        case .layout: return "rectangle.3.group"
        case .color: return "paintpalette"
        case .fill: return "square.fill.on.square.fill"
        case .text: return "textformat"
        case .dots: return "sparkles"
        }
    }
}

enum ColorPickerMode: String, CaseIterable, Identifiable {
    case grid, spectrum, rgb

    var id: String { rawValue }

    var label: String {
        switch self {
        case .grid: return "网格"
        case .spectrum: return "光谱"
        case .rgb: return "RGB"
        }
    }
}

enum ColorSelectionTarget {
    case primary
    case secondary
}

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var project: EditProject
    @Published var renderedPreview: UIImage?
    @Published var activeTool: EditorTool?
    @Published var isRendering = false
    @Published var isEyedropperActive = false
    @Published var colorPickerMode: ColorPickerMode = .grid
    @Published var colorSelectionTarget: ColorSelectionTarget = .primary
    @Published var isDrawingDotPath = false
    @Published var dotPathPoints: [CGPoint] = []
    @Published var livePhoto: PHLivePhoto?
    @Published var showTextEditor = false

    private let composer = ImageComposer()
    private let colorExtractor = ColorExtractor()
    private let dotRenderer = DotRenderer()
    private let undoManager = UndoRedoManager<EditProjectSnapshot>()
    private var renderTask: Task<Void, Never>?

    var canUndo: Bool { undoManager.canUndo }
    var canRedo: Bool { undoManager.canRedo }

    init(sourceImage: UIImage, livePhotoIdentifier: String? = nil) {
        let palette = ColorExtractor().extractPalette(from: sourceImage)
        self.project = EditProject(
            sourceImage: sourceImage,
            livePhotoIdentifier: livePhotoIdentifier,
            palette: palette
        )
        if let first = palette.first {
            project.colorCard.primaryColor = first
        }
        scheduleRender(previewScale: 0.5)
        loadLivePhotoIfNeeded()
    }

    func loadLivePhotoIfNeeded() {
        guard let id = project.livePhotoIdentifier else { return }
        Task {
            let size = project.sourceImage.size
            livePhoto = await LivePhotoService.shared.fetchLivePhoto(
                identifier: id,
                targetSize: size
            )
        }
    }

    func selectTool(_ tool: EditorTool) {
        if activeTool == tool {
            activeTool = nil
        } else {
            activeTool = tool
        }
    }

    func snapshot() {
        undoManager.push(EditProjectSnapshot(from: project))
    }

    func undo() {
        guard let previous = undoManager.undo(current: EditProjectSnapshot(from: project)) else { return }
        project = previous.toProject(sourceImage: project.sourceImage, livePhotoIdentifier: project.livePhotoIdentifier)
        scheduleRender(previewScale: 0.5)
    }

    func redo() {
        guard let next = undoManager.redo(current: EditProjectSnapshot(from: project)) else { return }
        project = next.toProject(sourceImage: project.sourceImage, livePhotoIdentifier: project.livePhotoIdentifier)
        scheduleRender(previewScale: 0.5)
    }

    func setPlacement(_ placement: CardPlacement) {
        snapshot()
        project.colorCard.placement = placement
        FeedbackService.shared.play(.filmAdvance)
        scheduleRender(previewScale: 0.5)
    }

    func setCardSizeRatio(_ ratio: Double) {
        project.colorCard.cardSizeRatio = CGFloat(ratio)
        scheduleRender(previewScale: 0.5)
    }

    func commitCardSizeRatio(_ ratio: Double) {
        snapshot()
        project.colorCard.cardSizeRatio = CGFloat(ratio)
        scheduleRender(previewScale: 0.5)
    }

    func setPrimaryColor(_ color: PaletteColor) {
        snapshot()
        project.colorCard.primaryColor = color
        scheduleRender(previewScale: 0.5)
    }

    func setSecondaryColor(_ color: PaletteColor) {
        snapshot()
        project.colorCard.secondaryColor = color
        scheduleRender(previewScale: 0.5)
    }

    func setFillStyle(_ style: FillStyle) {
        snapshot()
        project.colorCard.fill = style
        scheduleRender(previewScale: 0.5)
    }

    func setGradientDirection(_ direction: GradientDirection) {
        project.colorCard.gradientDirection = direction
        scheduleRender(previewScale: 0.5)
    }

    func setStripeWidth(_ width: Double) {
        project.colorCard.stripeWidth = CGFloat(width)
        scheduleRender(previewScale: 0.5)
    }

    func commitStripeWidth(_ width: Double) {
        snapshot()
        project.colorCard.stripeWidth = CGFloat(width)
        scheduleRender(previewScale: 0.5)
    }

    func setStripeDirection(_ direction: StripeDirection) {
        snapshot()
        project.colorCard.stripeDirection = direction
        scheduleRender(previewScale: 0.5)
    }

    func setGrainIntensity(_ value: Double) {
        project.colorCard.grainIntensity = value
        scheduleRender(previewScale: 0.5)
    }

    func commitGrainIntensity(_ value: Double) {
        snapshot()
        project.colorCard.grainIntensity = value
        scheduleRender(previewScale: 0.5)
    }

    func updateText(_ text: CardText) {
        snapshot()
        project.colorCard.text = text.content.isEmpty ? nil : text
        scheduleRender(previewScale: 0.5)
    }

    func regenerateRandomDots() {
        snapshot()
        let layout = composer.layout(for: project)
        project.dotLayer.randomSeed = UInt64(Date().timeIntervalSince1970)
        project.dotLayer.dots = dotRenderer.generateRandomDots(layer: project.dotLayer, layout: layout)
        scheduleRender(previewScale: 0.5)
    }

    func setDotCount(_ count: Double) {
        project.dotLayer.randomCount = Int(count)
        regenerateRandomDotsWithoutSnapshot()
    }

    func commitDotCount(_ count: Double) {
        snapshot()
        project.dotLayer.randomCount = Int(count)
        regenerateRandomDotsWithoutSnapshot()
    }

    func setDotBaseSize(_ size: Double) {
        project.dotLayer.baseSize = size
        regenerateRandomDotsWithoutSnapshot()
    }

    func commitDotBaseSize(_ size: Double) {
        snapshot()
        project.dotLayer.baseSize = size
        regenerateRandomDotsWithoutSnapshot()
    }

    func setDotSizeVariance(_ variance: Double) {
        project.dotLayer.sizeVariance = variance
        regenerateRandomDotsWithoutSnapshot()
    }

    func commitDotSizeVariance(_ variance: Double) {
        snapshot()
        project.dotLayer.sizeVariance = variance
        regenerateRandomDotsWithoutSnapshot()
    }

    func setDotShape(_ shape: DotShape) {
        snapshot()
        project.dotLayer.selectedShape = shape
    }

    func setDotMode(_ mode: DotGenerationMode) {
        snapshot()
        project.dotLayer.generationMode = mode
        if mode == .random {
            regenerateRandomDotsWithoutSnapshot()
        }
    }

    private func regenerateRandomDotsWithoutSnapshot() {
        let layout = composer.layout(for: project)
        project.dotLayer.dots = dotRenderer.generateRandomDots(layer: project.dotLayer, layout: layout)
        scheduleRender(previewScale: 0.5)
    }

    func addDot(at normalizedPoint: CGPoint) {
        snapshot()
        let layout = composer.layout(for: project)
        let region = LayoutCalculator().region(for: normalizedPoint, layout: layout)
        let dot = DotElement(
            shape: project.dotLayer.selectedShape,
            center: normalizedPoint,
            size: CGFloat(project.dotLayer.baseSize),
            rotation: Double.random(in: 0..<360),
            region: region
        )
        project.dotLayer.dots.append(dot)
        scheduleRender(previewScale: 0.5)
    }

    func beginDotPath(at point: CGPoint) {
        isDrawingDotPath = true
        dotPathPoints = [point]
    }

    func appendDotPath(point: CGPoint) {
        dotPathPoints.append(point)
    }

    func finishDotPath() {
        guard isDrawingDotPath, dotPathPoints.count >= 2 else {
            isDrawingDotPath = false
            dotPathPoints = []
            return
        }
        snapshot()
        let layout = composer.layout(for: project)
        let newDots = dotRenderer.generatePathDots(
            path: dotPathPoints,
            layer: project.dotLayer,
            layout: layout
        )
        project.dotLayer.dots.append(contentsOf: newDots)
        isDrawingDotPath = false
        dotPathPoints = []
        scheduleRender(previewScale: 0.5)
    }

    func pickColor(at canvasNormalizedPoint: CGPoint) {
        let layout = composer.layout(for: project)
        let canvasPoint = CGPoint(
            x: canvasNormalizedPoint.x * layout.canvasSize.width,
            y: canvasNormalizedPoint.y * layout.canvasSize.height
        )
        let sourcePoint: CGPoint
        if layout.sourceRect.contains(canvasPoint) {
            sourcePoint = CGPoint(
                x: (canvasPoint.x - layout.sourceRect.minX) / layout.sourceRect.width,
                y: (canvasPoint.y - layout.sourceRect.minY) / layout.sourceRect.height
            )
        } else {
            sourcePoint = canvasNormalizedPoint
        }
        let color = colorExtractor.colorAt(point: sourcePoint, in: project.sourceImage)
        switch colorSelectionTarget {
        case .primary:
            setPrimaryColor(color)
        case .secondary:
            setSecondaryColor(color)
        }
        isEyedropperActive = false
        FeedbackService.shared.play(.lightTap)
    }

    func renderFullResolution() async -> UIImage? {
        ImageComposer().compose(project: project, previewScale: 1.0)
    }

    private func scheduleRender(previewScale: CGFloat) {
        renderTask?.cancel()
        renderTask = Task { @MainActor in
            isRendering = true
            try? await Task.sleep(nanoseconds: 80_000_000)
            guard !Task.isCancelled else { return }
            let image = ImageComposer().compose(project: project, previewScale: previewScale)
            guard !Task.isCancelled else { return }
            renderedPreview = image
            isRendering = false
        }
    }
}

struct EditProjectSnapshot: Hashable {
    var colorCard: ColorCardConfig
    var dotLayer: DotLayer
    var palette: [PaletteColor]

    init(from project: EditProject) {
        self.colorCard = project.colorCard
        self.dotLayer = project.dotLayer
        self.palette = project.palette
    }

    func toProject(sourceImage: UIImage, livePhotoIdentifier: String?) -> EditProject {
        var p = EditProject(sourceImage: sourceImage, livePhotoIdentifier: livePhotoIdentifier, palette: palette)
        p.colorCard = colorCard
        p.dotLayer = dotLayer
        return p
    }
}
