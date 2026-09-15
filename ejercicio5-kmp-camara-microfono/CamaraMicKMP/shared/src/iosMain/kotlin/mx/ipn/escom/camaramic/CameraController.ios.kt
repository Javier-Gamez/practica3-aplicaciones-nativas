package mx.ipn.escom.camaramic

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.coroutines.suspendCancellableCoroutine
import platform.AVFoundation.AVCaptureDevice
import platform.AVFoundation.AVCapturePhoto
import platform.AVFoundation.AVCapturePhotoCaptureDelegateProtocol
import platform.AVFoundation.AVCapturePhotoOutput
import platform.AVFoundation.AVCapturePhotoSettings
import platform.AVFoundation.AVMediaTypeVideo
import platform.AVFoundation.fileDataRepresentation
import platform.Foundation.NSError
import platform.darwin.NSObject
import kotlin.coroutines.resume

/**
 * Owns its own `AVCaptureSession`/`AVCapturePhotoOutput`; the SwiftUI layer
 * only needs the session reference (exposed via [session]) to bind a
 * preview layer, and calls [capturePhoto] to trigger a shot -- mirroring
 * the plain-Swift CameraService from Ejercicio 3, but reachable from
 * common/shared code.
 */
@OptIn(ExperimentalForeignApi::class)
actual class CameraController {
    actual val isAvailable: Boolean
        get() = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) != null

    private val photoOutput = AVCapturePhotoOutput()
    private var pendingCallback: ((ByteArray?) -> Unit)? = null

    private val delegate = object : NSObject(), AVCapturePhotoCaptureDelegateProtocol {
        override fun captureOutput(output: AVCapturePhotoOutput, didFinishProcessingPhoto: AVCapturePhoto, error: NSError?) {
            val data = didFinishProcessingPhoto.fileDataRepresentation()
            pendingCallback?.invoke(data?.toByteArray())
            pendingCallback = null
        }
    }

    /** Not part of the `expect` contract (iOS-only): lets SwiftUI bind a preview layer. */
    fun photoOutputForPreview(): AVCapturePhotoOutput = photoOutput

    actual suspend fun capturePhoto(platformContext: Any?): ByteArray? =
        suspendCancellableCoroutine { continuation ->
            pendingCallback = { bytes -> continuation.resume(bytes) }
            photoOutput.capturePhotoWithSettings(AVCapturePhotoSettings(), delegate)
        }
}
