package mx.ipn.escom.camaramic

import android.content.Context
import android.media.MediaRecorder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File

actual class AudioRecorderController {
    private var recorder: MediaRecorder? = null
    private var outputFile: File? = null
    private var meterJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Default)

    private val _isRecording = MutableStateFlow(false)
    actual val isRecording: StateFlow<Boolean> = _isRecording.asStateFlow()

    private val _levelMeter = MutableStateFlow(0f)
    actual val levelMeter: StateFlow<Float> = _levelMeter.asStateFlow()

    private val _elapsedSeconds = MutableStateFlow(0.0)
    actual val elapsedSeconds: StateFlow<Double> = _elapsedSeconds.asStateFlow()

    actual suspend fun start(platformContext: Any?) {
        val context = platformContext as? Context ?: return
        val file = File.createTempFile("rec-", ".m4a", context.cacheDir)
        outputFile = file

        @Suppress("DEPRECATION")
        val mediaRecorder = if (android.os.Build.VERSION.SDK_INT >= 31) {
            MediaRecorder(context)
        } else {
            MediaRecorder()
        }
        mediaRecorder.apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setOutputFile(file.absolutePath)
            prepare()
            start()
        }
        recorder = mediaRecorder
        _isRecording.value = true
        _elapsedSeconds.value = 0.0

        meterJob = scope.launch {
            val startTime = System.currentTimeMillis()
            while (_isRecording.value) {
                val amplitude = runCatching { mediaRecorder.maxAmplitude }.getOrDefault(0)
                _levelMeter.value = (amplitude / 32767f).coerceIn(0f, 1f)
                _elapsedSeconds.value = (System.currentTimeMillis() - startTime) / 1000.0
                delay(100)
            }
        }
    }

    actual suspend fun stop(): ByteArray? {
        meterJob?.cancel()
        meterJob = null
        _isRecording.value = false
        _levelMeter.value = 0f

        val mediaRecorder = recorder ?: return null
        return runCatching {
            mediaRecorder.stop()
            mediaRecorder.release()
            outputFile?.readBytes()
        }.getOrNull().also {
            recorder = null
            outputFile?.delete()
            outputFile = null
        }
    }
}
