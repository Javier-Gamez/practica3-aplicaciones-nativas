package mx.ipn.escom.camaramic

import android.content.Context
import java.io.File

actual class PlatformFileStore(private val context: Context) {
    private val mediaDir: File by lazy {
        File(context.filesDir, "Media").apply { mkdirs() }
    }
    private val indexFile: File by lazy { File(mediaDir, "index.json") }

    actual fun mediaDirectoryPath(): String = mediaDir.absolutePath

    actual fun writeBytes(fileName: String, bytes: ByteArray) {
        File(mediaDir, fileName).writeBytes(bytes)
    }

    actual fun readBytes(fileName: String): ByteArray? {
        val file = File(mediaDir, fileName)
        return if (file.exists()) file.readBytes() else null
    }

    actual fun deleteFile(fileName: String) {
        File(mediaDir, fileName).delete()
    }

    actual fun writeIndexJson(json: String) {
        indexFile.writeText(json)
    }

    actual fun readIndexJson(): String? = if (indexFile.exists()) indexFile.readText() else null
}
