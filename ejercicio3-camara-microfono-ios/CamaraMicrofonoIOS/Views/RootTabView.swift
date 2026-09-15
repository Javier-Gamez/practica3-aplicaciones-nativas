import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem { Label("Cámara", systemImage: "camera") }
            AudioRecorderView()
                .tabItem { Label("Micrófono", systemImage: "mic") }
            GalleryView()
                .tabItem { Label("Galería", systemImage: "photo.stack") }
        }
    }
}
