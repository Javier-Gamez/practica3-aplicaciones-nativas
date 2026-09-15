import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var prefs = PreferencesStore.shared

    private var favoriteItems: [FileItem] {
        prefs.favorites.compactMap { path in
            FileItem.make(from: URL(fileURLWithPath: path))
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            List {
                if favoriteItems.isEmpty {
                    ContentUnavailableView("Sin favoritos", systemImage: "star")
                } else {
                    ForEach(favoriteItems) { item in
                        NavigationLink {
                            FileViewerView(item: item)
                        } label: {
                            FileRowView(item: item, isFavorite: true) {
                                prefs.toggleFavorite(item.url.path)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Favoritos")
        }
        .tint(prefs.theme.accentColor)
    }
}
