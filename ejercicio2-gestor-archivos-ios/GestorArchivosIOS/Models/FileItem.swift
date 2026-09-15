import Foundation
import UniformTypeIdentifiers

struct FileItem: Identifiable, Hashable {
    let url: URL
    let isDirectory: Bool
    let sizeBytes: Int
    let modifiedAt: Date

    var id: String { url.path }
    var name: String { url.lastPathComponent }

    var utType: UTType {
        UTType(filenameExtension: url.pathExtension) ?? .data
    }

    var systemImageName: String {
        if isDirectory { return "folder.fill" }
        if utType.conforms(to: .image) { return "photo" }
        if utType.conforms(to: .plainText) || utType.conforms(to: .text) { return "doc.text" }
        if utType.conforms(to: .audio) { return "waveform" }
        if utType.conforms(to: .movie) { return "film" }
        if utType.conforms(to: .pdf) { return "doc.richtext" }
        if utType.conforms(to: .archive) { return "doc.zipper" }
        return "doc"
    }

    static func make(from url: URL) -> FileItem? {
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
        let isDirectory = values?.isDirectory ?? false
        let size = values?.fileSize ?? 0
        let modified = values?.contentModificationDate ?? Date.distantPast
        return FileItem(url: url, isDirectory: isDirectory, sizeBytes: size, modifiedAt: modified)
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case name, date, size
    var id: String { rawValue }

    var label: String {
        switch self {
        case .name: return "Nombre"
        case .date: return "Fecha"
        case .size: return "Tamaño"
        }
    }

    var comparator: (FileItem, FileItem) -> Bool {
        switch self {
        case .name: return { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .date: return { $0.modifiedAt > $1.modifiedAt }
        case .size: return { $0.sizeBytes > $1.sizeBytes }
        }
    }
}
