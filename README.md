# Backgammon

Backgammon gegen den Computer: kostenlos, ohne Werbung, ohne Konto und offline. Mit drei Spielstärken, Dopplerwürfel, 3D-Brett, Bestenliste und Würfelstatistik, auf Deutsch und Englisch.

*English version below: [In English](#in-english)*

## Spielen

| Plattform | So geht's |
| --- | --- |
| **Web** | Direkt im Browser, ohne Installation: **https://agerber72.github.io/backgammon/** |
| **Windows** | ZIP unter **[Releases](https://github.com/agerber72/backgammon/releases/latest)** herunterladen, entpacken und `backgammon.exe` starten |
| **Android** | [Google Play](https://play.google.com/store/apps/details?id=de.p2g_it.backgammon) |

Die Web-Version speichert nichts im Browser. Spielstand und Bestenliste gibt es deshalb nur unter Windows und Android.

### Windows

- **Erster Start:** Die App ist nicht signiert. Beim ersten Start warnt Windows deshalb mit „Der Computer wurde durch Windows geschützt“. Ein Klick auf **Weitere Informationen** und dann auf **Trotzdem ausführen** startet die App.
- **Ohne Installation:** Die App braucht keine Installation und keinen Internetzugang. Spielstand und Einstellungen bleiben auf dem eigenen PC.
- **Entfernen:** Den entpackten Ordner `backgammon_windows_…` löschen. Wer auch Spielstand, Bestenliste und Einstellungen entfernen will, gibt im Explorer in die Adresszeile `%APPDATA%` ein und löscht dort im Ordner des Herausgebers den Unterordner `Backgammon`.

Versionen, Neuerungen und geplante Releases stehen unter **[Releases](https://github.com/agerber72/backgammon/releases)**.

## In English

Play backgammon against the computer: free, no ads, no account, offline. Three levels, doubling cube, 3D board, leaderboard and dice statistics, in English and German.

### Play

| Platform | How to |
| --- | --- |
| **Web** | Right in your browser, no installation: **https://agerber72.github.io/backgammon/** |
| **Windows** | Download the ZIP from **[Releases](https://github.com/agerber72/backgammon/releases/latest)**, unpack it and start `backgammon.exe` |
| **Android** | [Google Play](https://play.google.com/store/apps/details?id=de.p2g_it.backgammon) |

The web version stores nothing in your browser, so saved games and the leaderboard are only available on Windows and Android.

### Windows

- **First start:** The app is not signed, so Windows warns on first start with "Windows protected your PC". Click **More info**, then **Run anyway** to start the app.
- **No installation:** The app needs no installation and no internet access. Your game, settings and leaderboard stay on your PC.
- **Removing:** Delete the unpacked folder `backgammon_windows_…`. To remove your game, leaderboard and settings as well, type `%APPDATA%` into the address bar of File Explorer and delete the subfolder `Backgammon` in the publisher's folder.

Versions, changes and planned releases are listed under **[Releases](https://github.com/agerber72/backgammon/releases)**.

## Dokumentation

- [Vision](docs/vision.md): Zielgruppe, Marktbild, Leitprinzipien
- [Roadmap und Anforderungen](docs/roadmap-und-anforderungen.md): Deliveries, Versionen und Tasks
- [Architektur](docs/architektur.md): Aufbau der App und Entscheidungslog
- [Regeln](docs/regeln.md): die umgesetzten Backgammon-Regeln

## Entwicklung

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
./tools/windows/build_release.ps1   # Windows-ZIP in build/release/
./tools/android/build_bundle.ps1    # Android-Bundle in build/release/
```

GNU Backgammon dient nur während der Entwicklung als Referenz und wird nicht ausgeliefert, siehe [tools/gnubg/README.md](tools/gnubg/README.md).

## Lizenz

Copyright © 2026 Achim Gerber. Das Copyright liegt vollständig bei Achim Gerber.

Dieses Programm ist freie Software und steht unter der GNU General Public License Version 3, siehe [LICENSE](LICENSE). Es wird ohne jede Gewährleistung bereitgestellt.

Die Entwicklung wird von Claude (Anthropic) als Werkzeug unterstützt. Claude ist kein Urheber dieses Projekts. Ziele, Entscheidungen und Verantwortung liegen bei Achim Gerber.

Das Logo der Passion to Grow GmbH und die daraus erzeugten App-Symbole sind von der GPL ausgenommen. Alle Rechte daran liegen bei Achim Gerber. Abgeleitete Versionen dürfen sie nicht verwenden.

Kontakt: apps@passion-to-grow.com
