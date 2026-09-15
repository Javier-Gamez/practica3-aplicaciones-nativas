import SwiftUI

struct FileBrowserView: View {
    @StateObject private var viewModel = FileBrowserViewModel()
    @ObservedObject private var prefs = PreferencesStore.shared

    @State private var showNewFolderPrompt = false
    @State private var newFolderName = ""
    @State private var renameTarget: FileItem?
    @State private var renameText = ""
    @State private var deleteTarget: FileItem?
    @State private var showImporter = false
    @State private var showThemePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                breadcrumbBar
                Divider()
                list
            }
            .navigationTitle("Gestor de Archivos")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Buscar en esta carpeta")
            .toolbar { toolbarContent }
            .refreshable { viewModel.reload() }
            .alert("Nueva carpeta", isPresented: $showNewFolderPrompt) {
                TextField("Nombre", text: $newFolderName)
                Button("Cancelar", role: .cancel) {}
                Button("Crear") {
                    if !newFolderName.isEmpty { viewModel.createFolder(named: newFolderName) }
                    newFolderName = ""
                }
            }
            .alert("Renombrar", isPresented: Binding(get: { renameTarget != nil }, set: { if !$0 { renameTarget = nil } })) {
                TextField("Nombre", text: $renameText)
                Button("Cancelar", role: .cancel) { renameTarget = nil }
                Button("Guardar") {
                    if let target = renameTarget { viewModel.rename(target, to: renameText) }
                    renameTarget = nil
                }
            }
            .confirmationDialog(
                "¿Eliminar \"\(deleteTarget?.name ?? "")\"?",
                isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } }),
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    if let target = deleteTarget { viewModel.delete(target) }
                    deleteTarget = nil
                }
                Button("Cancelar", role: .cancel) { deleteTarget = nil }
            }
            .sheet(isPresented: $showImporter) {
                DocumentPickerView { url in viewModel.importFile(from: url) }
            }
            .confirmationDialog("Tema", isPresented: $showThemePicker, titleVisibility: .visible) {
                ForEach(AppTheme.allCases) { theme in
                    Button(theme.label) { prefs.theme = theme }
                }
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .tint(prefs.theme.accentColor)
    }

    private var breadcrumbBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                Button("Inicio") { while !viewModel.isAtRoot { viewModel.navigateUp() } }
                    .disabled(viewModel.isAtRoot)
                ForEach(Array(viewModel.breadcrumbs.enumerated()), id: \.offset) { index, segment in
                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.secondary)
                    Button(segment) { viewModel.navigateToBreadcrumb(index: index) }
                        .disabled(index == viewModel.breadcrumbs.count - 1)
                }
            }
            .font(.subheadline)
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                rowView(for: item)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredItems.isEmpty {
                ContentUnavailableView("Carpeta vacía", systemImage: "folder")
            }
        }
    }

    @ViewBuilder
    private func rowView(for item: FileItem) -> some View {
        Group {
            if item.isDirectory {
                Button {
                    viewModel.open(item)
                } label: {
                    FileRowView(
                        item: item,
                        isFavorite: prefs.isFavorite(item.url.path),
                        onFavoriteTap: { prefs.toggleFavorite(item.url.path) }
                    )
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    FileViewerView(item: item)
                        .onAppear { viewModel.open(item) }
                } label: {
                    FileRowView(
                        item: item,
                        isFavorite: prefs.isFavorite(item.url.path),
                        onFavoriteTap: { prefs.toggleFavorite(item.url.path) }
                    )
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { deleteTarget = item } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
        .contextMenu {
            Button { renameText = item.name; renameTarget = item } label: {
                Label("Renombrar", systemImage: "pencil")
            }
            Button { viewModel.copyToClipboard(item) } label: {
                Label("Copiar", systemImage: "doc.on.doc")
            }
            Button { viewModel.cutToClipboard(item) } label: {
                Label("Cortar", systemImage: "scissors")
            }
            Button { prefs.toggleFavorite(item.url.path) } label: {
                Label(prefs.isFavorite(item.url.path) ? "Quitar de favoritos" : "Agregar a favoritos",
                      systemImage: prefs.isFavorite(item.url.path) ? "star.slash" : "star")
            }
            Button(role: .destructive) { deleteTarget = item } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Picker("Ordenar por", selection: Binding(get: { prefs.sortOption }, set: viewModel.setSortOption)) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if viewModel.clipboard != nil {
                Button { viewModel.pasteHere() } label: { Image(systemName: "doc.on.clipboard") }
            }
            Button { showThemePicker = true } label: { Image(systemName: "paintpalette") }
            Menu {
                Button { showNewFolderPrompt = true } label: { Label("Nueva carpeta", systemImage: "folder.badge.plus") }
                Button { showImporter = true } label: { Label("Importar archivo", systemImage: "square.and.arrow.down") }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
