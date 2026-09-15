import SwiftUI

struct GalleryView: View {
    @ObservedObject private var prefs = PreferencesStore.shared
    @State private var items: [MediaItem] = []
    @State private var selectedCategory: String = "Todas"

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    private var categories: [String] { ["Todas"] + MediaLibraryService.shared.categories() }

    private var visibleItems: [MediaItem] {
        selectedCategory == "Todas" ? items : items.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Categoría", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding()

                if visibleItems.isEmpty {
                    ContentUnavailableView("Sin contenido en esta categoría", systemImage: "photo.on.rectangle.angled")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(visibleItems) { item in
                                NavigationLink {
                                    MediaDetailView(item: item, onDeleted: reload)
                                } label: {
                                    thumbnail(for: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Galería")
            .onAppear(perform: reload)
        }
        .tint(prefs.theme.accentColor)
    }

    private func reload() { items = MediaLibraryService.shared.fetchAll() }

    @ViewBuilder
    private func thumbnail(for item: MediaItem) -> some View {
        let url = item.fileURL(in: MediaLibraryService.shared.mediaDirectory)
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6))
            if item.kind == .photo, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.title)
                    Text(item.durationSeconds.map { String(format: "%.0fs", $0) } ?? "")
                        .font(.caption2)
                }
                .foregroundStyle(prefs.theme.accentColor)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
