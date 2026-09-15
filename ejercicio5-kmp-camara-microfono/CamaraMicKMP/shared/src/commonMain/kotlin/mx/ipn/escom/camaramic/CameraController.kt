package mx.ipn.escom.camaramic

/**
 * Wraps native photo capture. Never constructed from commonMain -- the
 * Android app builds it with a `Context`, the iOS app with no arguments --
 * so the expect declaration intentionally leaves the constructor open
 * rather than forcing a shared no-arg signature.
 *
 * [capturePhoto]'s `platformContext` is an already-bound platform capture
 * object (an androidx.camera.core.ImageCapture on Android; ignored on iOS,
 * where the controller owns its own AVCaptureSession).
 */
expect class CameraController {
    val isAvailable: Boolean
    suspend fun capturePhoto(platformContext: Any?): ByteArray?
}
