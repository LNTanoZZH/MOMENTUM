import SwiftUI
import SwiftData

@main
struct MomentumApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouter()
        }
        .modelContainer(for: WorkCollectionItem.self)
    }
}
