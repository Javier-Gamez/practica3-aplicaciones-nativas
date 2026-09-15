import AVFoundation

/// Wraps AVAudioRecorder: start/stop, elapsed time, input level metering
/// (used to draw the sensitivity/level meter) and an optional recording
/// time limit (timer).
final class AudioRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var currentLevel: Float = 0 // 0...1, from averagePower
    @Published var sensitivity: Float = 1.0 // multiplier applied to the level readout
    @Published var timeLimitSeconds: Int = 0 // 0 = sin límite

    private var recorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private var tempURL: URL?

    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).m4a")
        tempURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.delegate = self
        recorder.record()
        self.recorder = recorder

        isRecording = true
        elapsedSeconds = 0
        startMetering()
    }

    func stopRecording() -> URL? {
        recorder?.stop()
        stopMetering()
        isRecording = false
        return tempURL
    }

    private func startMetering() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.recorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0) // -160...0 dB
            let normalized = max(0, (power + 60) / 60) // rough 0...1 mapping
            self.currentLevel = min(1, normalized * self.sensitivity)
            self.elapsedSeconds = recorder.currentTime

            if self.timeLimitSeconds > 0 && self.elapsedSeconds >= Double(self.timeLimitSeconds) {
                _ = self.stopRecording()
            }
        }
    }

    private func stopMetering() {
        levelTimer?.invalidate()
        levelTimer = nil
        currentLevel = 0
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {}

/// Plays back a recorded file with a simple play/pause/seek API.
final class AudioPlayerService: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0 // 0...1

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    func play(url: URL) {
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
        isPlaying = true
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, let player = self.player, player.duration > 0 else { return }
            self.progress = player.currentTime / player.duration
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        progressTimer?.invalidate()
        isPlaying = false
        progress = 0
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
