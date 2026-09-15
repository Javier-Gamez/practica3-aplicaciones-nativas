import UIKit

/// In-memory cache for image thumbnails, keyed by file path + modification
/// time so a replaced file never serves a stale thumbnail.
final class ThumbnailCache {
    static let shared = ThumbnailCache()
    private let cache = NSCache<NSString, UIImage>()

    func thumbnail(for item: FileItem, maxDimension: CGFloat = 120) -> UIImage? {
        let key = "\(item.url.path)-\(item.modifiedAt.timeIntervalSince1970)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }
        guard let original = UIImage(contentsOfFile: item.url.path) else { return nil }
        let thumbnail = original.resized(maxDimension: maxDimension)
        cache.setObject(thumbnail, forKey: key)
        return thumbnail
    }
}

private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let scale = maxDimension / max(size.width, size.height)
        guard scale < 1 else { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
