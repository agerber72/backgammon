# Backgammon

Flutter-App für Backgammon. Zielplattformen: Android, Windows, Web.
Stand: Version 1.1.0 ist im Play Store veröffentlicht, auf Deutsch und Englisch: Partie gegen den Computer in drei Stufen, Speichern, Bestenliste, Würfelstatistik und Einstellungen. Die Web-Version läuft auf GitHub Pages; es fehlt der Windows-Build. Die Regeln stehen in [docs/regeln.md](docs/regeln.md).

Die Produktvision steht in [docs/vision.md](docs/vision.md), Tasks und Anforderungen stehen in [docs/roadmap-und-anforderungen.md](docs/roadmap-und-anforderungen.md), der Aufbau der App steht in [docs/architektur.md](docs/architektur.md). Lizenz: GPL-3.0 (siehe [LICENSE](LICENSE)).

## Umgebung

- Windows 11, Flutter 3.47.7 (stable) in `C:\dev\flutter`, Dart 3.13.5
- Android-Emulator: `Medium_Phone_API_37.0`
- iOS und macOS lassen sich auf diesem Rechner nicht bauen

## Befehle

```
flutter pub get                                   # Abhängigkeiten laden
flutter analyze                                   # statische Analyse
flutter test                                      # alle Tests
flutter test test/app/backgammon_app_test.dart     # einzelne Testdatei
flutter run -d windows                            # auf Windows starten
flutter run -d chrome                             # im Browser starten
flutter build web --no-web-resources-cdn          # Web-Version ohne Google-Server bauen
./tools/android/build_bundle.ps1                  # Bundle für Google Play als build/release/<paket>_<version>-<code>.aab
./tools/windows/build_release.ps1                 # Windows-ZIP als build/release/backgammon_windows_<version>-<code>.zip, mit Starttest
flutter emulators --launch Medium_Phone_API_37.0  # Emulator starten
flutter run -d emulator-5554                      # auf dem Emulator starten
./tools/gnubg/setup.ps1                           # GNU Backgammon einrichten
./tools/blender/setup.ps1                         # Blender einrichten
./tools/blender/render.ps1                        # Assets in beiden Auflösungen neu rendern (-Tier normal|hd, -Preview: nur Vorschau)
./tools/gnubg/hint.ps1 -PositionId <id> -Die1 3 -Die2 1  # Referenzbewertung
./tools/gnubg/update_reference.ps1                # Referenzdaten für die Tests neu erzeugen
./tools/gnubg/update_engine_reference.ps1         # Zugbewertungen für die Engine neu erzeugen
dart run tools/engine/tune.dart                   # Gewichte der Bewertung abstimmen
dart run tools/engine/compare_levels.dart         # Spielstufen messen
dart run tools/legal/build_pages.dart             # Rechtstexte als Seiten in web/ erzeugen
flutter test tools/store/store_graphics_test.dart # Screenshots und Vorstellungsgrafik für Google Play in docs/store/<version>/<sprache>/
```

GNU Backgammon ist nur Testwerkzeug (siehe [tools/gnubg/README.md](tools/gnubg/README.md)). Weder Code noch Binärdateien oder Gewichtsdateien dürfen in die App gelangen.

Vor jedem Abschluss einer Änderung müssen `flutter analyze` und `flutter test` fehlerfrei durchlaufen.

## Konventionen

- Gearbeitet wird nur im Workspace oder auf GitHub. Dokumente, Pläne und Anforderungen liegen unter `docs/`, nicht in claude.ai-Dokumenten, Artifacts oder anderen externen Diensten.
- Fällt beim Abarbeiten eines Tasks eine Architekturentscheidung, muss [docs/architektur.md](docs/architektur.md) im selben Schritt aktualisiert werden: Beschreibung anpassen und Eintrag im Entscheidungslog ergänzen. So bleibt nachvollziehbar, wie die App funktioniert.
- Mit dem Benutzer auf Deutsch kommunizieren.
- Code, Bezeichner und Code-Kommentare auf Englisch.
- Tests sind für Menschen lesbar: Der Testname nennt die geprüfte Anforderung und die Erwartung im Schema `A-308: Anforderung – erwartet: Erwartung`. Testnamen sind deutsch, das ist die einzige Ausnahme von Englisch im Code.
- Sichtbare Texte kommen aus `lib/l10n/app_de.arb`, nie fest aus dem Code. Lange Rechtstexte liegen in `assets/legal/`.
- Jeder Commit ist in allen Sprachen der App vollständig übersetzt (derzeit Deutsch und Englisch). Neue oder geänderte Texte stehen im selben Commit in jeder `lib/l10n/app_<sprache>.arb`, geänderte Rechtstexte in jeder `assets/legal/<name>_<sprache>.md`, geänderte Store-Texte in jedem Sprachabschnitt von [docs/store-eintrag.md](docs/store-eintrag.md) und Store-Grafiken in jedem `docs/store/<version>/<sprache>/`. Kein Commit mit fehlenden oder veralteten Übersetzungen.
- Bei jedem Push eines neuen Releases wird die README im selben Schritt aktualisiert, auf Deutsch und Englisch. In der Tabelle „Versionen“ kommt oben eine Zeile dazu: Version mit Build, Datum, Plattformen und die Neuerungen, getrennt durch `<br>`. Aus der Tabelle „Geplant“ fällt das veröffentlichte Release heraus. „Geplant“ nennt nur Releases, die in der Roadmap vorgesehen sind, mit Datum nur, wenn es feststeht.
- Tabellen in Markdown-Dateien bekommen passende Spaltenbreiten: Kurze Spalten wie Version, Datum, Plattform, Nummer oder Name dürfen nicht umbrechen, nur die Spalte mit dem längeren Text. Dafür stehen in kurzen Zellen geschützte Leerzeichen `&nbsp;` statt Leerzeichen und geschützte Bindestriche `&#8209;` statt `-`, etwa `2026&#8209;11&#8209;11`, `1.1.0&nbsp;(8)` oder `Android,&nbsp;Web`. Die Spalte mit dem längsten Text steht ganz rechts; mehrere Punkte darin werden mit `<br>` getrennt.
- Lint-Regeln: `flutter_lints` über `analysis_options.yaml`.
- Spielregeln und Spiellogik getrennt von der UI halten, damit sie ohne Widgets testbar sind.
- Neue Pakete nur nach Rücksprache mit dem Benutzer hinzufügen.
- Commits nur, wenn der Benutzer darum bittet.
- Commit-Nachrichten enden mit `Assisted-by: Claude`. Kein `Co-Authored-By` oder andere Formulierung, die Claude als Autor nennt. Pull Requests enden mit `Entwickelt mit Unterstützung von Claude Code`.
