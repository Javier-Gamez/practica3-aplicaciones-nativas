import CoreData
import UIKit

/// Owns the "Media" folder inside the app sandbox and keeps Core Data metadata
/// (date, category, duration) in sync with what is actually on disk.
final class MediaLibraryService {
    static let shared = MediaLibraryService()

    private let context = PersistenceController.shared.container.viewContext

    let mediaDirectory: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Media", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    func savePhoto(_ image: UIImage, category: String) throws -> MediaItem {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "MediaLibrary", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo codificar la imagen"])
        }
        let fileName = "IMG-\(Int(Date().timeIntervalSince1970)).jpg"
        try data.write(to: mediaDirectory.appendingPathComponent(fileName))
        return try insertRecord(kind: .photo, fileName: fileName, category: category, duration: nil)
    }

    func saveAudio(temporaryURL: URL, category: String, duration: Double) throws -> MediaItem {
        let fileName = "REC-\(Int(Date().timeIntervalSince1970)).m4a"
        let destination = mediaDirectory.appendingPathComponent(fileName)
        try FileManager.default.moveItem(at: temporaryURL, to: destination)
        return try insertRecord(kind: .audio, fileName: fileName, category: category, duration: duration)
    }

    private func insertRecord(kind: MediaKind, fileName: String, category: String, duration: Double?) throws -> MediaItem {
        let entity = CapturedItemEntity(context: context)
        entity.id = UUID()
        entity.kind = kind.rawValue
        entity.fileName = fileName
        entity.category = category
        entity.createdAt = Date()
        entity.durationSeconds = duration ?? 0
        try context.save()
        return entity.toMediaItem()
    }

    func fetchAll() -> [MediaItem] {
        let request = NSFetchRequest<CapturedItemEntity>(entityName: "CapturedItemEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request))?.map { $0.toMediaItem() } ?? []
    }

    func categories() -> [String] {
        Array(Set(fetchAll().map(\.category))).sorted()
    }

    func delete(_ item: MediaItem) {
        let request = NSFetchRequest<CapturedItemEntity>(entityName: "CapturedItemEntity")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            try? context.save()
        }
        try? FileManager.default.removeItem(at: item.fileURL(in: mediaDirectory))
    }
}
