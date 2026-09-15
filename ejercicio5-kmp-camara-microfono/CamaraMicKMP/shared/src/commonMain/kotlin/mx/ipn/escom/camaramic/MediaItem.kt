package mx.ipn.escom.camaramic

import kotlinx.serialization.Serializable

@Serializable
enum class MediaKind { PHOTO, AUDIO }

@Serializable
data class MediaItem(
    val id: String,
    val kind: MediaKind,
    val fileName: String,
    val category: String,
    val createdAtEpochMillis: Long,
    val durationSeconds: Double = 0.0,
)
