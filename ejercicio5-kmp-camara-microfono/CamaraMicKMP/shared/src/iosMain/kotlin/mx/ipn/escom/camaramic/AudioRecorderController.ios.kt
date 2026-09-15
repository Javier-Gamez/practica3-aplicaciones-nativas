package mx.ipn.escom.camaramic

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import platform.AVFAudio.AVAudioQualityHigh
import platform.AVFAudio.AVAudioRecorder
import platform.AVFAudio.AVAudioSession
import platform.AVFAudio.AVEncoderAudioQualityKey
import platform.AVFAudio.AVFormatIDKey
import platform.AVFAudio.AVNumberOfChannelsKey
import platform.AVFAudio.AVSampleRateKey
import platform.Foundation.NSDate
import platform.Foundation.NSURL
import platform.Foundation.timeIntervalSinceDate
import platform.CoreAudioTypes.kAudioFormatMPEG4AAC
import platform.Foundation.NSTemporaryDirectory
import platform.Foundation.NSUUID

@OptIn(ExperimentalForeignApi::class)
actual class AudioRecorderController {
    private var recorder: AVAudioRecorder? = null
    private var fileURL: NSURL? = null
    private var startedAt: NSDate? = null
    private var meterJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Default)

    private val _isRecording = MutableStateFlow(false)
    actual val isRecording: StateFlow<Boolean> = _isRecording.asStateFlow()

    private val _levelMeter = MutableStateFlow(0f)
    actual val levelMeter: StateFlow<Float> = _levelMeter.asStateFlow()

    private val _elapsedSeconds = MutableStateFlow(0.0)
    actual val elapsedSeconds: StateFlow<Double> = _elapsedSeconds.asStateFlow()

    actual suspend fun start(platformContext: Any?) {
        val session = AVAudioSession.sharedInstance()
        session.setCategory("AVAudioSessionCategoryPlayAndRecord", error = null)
        session.setActive(true, error = null)

        val path = NSTemporaryDirectory() + NSUUID().UUIDString() + ".m4a"
        val url = NSURL.fileURLWithPath(path)
        fileURL = url

        val settings = mapOf<Any?, Any?>(
            AVFormatIDKey to kAudioFormatMPEG4AAC,
            AVSampleRateKey to 44100.0,
            AVNumberOfChannelsKey to 1,
            AVEncoderAudioQualityKey to AVAudioQualityHigh,
        )

        val newRecorder = AVAudioRecorder(uRL = url, settings = settings, error = null)
        newRecorder.meteringEnabled = true
        newRecorder.record()
        recorder = newRecorder
        startedAt = NSDate()
        _isRecording.value = true
        _elapsedSeconds.value = 0.0

        meterJob = scope.launch {
            while (_isRecording.value) {
                newRecorder.updateMeters()
                val power = newRecorder.averagePowerForChannel(0u)
                _levelMeter.value = ((power + 60f) / 60f).coerceIn(0f, 1f)
                startedAt?.let { start -> _elapsedSeconds.value = NSDate().timeIntervalSinceDate(start) }
                delay(100)
            }
        }
    }

    actual suspend fun stop(): ByteArray? {
        meterJob?.cancel()
        meterJob = null
        _isRecording.value = false
        _levelMeter.value = 0f

        recorder?.stop()
        recorder = null

        val url = fileURL ?: return null
        val data = platform.Foundation.NSData.dataWithContentsOfURL(url)
        fileURL = null
        return data?.toByteArray()
    }
}
