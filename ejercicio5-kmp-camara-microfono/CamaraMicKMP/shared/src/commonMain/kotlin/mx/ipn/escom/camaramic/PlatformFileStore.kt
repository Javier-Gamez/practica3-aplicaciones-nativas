package mx.ipn.escom.camaramic

/**
 * Raw filesystem access, implemented per platform (java.io.File on Android,
 * NSFileManager on iOS). Everything above this layer (MediaRepository) is
 * pure common Kotlin.
 */
expect class PlatformFileStore {
    fun mediaDirectoryPath(): String
    fun writeBytes(fileName: String, bytes: ByteArray)
    fun readBytes(fileName: String): ByteArray?
    fun deleteFile(fileName: String)
    fun writeIndexJson(json: String)
    fun readIndexJson(): String?
}
