import SwiftUI

struct RecentsView: View {
    @ObservedObject private var prefs = PreferencesStore.shared

    private var recentItems: [FileItem] {
        prefs.recents.compactMap { path in
            FileManager.default.fileExists(atPath: path) ? FileItem.make(from: URL(fileURLWithPath: path)) : nil
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if recentItems.isEmpty {
                    ContentUnavailableView("Sin archivos recientes", systemImage: "clock")
                } else {
                    ForEach(recentItems) { item in
                        NavigationLink {
                            FileViewerView(item: item)
                        } label: {
                            FileRowView(item: item, isFavorite: prefs.isFavorite(item.url.path)) {
                                prefs.toggleFavorite(item.url.path)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Recientes")
            .toolbar {
                if !recentItems.isEmpty {
                    Button("Limpiar") { prefs.clearRecents() }
                }
            }
        }
        .tint(prefs.theme.accentColor)
    }
}
