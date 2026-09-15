import SwiftUI
import UniformTypeIdentifiers

/// In-app preview for images (pinch zoom / rotate) and text files, with a
/// fallback to QuickLook for everything else (PDF, audio, video, etc.).
struct FileViewerView: View {
    let item: FileItem
    @State private var textContent: String = ""
    @State private var rotation: Angle = .zero
    @State private var showShareSheet = false

    var body: some View {
        Group {
            if item.utType.conforms(to: .image) {
                imagePreview
            } else if item.utType.conforms(to: .plainText) || item.utType.conforms(to: .text) {
                textPreview
            } else {
                QuickLookView(url: item.url)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showShareSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [item.url])
        }
        .task {
            if item.utType.conforms(to: .plainText) || item.utType.conforms(to: .text) {
                textContent = (try? FileManagerService.shared.readText(item.url)) ?? "No se pudo leer el archivo."
            }
        }
    }

    private var imagePreview: some View {
        GeometryReader { geo in
            if let uiImage = UIImage(contentsOfFile: item.url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(rotation)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .modifier(PinchZoomModifier())
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation { rotation += .degrees(90) }
                            } label: {
                                Image(systemName: "rotate.right")
                            }
                        }
                    }
            } else {
                Text("No se pudo cargar la imagen")
            }
        }
    }

    private var textPreview: some View {
        ScrollView {
            Text(textContent)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Adds pinch-to-zoom and drag-to-pan on top of a fitted image.
private struct PinchZoomModifier: ViewModifier {
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in scale = min(max(lastScale * value, 1), 6) }
                    .onEnded { _ in lastScale = scale }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard scale > 1 else { return }
                        offset = CGSize(width: lastOffset.width + value.translation.width,
                                         height: lastOffset.height + value.translation.height)
                    }
                    .onEnded { _ in lastOffset = offset }
            )
            .onTapGesture(count: 2) {
                withAnimation {
                    scale = 1; lastScale = 1; offset = .zero; lastOffset = .zero
                }
            }
    }
}
