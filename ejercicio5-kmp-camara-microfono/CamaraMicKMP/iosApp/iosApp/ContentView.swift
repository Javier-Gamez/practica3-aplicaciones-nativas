import SwiftUI
import Shared

/// Bridges the shared `MediaRepository.items: StateFlow<List<MediaItem>>`
/// into a plain SwiftUI `@Published` array using `FlowWatcher` (see
/// StateFlowWatcher.ios.kt in the shared module).
@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var items: [MediaItem] = []

    private let repository: MediaRepository
    private let watcher = FlowWatcher()

    init(repository: MediaRepository) {
        self.repository = repository
        watcher.watch(flow: repository.items) { [weak self] value in
            self?.items = value as? [MediaItem] ?? []
        }
    }

    deinit {
        watcher.cancel()
    }

    func delete(_ item: MediaItem) {
        repository.delete(item: item)
    }
}

struct ContentView: View {
    @StateObject private var gallery: GalleryViewModel

    init() {
        // In a real app, inject a single shared `MediaRepository` instance
        // from the App entry point instead of creating one per view.
        let repository = MediaRepository(store: PlatformFileStore())
        _gallery = StateObject(wrappedValue: GalleryViewModel(repository: repository))
    }

    var body: some View {
        TabView {
            Text("Cámara (ver CameraController en el módulo Shared)")
                .tabItem { Label("Cámara", systemImage: "camera") }

            Text("Micrófono (ver AudioRecorderController en el módulo Shared)")
                .tabItem { Label("Micrófono", systemImage: "mic") }

            List(gallery.items, id: \.id) { item in
                VStack(alignment: .leading) {
                    Text(item.fileName)
                    Text(item.category).font(.caption).foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button("Eliminar", role: .destructive) { gallery.delete(item) }
                }
            }
            .tabItem { Label("Galería", systemImage: "photo.on.rectangle") }
        }
        .tint(Color(red: 0.549, green: 0.114, blue: 0.251)) // Guinda
    }
}
