package mx.ipn.escom.camaramic

import kotlinx.coroutines.flow.StateFlow

/** Wraps native audio recording (AVAudioRecorder on iOS, MediaRecorder on Android). */
expect class AudioRecorderController {
    val isRecording: StateFlow<Boolean>
    val levelMeter: StateFlow<Float> // 0f..1f
    val elapsedSeconds: StateFlow<Double>

    suspend fun start(platformContext: Any?)

    /** Stops recording and returns the raw audio bytes (AAC/M4A). */
    suspend fun stop(): ByteArray?
}
