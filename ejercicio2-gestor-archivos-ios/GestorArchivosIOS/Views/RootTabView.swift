import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            FileBrowserView()
                .tabItem { Label("Archivos", systemImage: "folder") }
            FavoritesView()
                .tabItem { Label("Favoritos", systemImage: "star") }
            RecentsView()
                .tabItem { Label("Recientes", systemImage: "clock") }
        }
    }
}
