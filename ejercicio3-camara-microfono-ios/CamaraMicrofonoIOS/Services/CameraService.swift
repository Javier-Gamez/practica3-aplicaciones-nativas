import AVFoundation
import CoreImage
import UIKit

enum CameraFilter: String, CaseIterable, Identifiable {
    case none, mono, sepia
    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "Ninguno"
        case .mono: return "Blanco y negro"
        case .sepia: return "Sepia"
        }
    }

    var ciFilterName: String? {
        switch self {
        case .none: return nil
        case .mono: return "CIPhotoEffectMono"
        case .sepia: return "CISepiaTone"
        }
    }
}

/// Wraps AVCaptureSession for photo capture. The iOS Simulator has no
/// physical camera, so `isCameraAvailable` reports that and the UI falls
/// back to PHPickerViewController (see `PhotoLibraryPickerView`).
final class CameraService: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var flashOn = false
    @Published var filter: CameraFilter = .none
    @Published var timerSeconds: Int = 0 // 0, 3 or 10

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?

    static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func configure() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async { self?.isSessionRunning = true }
        }
    }

    func stop() {
        guard session.isRunning else { return }
        session.stopRunning()
        isSessionRunning = false
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let delay = Double(timerSeconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            let settings = AVCapturePhotoSettings()
            settings.flashMode = self.flashOn ? .on : .off
            self.captureCompletion = completion
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func applyFilter(to image: UIImage) -> UIImage {
        guard let filterName = filter.ciFilterName,
              let ciImage = CIImage(image: image),
              let ciFilter = CIFilter(name: filterName) else { return image }
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let output = ciFilter.outputImage,
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        captureCompletion?(applyFilter(to: image))
    }
}
