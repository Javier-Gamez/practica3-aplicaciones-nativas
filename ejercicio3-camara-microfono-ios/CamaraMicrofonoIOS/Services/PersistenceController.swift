import CoreData

/// Core Data stack. The model is built **programmatically** (NSManagedObjectModel)
/// instead of a `.xcdatamodeld` file, since that file format is normally edited
/// with Xcode's visual model editor and this project was authored outside Xcode.
/// It is fully equivalent at runtime -- feel free to replace it with a real
/// `.xcdatamodeld` in Xcode's editor if you prefer working visually.
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        let model = Self.buildModel()
        container = NSPersistentContainer(name: "CamaraMicrofono", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("No se pudo cargar Core Data: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "CapturedItemEntity"
        entity.managedObjectClassName = NSStringFromClass(CapturedItemEntity.self)

        func attribute(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = optional
            return attr
        }

        entity.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("kind", .stringAttributeType),
            attribute("fileName", .stringAttributeType),
            attribute("category", .stringAttributeType),
            attribute("createdAt", .dateAttributeType),
            attribute("durationSeconds", .doubleAttributeType, optional: true),
            attribute("latitude", .doubleAttributeType, optional: true),
            attribute("longitude", .doubleAttributeType, optional: true),
        ]

        model.entities = [entity]
        return model
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}

/// Minimal `NSManagedObject` subclass matching the programmatic model above.
@objc(CapturedItemEntity)
final class CapturedItemEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var kind: String
    @NSManaged var fileName: String
    @NSManaged var category: String
    @NSManaged var createdAt: Date
    @NSManaged var durationSeconds: Double
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double

    func toMediaItem() -> MediaItem {
        MediaItem(
            id: id,
            kind: MediaKind(rawValue: kind) ?? .photo,
            fileName: fileName,
            category: category,
            createdAt: createdAt,
            durationSeconds: kind == MediaKind.audio.rawValue ? durationSeconds : nil
        )
    }
}
