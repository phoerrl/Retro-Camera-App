import AVFoundation
import Foundation
import SwiftUI
import UIKit

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var authorization: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published var availableCameras: [CameraOption] = []
    @Published var selectedCameraID: String?
    @Published var currentLook: FilmLook = .surfGlow
    @Published var previewImage: UIImage?
    @Published var isCapturing = false
    @Published var toast: String?

    let session: AVCaptureSession
    private let service: CameraService

    init() {
        let cameraService = CameraService()
        service = cameraService
        session = cameraService.session
        cameraService.onPreviewFrame = { [weak self] image in
            Task { @MainActor in
                self?.previewImage = image
            }
        }
    }

    var currentCameraName: String {
        availableCameras.first(where: { $0.id == selectedCameraID })?.displayName ?? "Kamera wird gesucht"
    }

    func prepare() async {
        authorization = AVCaptureDevice.authorizationStatus(for: .video)

        if authorization == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            authorization = granted ? .authorized : .denied
        }

        guard authorization == .authorized else { return }

        await service.configure()
        availableCameras = service.availableCameras
        selectedCameraID = service.selectedCameraID
        service.start()
    }

    func selectCamera(_ id: String) {
        service.selectCamera(id)
        selectedCameraID = id
    }

    func switchCamera() {
        guard !availableCameras.isEmpty else { return }
        let currentIndex = availableCameras.firstIndex { $0.id == selectedCameraID } ?? -1
        let next = availableCameras[(currentIndex + 1) % availableCameras.count]
        selectCamera(next.id)
    }

    func selectLook(_ look: FilmLook) {
        currentLook = look
        service.setPreviewLook(look)
    }

    func cycleLook(reverse: Bool) {
        let looks = FilmLook.allCases
        guard let index = looks.firstIndex(of: currentLook) else {
            currentLook = .surfGlow
            return
        }
        let nextIndex = reverse ? (index - 1 + looks.count) % looks.count : (index + 1) % looks.count
        selectLook(looks[nextIndex])
    }

    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true

        service.capturePhoto(look: currentLook) { [weak self] result in
            Task { @MainActor in
                self?.isCapturing = false
                switch result {
                case .success:
                    self?.showToast("Foto gespeichert")
                case .failure(let error):
                    self?.showToast(error.localizedDescription)
                }
            }
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation { self.toast = nil }
            }
        }
    }
}
