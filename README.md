# Retro M

Retro M ist eine SwiftUI-Kamera-App im Stil einer klassischen Messsucherkamera. Sie nutzt AVFoundation für die Kamera, zeigt den aktuell ausgewählten Filmlook live im Sucher, listet die verfügbaren iPhone-Kameras auf und speichert Fotos mit Core-Image-Filmlooks in der Fotomediathek.

## Looks

- Surf Glow: warme Strandfarben, weiche Highlights, leichter Pastellfilm.
- Tokyo Chrome: heller Street-Look mit reduziertem Vintage-Kontrast.
- U-Bahn Neon: kühle Schatten, roter Glow, stärkerer Kontrast.
- Pacific Gold: 70er-Küstenlook mit warmen Mitten und matterem Schwarz.

## Live-Vorschau

Der Sucher zeigt nicht mehr das rohe Kamerabild. Die App verarbeitet Live-Frames der Kamera mit dem aktuell ausgewählten Look und aktualisiert die Vorschau direkt beim Wechsel des Looks. Für eine flüssigere Vorschau nutzt die App einen schnellen Preview-Renderer mit kleinerer Rendergröße und 30-fps-Ziel; gespeicherte Fotos werden weiterhin mit dem volleren Filmrezept ausgegeben.

## Kameras

Die Auswahl ist bewusst auf die praktischen Modi beschränkt:

- 0,5
- 1
- 2
- Front

## Öffnen

1. `RetroM.xcodeproj` in Xcode öffnen.
2. Unter `Signing & Capabilities` ein eigenes Team wählen.
3. Auf einem echten iPhone starten. Im Simulator steht keine echte Kamera zur Verfügung.

Die App enthält die benötigten Einträge für Kamera- und Foto-Berechtigungen in `Info.plist`.
