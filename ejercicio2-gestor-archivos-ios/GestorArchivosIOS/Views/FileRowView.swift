import SwiftUI
import UniformTypeIdentifiers

struct FileRowView: View {
    let item: FileItem
    let isFavorite: Bool
    let onFavoriteTap: () -> Void

    private var dateLabel: String {
        item.modifiedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .lineLimit(1)
                Text(item.isDirectory ? dateLabel : "\(FileManagerService.shared.fileSizeLabel(item.sizeBytes)) · \(dateLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onFavoriteTap) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if item.utType.conforms(to: .image), let image = ThumbnailCache.shared.thumbnail(for: item) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            Image(systemName: item.systemImageName)
                .font(.title2)
                .frame(width: 36, height: 36)
                .foregroundStyle(.tint)
        }
    }
}
