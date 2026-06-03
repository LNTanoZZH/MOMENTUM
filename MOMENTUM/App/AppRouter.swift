import SwiftUI

struct AppRouter: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationDestination(for: EditorRoute.self) { route in
                    if let image = ImageSessionStore.shared.image(for: route.imageID) {
                        ColorCardEditorView(
                            sourceImage: image,
                            livePhotoIdentifier: ImageSessionStore.shared.livePhotoIdentifier(for: route.imageID),
                            navigationPath: $navigationPath
                        )
                    }
                }
                .navigationDestination(for: ExportRoute.self) { route in
                    if let image = ImageSessionStore.shared.image(for: route.imageID) {
                        ExportRitualView(
                            renderedImage: image,
                            projectID: route.projectID,
                            navigationPath: $navigationPath
                        )
                    }
                }
        }
        .tint(MomentumColors.accentWarm)
    }
}

struct EditorRoute: Hashable {
    let imageID: UUID
}

struct ExportRoute: Hashable {
    let imageID: UUID
    let projectID: UUID
}
