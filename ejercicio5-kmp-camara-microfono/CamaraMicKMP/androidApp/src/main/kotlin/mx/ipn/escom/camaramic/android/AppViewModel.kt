package mx.ipn.escom.camaramic.android

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import mx.ipn.escom.camaramic.AppThemeOption
import mx.ipn.escom.camaramic.AudioRecorderController
import mx.ipn.escom.camaramic.CameraController
import mx.ipn.escom.camaramic.MediaItem
import mx.ipn.escom.camaramic.MediaRepository
import mx.ipn.escom.camaramic.PlatformFileStore

class AppViewModel(application: Application) : AndroidViewModel(application) {
    private val fileStore = PlatformFileStore(application)
    val repository = MediaRepository(fileStore)
    val camera = CameraController(application)
    val audio = AudioRecorderController()

    private val _theme = MutableStateFlow(AppThemeOption.GUINDA)
    val theme: StateFlow<AppThemeOption> = _theme.asStateFlow()

    fun setTheme(option: AppThemeOption) {
        _theme.value = option
    }

    fun savePhoto(bytes: ByteArray, category: String): MediaItem =
        repository.savePhoto(bytes, category, System.currentTimeMillis(), newId())

    fun saveAudioRecording(bytes: ByteArray, category: String, durationSeconds: Double): MediaItem =
        repository.saveAudio(bytes, category, durationSeconds, System.currentTimeMillis(), newId())

    fun deleteItem(item: MediaItem) = viewModelScope.launch {
        repository.delete(item)
    }

    private fun newId(): String = java.util.UUID.randomUUID().toString()
}
