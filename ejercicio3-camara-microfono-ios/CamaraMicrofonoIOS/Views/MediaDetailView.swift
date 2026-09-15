import SwiftUI

struct MediaDetailView: View {
    let item: MediaItem
    var onDeleted: () -> Void

    @StateObject private var player = AudioPlayerService()
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var rotation: Angle = .zero

    private var fileURL: URL { item.fileURL(in: MediaLibraryService.shared.mediaDirectory) }

    var body: some View {
        VStack {
            switch item.kind {
            case .photo:
                photoDetail
            case .audio:
                audioDetail
            }
        }
        .navigationTitle(item.category)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("¿Eliminar este elemento?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) {
                MediaLibraryService.shared.delete(item)
                onDeleted()
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private var photoDetail: some View {
        Group {
            if let image = UIImage(contentsOfFile: fileURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(rotation)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button { withAnimation { rotation += .degrees(90) } } label: {
                                Image(systemName: "rotate.right")
                            }
                        }
                    }
            } else {
                Text("No se pudo cargar la imagen")
            }
        }
    }

    private var audioDetail: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(PreferencesStore.shared.theme.accentColor)

            ProgressView(value: player.progress)
                .padding(.horizontal, 32)

            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.secondary)

            Button {
                player.isPlaying ? player.pause() : player.play(url: fileURL)
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
            }
        }
        .padding()
        .onDisappear { player.stop() }
    }
}
