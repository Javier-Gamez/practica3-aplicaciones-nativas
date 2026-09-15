package mx.ipn.escom.camaramic

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/**
 * Pure Kotlin business logic shared between Android and iOS: keeps the
 * in-memory list of captured items in sync with a JSON index file and the
 * raw media files on disk, both accessed through [PlatformFileStore].
 */
class MediaRepository(private val store: PlatformFileStore) {
    private val json = Json { prettyPrint = false; ignoreUnknownKeys = true }

    private val _items = MutableStateFlow<List<MediaItem>>(emptyList())
    val items: StateFlow<List<MediaItem>> = _items.asStateFlow()

    init {
        reload()
    }

    fun reload() {
        val raw = store.readIndexJson()
        _items.value = if (raw.isNullOrBlank()) {
            emptyList()
        } else {
            runCatching { json.decodeFromString<List<MediaItem>>(raw) }.getOrDefault(emptyList())
        }
    }

    val categories: List<String>
        get() = _items.value.map { it.category }.distinct().sorted()

    fun savePhoto(bytes: ByteArray, category: String, nowEpochMillis: Long, newId: String): MediaItem {
        val fileName = "IMG-$nowEpochMillis.jpg"
        store.writeBytes(fileName, bytes)
        return insert(
            MediaItem(
                id = newId,
                kind = MediaKind.PHOTO,
                fileName = fileName,
                category = category,
                createdAtEpochMillis = nowEpochMillis,
            )
        )
    }

    fun saveAudio(bytes: ByteArray, category: String, durationSeconds: Double, nowEpochMillis: Long, newId: String): MediaItem {
        val fileName = "REC-$nowEpochMillis.m4a"
        store.writeBytes(fileName, bytes)
        return insert(
            MediaItem(
                id = newId,
                kind = MediaKind.AUDIO,
                fileName = fileName,
                category = category,
                createdAtEpochMillis = nowEpochMillis,
                durationSeconds = durationSeconds,
            )
        )
    }

    fun delete(item: MediaItem) {
        store.deleteFile(item.fileName)
        _items.value = _items.value.filterNot { it.id == item.id }
        persist()
    }

    fun bytesFor(item: MediaItem): ByteArray? = store.readBytes(item.fileName)

    private fun insert(item: MediaItem): MediaItem {
        _items.value = _items.value + item
        persist()
        return item
    }

    private fun persist() {
        store.writeIndexJson(json.encodeToString(_items.value))
    }
}
