import Foundation
import SwiftUI

@MainActor
final class FileBrowserViewModel: ObservableObject {
    @Published var currentDirectory: URL
    @Published private(set) var items: [FileItem] = []
    @Published var searchQuery: String = "" { didSet { applyFilter() } }
    @Published private(set) var filteredItems: [FileItem] = []
    @Published var errorMessage: String?
    @Published var clipboard: (item: FileItem, isCut: Bool)?

    private let service = FileManagerService.shared
    private let prefs = PreferencesStore.shared
    let rootDirectory: URL

    init() {
        let root = FileManagerService.shared.documentsDirectory
        rootDirectory = root
        if let savedPath = PreferencesStore.shared.lastFolderPath,
           FileManager.default.fileExists(atPath: savedPath) {
            currentDirectory = URL(fileURLWithPath: savedPath, isDirectory: true)
        } else {
            currentDirectory = root
        }
        reload()
    }

    var breadcrumbs: [String] {
        let rootPath = rootDirectory.standardizedFileURL.path
        let currentPath = currentDirectory.standardizedFileURL.path
        guard currentPath.hasPrefix(rootPath), currentPath != rootPath else { return [] }
        let relative = String(currentPath.dropFirst(rootPath.count))
        return relative.split(separator: "/").map(String.init)
    }

    var isAtRoot: Bool { currentDirectory.standardizedFileURL == rootDirectory.standardizedFileURL }

    func reload() {
        do {
            items = try service.contents(of: currentDirectory, sortedBy: prefs.sortOption)
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyFilter() {
        filteredItems = searchQuery.isEmpty
            ? items
            : items.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    func setSortOption(_ option: SortOption) {
        prefs.sortOption = option
        reload()
    }

    func open(_ item: FileItem) {
        if item.isDirectory {
            currentDirectory = item.url
            prefs.lastFolderPath = item.url.path
            searchQuery = ""
            reload()
        } else {
            prefs.pushRecent(item.url.path)
        }
    }

    func navigateUp() {
        guard !isAtRoot else { return }
        currentDirectory = currentDirectory.deletingLastPathComponent()
        prefs.lastFolderPath = currentDirectory.path
        reload()
    }

    func navigateToBreadcrumb(index: Int) {
        let segments = Array(breadcrumbs.prefix(index + 1))
        var url = rootDirectory
        for segment in segments { url.appendPathComponent(segment) }
        currentDirectory = url
        prefs.lastFolderPath = url.path
        reload()
    }

    func createFolder(named name: String) {
        do {
            try service.createFolder(named: name, in: currentDirectory)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(_ item: FileItem, to newName: String) {
        do {
            _ = try service.rename(item, to: newName)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ item: FileItem) {
        do {
            try service.delete(item)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func copyToClipboard(_ item: FileItem) { clipboard = (item, false) }
    func cutToClipboard(_ item: FileItem) { clipboard = (item, true) }

    func pasteHere() {
        guard let clipboard else { return }
        do {
            if clipboard.isCut {
                try service.move(clipboard.item, into: currentDirectory)
            } else {
                try service.copy(clipboard.item, into: currentDirectory)
            }
            self.clipboard = nil
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importFile(from url: URL) {
        do {
            _ = try service.importExternalFile(from: url, into: currentDirectory)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
