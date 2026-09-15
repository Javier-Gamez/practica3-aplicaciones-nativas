package mx.ipn.escom.camaramic

import android.content.Context
import android.content.pm.PackageManager
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.concurrent.Executor
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * The `Context` is only used to check `FEATURE_CAMERA_ANY`. The actual
 * capture happens through the `ImageCapture` use case that the Compose UI
 * (MainActivity) already bound to the visible preview -- passed in as
 * [capturePhoto]'s `platformContext` -- so there is only ever one active
 * CameraX session.
 */
actual class CameraController(context: Context) {
    actual val isAvailable: Boolean =
        context.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)

    actual suspend fun capturePhoto(platformContext: Any?): ByteArray? {
        val imageCapture = platformContext as? ImageCapture ?: return null
        return suspendCancellableCoroutine { continuation ->
            imageCapture.takePicture(
                Executor { it.run() },
                object : ImageCapture.OnImageCapturedCallback() {
                    override fun onCaptureSuccess(image: ImageProxy) {
                        val bytes = image.toJpegByteArray()
                        image.close()
                        continuation.resume(bytes)
                    }

                    override fun onError(exception: ImageCaptureException) {
                        continuation.resumeWithException(exception)
                    }
                },
            )
        }
    }
}

private fun ImageProxy.toJpegByteArray(): ByteArray {
    val buffer = planes[0].buffer
    val bytes = ByteArray(buffer.remaining())
    buffer.get(bytes)
    return bytes
}
