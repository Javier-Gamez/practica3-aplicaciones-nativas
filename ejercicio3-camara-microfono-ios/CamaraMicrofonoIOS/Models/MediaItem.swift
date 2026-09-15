import Foundation

enum MediaKind: String, Codable {
    case photo
    case audio
}

/// Plain struct mirror of the `CapturedItemEntity` Core Data record, used
/// throughout the UI layer so views don't depend on Core Data types directly.
struct MediaItem: Identifiable, Hashable {
    let id: UUID
    let kind: MediaKind
    let fileName: String
    let category: String
    let createdAt: Date
    let durationSeconds: Double?

    func fileURL(in directory: URL) -> URL {
        directory.appendingPathComponent(fileName)
    }
}
