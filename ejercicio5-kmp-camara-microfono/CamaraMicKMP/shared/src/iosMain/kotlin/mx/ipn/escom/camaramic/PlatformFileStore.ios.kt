package mx.ipn.escom.camaramic

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSData
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSSearchPathForDirectoriesInDomains
import platform.Foundation.NSUserDomainMask
import platform.Foundation.dataWithContentsOfFile

@OptIn(ExperimentalForeignApi::class)
actual class PlatformFileStore {
    private val mediaDir: String by lazy {
        val documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).first() as String
        val dir = "$documents/Media"
        NSFileManager.defaultManager.createDirectoryAtPath(dir, true, null, null)
        dir
    }
    private val indexPath: String get() = "$mediaDir/index.json"

    actual fun mediaDirectoryPath(): String = mediaDir

    actual fun writeBytes(fileName: String, bytes: ByteArray) {
        bytes.toNSData().writeToFile("$mediaDir/$fileName", atomically = true)
    }

    actual fun readBytes(fileName: String): ByteArray? =
        NSData.dataWithContentsOfFile("$mediaDir/$fileName")?.toByteArray()

    actual fun deleteFile(fileName: String) {
        NSFileManager.defaultManager.removeItemAtPath("$mediaDir/$fileName", null)
    }

    actual fun writeIndexJson(json: String) {
        json.encodeToByteArray().toNSData().writeToFile(indexPath, atomically = true)
    }

    actual fun readIndexJson(): String? =
        NSData.dataWithContentsOfFile(indexPath)?.toByteArray()?.decodeToString()
}
