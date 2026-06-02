# Retro M über GitHub auf dein iPhone bringen

Diese Anleitung führt dich Schritt für Schritt durch den Weg:

1. Projekt auf GitHub hochladen
2. Projekt auf deinen Mac holen
3. In Xcode öffnen
4. Auf dem iPhone starten

Du brauchst dafür:

- einen Mac
- ein iPhone
- ein kostenloses Apple-Konto
- einen kostenlosen GitHub-Account
- Xcode aus dem Mac App Store

## 1. Xcode installieren

1. Öffne auf deinem Mac den **App Store**.
2. Suche nach **Xcode**.
3. Installiere Xcode.
4. Öffne Xcode einmal nach der Installation.
5. Akzeptiere die Lizenzbedingungen, falls Xcode danach fragt.

Xcode ist das Apple-Programm, mit dem iPhone-Apps gebaut und auf dein iPhone übertragen werden.

## 2. GitHub-Account erstellen

1. Öffne [github.com](https://github.com).
2. Erstelle einen Account oder melde dich an.

GitHub ist nur der Online-Speicher für dein App-Projekt.

## 3. Neues GitHub-Repository erstellen

1. Klicke auf GitHub oben rechts auf das **+**.
2. Wähle **New repository**.
3. Gib als Namen zum Beispiel ein:

   `RetroM`

4. Wähle **Private**, wenn nur du das Projekt sehen sollst.
5. Lasse die Optionen für README, `.gitignore` und License leer.
6. Klicke auf **Create repository**.

## 4. Projekt auf GitHub hochladen

Am einfachsten geht das ohne Terminal direkt im Browser:

1. Öffne dein neues GitHub-Repository.
2. Klicke auf **uploading an existing file**.
3. Öffne auf deinem Mac den Ordner:

   `/Users/paddy/Documents/Codex/2026-06-02/files-mentioned-by-the-user-image/outputs/RetroM`

4. Ziehe den Inhalt dieses Ordners in das GitHub-Fenster.

Wichtig: Lade den Inhalt des Ordners `RetroM` hoch, also unter anderem:

- `RetroM.xcodeproj`
- `RetroMApp`
- `README.md`

5. Unten bei **Commit changes** kannst du schreiben:

   `Initial Retro M app`

6. Klicke auf **Commit changes**.

Jetzt liegt dein App-Projekt auf GitHub.

## 5. Projekt auf deinen Mac holen

Der einfache Weg ist GitHub Desktop.

1. Lade **GitHub Desktop** herunter:

   [desktop.github.com](https://desktop.github.com)

2. Installiere und öffne GitHub Desktop.
3. Melde dich mit deinem GitHub-Account an.
4. Klicke auf **File > Clone Repository**.
5. Wähle dein Repository `RetroM`.
6. Wähle einen Speicherort auf deinem Mac, zum Beispiel `Documents`.
7. Klicke auf **Clone**.

Das bedeutet: GitHub Desktop lädt dein Projekt von GitHub auf deinen Mac.

## 6. Projekt in Xcode öffnen

1. Öffne den geklonten Ordner auf deinem Mac.
2. Doppelklicke auf:

   `RetroM.xcodeproj`

3. Xcode öffnet nun das Projekt.

## 7. Apple-Konto in Xcode hinzufügen

1. Öffne in Xcode oben links **Xcode > Settings**.
2. Gehe zu **Accounts**.
3. Klicke links unten auf **+**.
4. Wähle **Apple ID**.
5. Melde dich mit deiner Apple-ID an.

## 8. Signing einstellen

Damit die App auf dein iPhone darf, muss Xcode sie signieren.

1. Klicke links in Xcode auf das blaue Projekt-Symbol **RetroM**.
2. Wähle unter **Targets** den Eintrag **RetroM**.
3. Öffne den Tab **Signing & Capabilities**.
4. Aktiviere **Automatically manage signing**.
5. Wähle bei **Team** deine Apple-ID aus.

Falls Xcode meckert, dass die Bundle ID schon vergeben ist:

1. Suche im Feld **Bundle Identifier** nach:

   `com.example.retrom`

2. Ändere es zum Beispiel in:

   `com.deinname.retrom`

Nimm einen Namen, der möglichst eindeutig ist.

## 9. iPhone vorbereiten

1. Verbinde dein iPhone per Kabel mit dem Mac.
2. Entsperre dein iPhone.
3. Wenn gefragt wird, tippe auf **Diesem Computer vertrauen**.
4. Warte kurz, bis Xcode dein iPhone erkennt.

Oben in Xcode gibt es eine Geräteauswahl. Dort sollte dein iPhone erscheinen.

## 10. App auf das iPhone bringen

1. Wähle oben in Xcode dein iPhone als Zielgerät aus.
2. Klicke oben links auf den **Play-Button**.
3. Xcode baut die App und installiert sie auf dein iPhone.

Beim ersten Mal kann das einige Minuten dauern.

## 11. Falls das iPhone die App nicht öffnet

Bei kostenlosen Apple-Konten kann iOS beim ersten Start nach Vertrauen fragen.

Auf dem iPhone:

1. Öffne **Einstellungen**.
2. Gehe zu **Allgemein**.
3. Öffne **VPN & Geräteverwaltung** oder **Geräteverwaltung**.
4. Wähle dein Apple-ID-Entwicklerprofil.
5. Tippe auf **Vertrauen**.

Danach kannst du die App öffnen.

## 12. Kamera- und Fotozugriff erlauben

Beim ersten Start fragt die App nach Berechtigungen:

1. Kamera erlauben
2. Speichern in Fotos erlauben

Beides erlauben, sonst kann die App keine Fotos aufnehmen und speichern.

## Häufige Probleme

### Mein iPhone erscheint nicht in Xcode

- iPhone entsperren
- Kabel neu einstecken
- auf dem iPhone **Diesem Computer vertrauen** bestätigen
- Xcode neu starten

### Xcode sagt: Bundle Identifier already in use

Ändere `com.example.retrom` in etwas Persönliches, zum Beispiel:

`com.paddy.retrom`

### Xcode sagt: No signing certificate

Prüfe:

- Apple-ID ist in Xcode angemeldet
- Team ist unter **Signing & Capabilities** ausgewählt
- **Automatically manage signing** ist aktiviert

### Die Kamera funktioniert im Simulator nicht

Das ist normal. Für diese App brauchst du ein echtes iPhone.

## Kurzfassung

1. Xcode installieren
2. GitHub-Repo erstellen
3. Projektdateien hochladen
4. Mit GitHub Desktop klonen
5. `RetroM.xcodeproj` öffnen
6. Apple-ID in Xcode hinzufügen
7. Signing aktivieren
8. iPhone verbinden
9. Play drücken
