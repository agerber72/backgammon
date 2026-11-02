# Backgammon

Flutter-App für Backgammon. Zielplattformen: Android, Windows, Web.
Das Projekt steht am Anfang: `lib/main.dart` und `test/widget_test.dart` sind noch die Vorlage von `flutter create`.

Die Produktvision steht in [docs/vision.md](docs/vision.md). Lizenz: GPL-3.0 (siehe [LICENSE](LICENSE)).

## Umgebung

- Windows 11, Flutter 3.47.7 (stable) in `C:\dev\flutter`, Dart 3.13.5
- Android-Emulator: `Medium_Phone_API_37.0`
- iOS und macOS lassen sich auf diesem Rechner nicht bauen

## Befehle

```
flutter pub get                                   # Abhängigkeiten laden
flutter analyze                                   # statische Analyse
flutter test                                      # alle Tests
flutter test test/widget_test.dart                # einzelne Testdatei
flutter run -d windows                            # auf Windows starten
flutter run -d chrome                             # im Browser starten
flutter emulators --launch Medium_Phone_API_37.0  # Emulator starten
flutter run -d emulator-5554                      # auf dem Emulator starten
./tools/gnubg/setup.ps1                           # GNU Backgammon einrichten
./tools/gnubg/hint.ps1 -PositionId <id> -Die1 3 -Die2 1  # Referenzbewertung
```

GNU Backgammon ist nur Testwerkzeug (siehe [tools/gnubg/README.md](tools/gnubg/README.md)). Weder Code noch Binärdateien oder Gewichtsdateien dürfen in die App gelangen.

Vor jedem Abschluss einer Änderung müssen `flutter analyze` und `flutter test` fehlerfrei durchlaufen.

## Konventionen

- Gearbeitet wird nur im Workspace oder auf GitHub. Dokumente, Pläne und Anforderungen liegen unter `docs/`, nicht in claude.ai-Dokumenten, Artifacts oder anderen externen Diensten.
- Mit dem Benutzer auf Deutsch kommunizieren.
- Code, Bezeichner und Code-Kommentare auf Englisch.
- Lint-Regeln: `flutter_lints` über `analysis_options.yaml`.
- Spielregeln und Spiellogik getrennt von der UI halten, damit sie ohne Widgets testbar sind.
- Neue Pakete nur nach Rücksprache mit dem Benutzer hinzufügen.
- Commits nur, wenn der Benutzer darum bittet.
