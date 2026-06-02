# Retro M

Retro M ist eine SwiftUI-Kamera-App im Stil einer klassischen Messsucherkamera. Sie nutzt AVFoundation für die Live-Vorschau, listet die verfügbaren iPhone-Kameras auf und speichert Fotos mit Core-Image-Filmlooks in der Fotomediathek.

## Looks

- Surf Glow: warme Strandfarben, weiche Highlights, leichter Pastellfilm.
- Tokyo Chrome: heller Street-Look mit reduziertem Vintage-Kontrast.
- U-Bahn Neon: kühle Schatten, roter Glow, stärkerer Kontrast.
- Pacific Gold: 70er-Küstenlook mit warmen Mitten und matterem Schwarz.

## Öffnen

1. `RetroM.xcodeproj` in Xcode öffnen.
2. Unter `Signing & Capabilities` ein eigenes Team waehlen.
3. Auf einem echten iPhone starten. Im Simulator steht keine echte Kamera zur Verfuegung.

Die App enthält die benötigten Einträge für Kamera- und Foto-Berechtigungen in `Info.plist`.
