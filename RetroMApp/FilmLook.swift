import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

enum FilmLook: String, CaseIterable, Identifiable {
    case surfGlow
    case tokyoChrome
    case ubahnNeon
    case pacificGold

    var id: String { rawValue }

    var name: String {
        switch self {
        case .surfGlow:
            return "Surf Glow"
        case .tokyoChrome:
            return "Tokyo Chrome"
        case .ubahnNeon:
            return "U-Bahn Neon"
        case .pacificGold:
            return "Pacific Gold"
        }
    }

    var description: String {
        switch self {
        case .surfGlow:
            return "Pastellige Sonne, weiche Highlights, Strandfilm."
        case .tokyoChrome:
            return "Klarer Street-Look mit leichtem Vintage-Kontrast."
        case .ubahnNeon:
            return "Kühle Schatten, rote Halation, urbaner Nachtfilm."
        case .pacificGold:
            return "Warme Kueste, matte Schwarztöne, 70er-Farben."
        }
    }

    var swatch: Color {
        switch self {
        case .surfGlow:
            return Color(red: 0.97, green: 0.72, blue: 0.46)
        case .tokyoChrome:
            return Color(red: 0.72, green: 0.77, blue: 0.66)
        case .ubahnNeon:
            return Color(red: 0.78, green: 0.08, blue: 0.05)
        case .pacificGold:
            return Color(red: 0.73, green: 0.63, blue: 0.39)
        }
    }
}

enum FilmProcessor {
    private static let context = CIContext(options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any])

    static func render(_ image: UIImage, look: FilmLook) -> UIImage? {
        guard let input = CIImage(image: image) else { return nil }

        let oriented = input.oriented(forExifOrientation: Int32(image.imageOrientation.exifOrientation))
        let output = applyFilmRecipe(to: oriented, look: look, includeGrain: true)

        guard let cgImage = context.createCGImage(output, from: oriented.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    }

    static func renderPreview(_ image: CIImage, look: FilmLook) -> UIImage? {
        let output = applyFilmRecipe(to: image, look: look, includeGrain: true)
        guard let cgImage = context.createCGImage(output, from: image.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private static func applyFilmRecipe(to image: CIImage, look: FilmLook, includeGrain: Bool) -> CIImage {
        var output = applyBaseGrade(to: image, look: look)
        output = applyTemperature(to: output, look: look)
        output = applyBloom(to: output, look: look)
        output = applyVignette(to: output, extent: image.extent, look: look)
        if includeGrain {
            output = applyGrain(to: output, extent: image.extent, look: look)
        }
        return output.cropped(to: image.extent)
    }

    private static func applyBaseGrade(to image: CIImage, look: FilmLook) -> CIImage {
        let controls = CIFilter.colorControls()
        controls.inputImage = image

        switch look {
        case .surfGlow:
            controls.saturation = 0.92
            controls.contrast = 0.88
            controls.brightness = 0.06
        case .tokyoChrome:
            controls.saturation = 0.82
            controls.contrast = 1.05
            controls.brightness = 0.02
        case .ubahnNeon:
            controls.saturation = 1.12
            controls.contrast = 1.18
            controls.brightness = -0.03
        case .pacificGold:
            controls.saturation = 0.98
            controls.contrast = 0.9
            controls.brightness = 0.04
        }

        let faded = CIFilter.highlightShadowAdjust()
        faded.inputImage = controls.outputImage
        faded.shadowAmount = look == .ubahnNeon ? -0.15 : 0.35
        faded.highlightAmount = look == .surfGlow ? 0.72 : 0.9
        return faded.outputImage ?? image
    }

    private static func applyTemperature(to image: CIImage, look: FilmLook) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image

        switch look {
        case .surfGlow:
            filter.neutral = CIVector(x: 6100, y: 20)
            filter.targetNeutral = CIVector(x: 7200, y: 55)
        case .tokyoChrome:
            filter.neutral = CIVector(x: 6500, y: 0)
            filter.targetNeutral = CIVector(x: 6000, y: 18)
        case .ubahnNeon:
            filter.neutral = CIVector(x: 6500, y: 0)
            filter.targetNeutral = CIVector(x: 4700, y: -40)
        case .pacificGold:
            filter.neutral = CIVector(x: 6200, y: 8)
            filter.targetNeutral = CIVector(x: 7600, y: 28)
        }

        return filter.outputImage ?? image
    }

    private static func applyBloom(to image: CIImage, look: FilmLook) -> CIImage {
        let bloom = CIFilter.bloom()
        bloom.inputImage = image
        bloom.radius = look == .ubahnNeon ? 9 : 15
        bloom.intensity = look == .tokyoChrome ? 0.14 : 0.28
        guard let glow = bloom.outputImage else { return image }

        let blend = CIFilter.screenBlendMode()
        blend.inputImage = glow
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    private static func applyVignette(to image: CIImage, extent: CGRect, look: FilmLook) -> CIImage {
        let vignette = CIFilter.vignetteEffect()
        vignette.inputImage = image
        vignette.center = CGPoint(x: extent.midX, y: extent.midY)
        vignette.radius = Float(max(extent.width, extent.height) * 0.72)
        vignette.intensity = look == .ubahnNeon ? 0.72 : 0.42
        return vignette.outputImage ?? image
    }

    private static func applyGrain(to image: CIImage, extent: CGRect, look: FilmLook) -> CIImage {
        let random = CIFilter.randomGenerator().outputImage?.cropped(to: extent)
        let monochrome = CIFilter.colorMonochrome()
        monochrome.inputImage = random
        monochrome.color = CIColor(red: 0.72, green: 0.68, blue: 0.58)
        monochrome.intensity = look == .ubahnNeon ? 0.12 : 0.08

        let opacity = CIFilter.colorMatrix()
        opacity.inputImage = monochrome.outputImage
        opacity.aVector = CIVector(x: 0, y: 0, z: 0, w: look == .tokyoChrome ? 0.08 : 0.12)

        let overlay = CIFilter.overlayBlendMode()
        overlay.inputImage = opacity.outputImage
        overlay.backgroundImage = image
        return overlay.outputImage ?? image
    }
}

private extension UIImage.Orientation {
    var exifOrientation: Int {
        switch self {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}
