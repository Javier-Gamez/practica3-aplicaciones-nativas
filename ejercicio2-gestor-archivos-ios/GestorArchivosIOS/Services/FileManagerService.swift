import Foundation

enum FileServiceError: LocalizedError {
    case notFound
    case unsupportedType
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "El archivo o carpeta ya no existe."
        case .unsupportedType: return "Tipo de archivo no soportado."
        case .operationFailed(let reason): return reason
        }
    }
}

/// Wraps every filesystem operation, scoped to the app sandbox (Documents).
/// The app never attempts to read or write outside this container, per the
/// iOS sandbox requirements in the practice.
final class FileManagerService {
    static let shared = FileManagerService()
    private let fm = FileManager.default

    var documentsDirectory: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func contents(of directory: URL, sortedBy sort: SortOption) throws -> [FileItem] {
        let urls = try fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        var items = urls.compactMap { FileItem.make(from: $0) }
        items.sort { a, b in
            if a.isDirectory != b.isDirectory { return a.isDirectory }
            return sort.comparator(a, b)
        }
        return items
    }

    func createFolder(named name: String, in directory: URL) throws {
        let target = directory.appendingPathComponent(name, isDirectory: true)
        try fm.createDirectory(at: target, withIntermediateDirectories: false)
    }

    func rename(_ item: FileItem, to newName: String) throws -> URL {
        let newURL = item.url.deletingLastPathComponent().appendingPathComponent(newName)
        try fm.moveItem(at: item.url, to: newURL)
        return newURL
    }

    func delete(_ item: FileItem) throws {
        try fm.removeItem(at: item.url)
    }

    func copy(_ item: FileItem, into directory: URL) throws {
        let dest = directory.appendingPathComponent(item.name)
        try fm.copyItem(at: item.url, to: dest)
    }

    func move(_ item: FileItem, into directory: URL) throws {
        let dest = directory.appendingPathComponent(item.name)
        try fm.moveItem(at: item.url, to: dest)
    }

    func readText(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    func fileSizeLabel(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    /// Copies a file picked from outside the sandbox (Files app / iCloud Drive)
    /// into the given directory, resolving the security-scoped bookmark first.
    func importExternalFile(from sourceURL: URL, into directory: URL) throws -> URL {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer { if accessed { sourceURL.stopAccessingSecurityScopedResource() } }

        var destination = directory.appendingPathComponent(sourceURL.lastPathComponent)
        if fm.fileExists(atPath: destination.path) {
            let base = destination.deletingPathExtension().lastPathComponent
            let ext = destination.pathExtension
            destination = directory.appendingPathComponent("\(base)-\(Int(Date().timeIntervalSince1970)).\(ext)")
        }
        try fm.copyItem(at: sourceURL, to: destination)
        return destination
    }
}
