import AVFoundation
import CoreImage
import Photos
import UIKit

struct CameraOption: Identifiable, Equatable {
    let id: String
    let displayName: String
    let shortName: String
    let device: AVCaptureDevice
}

final class CameraService: NSObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let output = AVCapturePhotoOutput()
    private var activeInput: AVCaptureDeviceInput?
    private var pendingCapture: ((Result<Void, Error>) -> Void)?
    private var pendingLook: FilmLook = .surfGlow

    private(set) var availableCameras: [CameraOption] = []
    private(set) var selectedCameraID: String?

    func configure() async {
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                self.configureSession()
                continuation.resume()
            }
        }
    }

    func start() {
        sessionQueue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func selectCamera(_ id: String) {
        sessionQueue.async {
            guard let option = self.availableCameras.first(where: { $0.id == id }) else { return }
            self.useCamera(option, commitConfiguration: true)
        }
    }

    func switchToNextCamera() {
        sessionQueue.async {
            guard !self.availableCameras.isEmpty else { return }
            let currentIndex = self.availableCameras.firstIndex { $0.id == self.selectedCameraID } ?? -1
            let next = self.availableCameras[(currentIndex + 1) % self.availableCameras.count]
            self.useCamera(next, commitConfiguration: true)
        }
    }

    func capturePhoto(look: FilmLook, completion: @escaping (Result<Void, Error>) -> Void) {
        sessionQueue.async {
            self.pendingLook = look
            self.pendingCapture = completion

            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            settings.photoQualityPrioritization = .quality
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        discoverCameras()

        if session.outputs.isEmpty, session.canAddOutput(output) {
            output.maxPhotoQualityPrioritization = .quality
            session.addOutput(output)
        }

        if let first = availableCameras.first {
            useCamera(first, commitConfiguration: false)
        }

        session.commitConfiguration()
    }

    private func discoverCameras() {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInUltraWideCamera,
                .builtInWideAngleCamera,
                .builtInTelephotoCamera,
                .builtInTrueDepthCamera
            ],
            mediaType: .video,
            position: .unspecified
        )

        var seen = Set<String>()
        availableCameras = discovery.devices.compactMap { device in
            guard seen.insert(device.uniqueID).inserted else { return nil }
            return CameraOption(
                id: device.uniqueID,
                displayName: displayName(for: device),
                shortName: shortName(for: device),
                device: device
            )
        }
    }

    private func useCamera(_ option: CameraOption, commitConfiguration: Bool) {
        do {
            let input = try AVCaptureDeviceInput(device: option.device)
            if commitConfiguration {
                session.beginConfiguration()
            }

            if let activeInput {
                session.removeInput(activeInput)
            }

            if session.canAddInput(input) {
                session.addInput(input)
                activeInput = input
                selectedCameraID = option.id
            }

            if commitConfiguration {
                session.commitConfiguration()
            }
        } catch {
            pendingCapture?(.failure(error))
        }
    }

    private func displayName(for device: AVCaptureDevice) -> String {
        let side = device.position == .front ? "Front" : "Rück"
        return "\(side) \(device.localizedName)"
    }

    private func shortName(for device: AVCaptureDevice) -> String {
        switch device.deviceType {
        case .builtInUltraWideCamera:
            return "0.5x"
        case .builtInWideAngleCamera:
            return device.position == .front ? "Front" : "1x"
        case .builtInTelephotoCamera:
            return "2x"
        case .builtInTripleCamera:
            return "Triple"
        case .builtInDualWideCamera:
            return "DualW"
        case .builtInDualCamera:
            return "Dual"
        case .builtInTrueDepthCamera:
            return "Self"
        default:
            return "Cam"
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            pendingCapture?(.failure(error))
            pendingCapture = nil
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let processed = FilmProcessor.render(image, look: pendingLook) else {
            pendingCapture?(.failure(CameraError.processingFailed))
            pendingCapture = nil
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                self.pendingCapture?(.failure(CameraError.photoLibraryDenied))
                self.pendingCapture = nil
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: processed)
            } completionHandler: { success, error in
                if let error {
                    self.pendingCapture?(.failure(error))
                } else if success {
                    self.pendingCapture?(.success(()))
                } else {
                    self.pendingCapture?(.failure(CameraError.saveFailed))
                }
                self.pendingCapture = nil
            }
        }
    }
}

enum CameraError: LocalizedError {
    case processingFailed
    case photoLibraryDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .processingFailed:
            return "Der Filmlook konnte nicht angewendet werden."
        case .photoLibraryDenied:
            return "Kein Zugriff zum Speichern in Fotos."
        case .saveFailed:
            return "Das Foto konnte nicht gespeichert werden."
        }
    }
}
