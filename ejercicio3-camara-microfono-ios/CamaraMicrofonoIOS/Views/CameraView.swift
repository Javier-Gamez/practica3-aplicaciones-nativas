import SwiftUI

struct CameraView: View {
    @StateObject private var camera = CameraService()
    @ObservedObject private var prefs = PreferencesStore.shared

    @State private var showPhotoPicker = false
    @State private var capturedImage: UIImage?
    @State private var showCategoryPrompt = false
    @State private var categoryName = ""
    @State private var errorMessage: String?

    private let cameraAvailable = CameraService.isCameraAvailable

    var body: some View {
        NavigationStack {
            ZStack {
                if cameraAvailable {
                    CameraPreviewView(session: camera.session)
                        .ignoresSafeArea()
                        .onAppear { camera.configure(); camera.start() }
                        .onDisappear { camera.stop() }
                } else {
                    unavailableCameraNotice
                }

                VStack {
                    Spacer()
                    controls
                }
            }
            .navigationTitle("Cámara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Tema", selection: $prefs.theme) {
                            ForEach(AppTheme.allCases) { theme in Text(theme.label).tag(theme) }
                        }
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoLibraryPickerView { image in
                    capturedImage = image
                    showCategoryPrompt = true
                }
            }
            .alert("Guardar en categoría", isPresented: $showCategoryPrompt) {
                TextField("Categoría", text: $categoryName)
                Button("Cancelar", role: .cancel) { capturedImage = nil }
                Button("Guardar") { saveCapturedImage() }
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .tint(prefs.theme.accentColor)
    }

    private var unavailableCameraNotice: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.on.rectangle.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("El simulador no tiene cámara física.")
                .font(.headline)
            Text("Selecciona una foto de la fototeca para simular una captura, o compila en un iPhone físico.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Elegir de la fototeca") { showPhotoPicker = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var controls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                Button { camera.flashOn.toggle() } label: {
                    Image(systemName: camera.flashOn ? "bolt.fill" : "bolt.slash")
                }
                Menu {
                    Picker("Temporizador", selection: $camera.timerSeconds) {
                        Text("Sin temporizador").tag(0)
                        Text("3 segundos").tag(3)
                        Text("10 segundos").tag(10)
                    }
                } label: {
                    Image(systemName: "timer")
                }
                Menu {
                    Picker("Filtro", selection: $camera.filter) {
                        ForEach(CameraFilter.allCases) { filter in Text(filter.label).tag(filter) }
                    }
                } label: {
                    Image(systemName: "camera.filters")
                }
            }
            .font(.title2)
            .foregroundStyle(.white)
            .padding(10)
            .background(.black.opacity(0.4), in: Capsule())

            HStack {
                Button { showPhotoPicker = true } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                Spacer()
                Button {
                    guard cameraAvailable else { return }
                    camera.capturePhoto { image in
                        capturedImage = image
                        showCategoryPrompt = image != nil
                    }
                } label: {
                    Circle().stroke(.white, lineWidth: 4).frame(width: 72, height: 72)
                        .overlay(Circle().fill(.white).frame(width: 60, height: 60))
                }
                .disabled(!cameraAvailable)
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }

    private func saveCapturedImage() {
        guard let image = capturedImage else { return }
        let category = categoryName.isEmpty ? "General" : categoryName
        do {
            _ = try MediaLibraryService.shared.savePhoto(image, category: category)
            prefs.lastCategory = category
        } catch {
            errorMessage = error.localizedDescription
        }
        capturedImage = nil
        categoryName = ""
    }
}
