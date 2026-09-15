import SwiftUI

struct AudioRecorderView: View {
    @StateObject private var recorder = AudioRecorderService()
    @ObservedObject private var prefs = PreferencesStore.shared

    @State private var permissionDenied = false
    @State private var showCategoryPrompt = false
    @State private var categoryName = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                levelMeter

                Text(timeLabel)
                    .font(.system(size: 40, weight: .semibold, design: .monospaced))

                VStack(alignment: .leading) {
                    Text("Sensibilidad")
                    Slider(value: $recorder.sensitivity, in: 0.5...3)
                }
                .padding(.horizontal, 32)

                Menu {
                    Picker("Límite", selection: $recorder.timeLimitSeconds) {
                        Text("Sin límite").tag(0)
                        Text("30 segundos").tag(30)
                        Text("60 segundos").tag(60)
                        Text("120 segundos").tag(120)
                    }
                } label: {
                    Label(recorder.timeLimitSeconds == 0 ? "Sin límite de tiempo" : "Límite: \(recorder.timeLimitSeconds)s",
                          systemImage: "hourglass")
                }

                Button {
                    toggleRecording()
                } label: {
                    Circle()
                        .fill(recorder.isRecording ? Color.red : prefs.theme.accentColor)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        )
                }

                Spacer()
            }
            .navigationTitle("Micrófono")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Permiso de micrófono denegado", isPresented: $permissionDenied) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Activa el acceso al micrófono en Ajustes para grabar audio.")
            }
            .alert("Guardar en categoría", isPresented: $showCategoryPrompt) {
                TextField("Categoría", text: $categoryName)
                Button("Descartar", role: .destructive) {}
                Button("Guardar") { saveRecording() }
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .tint(prefs.theme.accentColor)
    }

    private var timeLabel: String {
        let minutes = Int(recorder.elapsedSeconds) / 60
        let seconds = Int(recorder.elapsedSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var levelMeter: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < Int(recorder.currentLevel * 20) ? prefs.theme.accentColor : Color(.systemGray5))
                    .frame(width: 8, height: 24)
            }
        }
    }

    @State private var lastStoppedURL: URL?

    private func toggleRecording() {
        if recorder.isRecording {
            lastStoppedURL = recorder.stopRecording()
            showCategoryPrompt = lastStoppedURL != nil
        } else {
            recorder.requestPermission { granted in
                guard granted else { permissionDenied = true; return }
                do {
                    try recorder.startRecording()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveRecording() {
        guard let url = lastStoppedURL else { return }
        let category = categoryName.isEmpty ? "General" : categoryName
        do {
            _ = try MediaLibraryService.shared.saveAudio(temporaryURL: url, category: category, duration: recorder.elapsedSeconds)
            prefs.lastCategory = category
        } catch {
            errorMessage = error.localizedDescription
        }
        categoryName = ""
        lastStoppedURL = nil
    }
}
