import AVFoundation
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showLookDrawer = false

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.045, blue: 0.04).ignoresSafeArea()

            if viewModel.authorization == .authorized {
                cameraBody
            } else {
                permissionView
            }
        }
        .task {
            await viewModel.prepare()
        }
    }

    private var cameraBody: some View {
        VStack(spacing: 0) {
            topPlate

            ZStack(alignment: .topTrailing) {
                liveLookPreview
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(filmOverlay)
                    .overlay(viewfinderFrame)
                    .padding(.horizontal, 12)

                exposureBadge
                    .padding(.top, 16)
                    .padding(.trailing, 26)
            }

            controls
        }
        .background(cameraLeather)
        .sheet(isPresented: $showLookDrawer) {
            lookPicker
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
        }
        .overlay(alignment: .top) {
            if let message = viewModel.toast {
                Text(message)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 54)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var liveLookPreview: some View {
        ZStack {
            Color.black

            if let previewImage = viewModel.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 28, weight: .bold))
                    Text("Sucher startet")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
                .foregroundStyle(Color(red: 0.93, green: 0.88, blue: 0.76).opacity(0.72))
            }
        }
        .aspectRatio(3 / 4, contentMode: .fit)
        .clipped()
    }

    private var topPlate: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.78, green: 0.02, blue: 0.02))
                    .frame(width: 42, height: 42)
                    .shadow(color: .black.opacity(0.45), radius: 6, y: 3)
                Text("M")
                    .font(.system(size: 19, weight: .black, design: .serif))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("RETRO M")
                    .font(.system(size: 18, weight: .black, design: .serif))
                Text(viewModel.currentLook.name.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.switchCamera()
            } label: {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.16), in: Circle())
            }
            .accessibilityLabel("Kamera wechseln")

            Button {
                showLookDrawer = true
            } label: {
                Image(systemName: "film")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.16), in: Circle())
            }
            .accessibilityLabel("Filmlook wählen")
        }
        .foregroundStyle(Color(red: 0.92, green: 0.88, blue: 0.78))
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.52, blue: 0.45),
                    Color(red: 0.16, green: 0.15, blue: 0.13)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var controls: some View {
        VStack(spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableCameras) { camera in
                        Button {
                            viewModel.selectCamera(camera.id)
                        } label: {
                            Text(camera.shortName)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(viewModel.selectedCameraID == camera.id ? .black : .white)
                                .frame(minWidth: camera.shortName == "Front" ? 74 : 52)
                                .padding(.vertical, 9)
                                .background(viewModel.selectedCameraID == camera.id ? Color(red: 0.94, green: 0.86, blue: 0.62) : Color.white.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 18)
            }

            HStack(alignment: .center) {
                Button {
                    viewModel.cycleLook(reverse: true)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .bold))
                        .frame(width: 54, height: 54)
                        .background(Color.white.opacity(0.08), in: Circle())
                }
                .accessibilityLabel("Vorheriger Look")

                Spacer()

                Button {
                    viewModel.capturePhoto()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0.93, green: 0.88, blue: 0.76), lineWidth: 5)
                            .frame(width: 82, height: 82)
                        Circle()
                            .fill(viewModel.isCapturing ? Color(red: 0.8, green: 0.02, blue: 0.02) : Color(red: 0.16, green: 0.15, blue: 0.13))
                            .frame(width: 66, height: 66)
                    }
                }
                .accessibilityLabel("Foto aufnehmen")

                Spacer()

                Button {
                    viewModel.cycleLook(reverse: false)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 19, weight: .bold))
                        .frame(width: 54, height: 54)
                        .background(Color.white.opacity(0.08), in: Circle())
                }
                .accessibilityLabel("Nächster Look")
            }
            .foregroundStyle(Color(red: 0.93, green: 0.88, blue: 0.76))
            .padding(.horizontal, 28)

            Text(viewModel.currentCameraName)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(red: 0.72, green: 0.68, blue: 0.58))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.bottom, 10)
        }
        .padding(.top, 12)
        .background(Color(red: 0.07, green: 0.065, blue: 0.055))
    }

    private var permissionView: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(Color(red: 0.78, green: 0.02, blue: 0.02)).frame(width: 68, height: 68)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Kamerazugriff benötigt")
                .font(.system(size: 24, weight: .black, design: .serif))
                .foregroundStyle(Color(red: 0.92, green: 0.88, blue: 0.78))

            Text("Retro M braucht Zugriff auf die iPhone-Kameras, um Livebilder aufzunehmen und die Filmlooks zu speichern.")
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)

            Button("Zugriff erlauben") {
                Task { await viewModel.prepare() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.78, green: 0.02, blue: 0.02))
        }
    }

    private var lookPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Filmlooks")
                .font(.system(size: 22, weight: .black, design: .serif))
                .padding(.horizontal, 18)
                .padding(.top, 18)

            ForEach(FilmLook.allCases) { look in
                Button {
                    viewModel.selectLook(look)
                    showLookDrawer = false
                } label: {
                    HStack {
                        Circle()
                            .fill(look.swatch)
                            .frame(width: 28, height: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(look.name)
                                .font(.system(size: 15, weight: .bold))
                            Text(look.description)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if look == viewModel.currentLook {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 0.78, green: 0.02, blue: 0.02))
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 4)
                }
            }
            Spacer()
        }
    }

    private var cameraLeather: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.075, blue: 0.065),
                Color(red: 0.02, green: 0.02, blue: 0.018)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var filmOverlay: some View {
        ZStack {
            LinearGradient(
                colors: [.white.opacity(0.12), .clear, .black.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Rectangle()
                .fill(.black.opacity(0.05))
                .blendMode(.multiply)
        }
        .allowsHitTesting(false)
    }

    private var viewfinderFrame: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .strokeBorder(Color(red: 0.9, green: 0.86, blue: 0.74).opacity(0.48), lineWidth: 1)
            .overlay(alignment: .center) {
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    .frame(width: 74, height: 74)
            }
            .allowsHitTesting(false)
    }

    private var exposureBadge: some View {
        Text("A  1/125  ISO AUTO")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(Color(red: 0.95, green: 0.86, blue: 0.58))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.48), in: Capsule())
    }
}
