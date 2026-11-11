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

## Versionen

| Version | Datum | Plattformen | Neu |
| --- | --- | --- | --- |
| **1.1.0**&nbsp;(8) | 2026&#8209;11&#8209;11 | Android,&nbsp;Windows,&nbsp;Web | Die App gibt es jetzt auch auf Englisch<br>Erste Windows-Version, als ZIP über GitHub Releases<br>Persönliche Bestenliste mit Gesamtpunkten je Spielstärke und den letzten Partien<br>„Zu Ende spielen“ würfelt schneller aus und rettet Gammon und Backgammon, wo es geht<br>Einstellbares Spieltempo mit Countdown-Ring<br>App-Symbol mit kleinerem Logo<br>Pfeile zum Blättern in langen Texten |
| **1.0.0**&nbsp;(6) | 2026&#8209;11&#8209;07 | Android,&nbsp;Web | Erste Version: Backgammon gegen den Computer in drei Spielstärken, mit Dopplerwürfel, 3D-Brett, Würfelstatistik und gespeicherter Partie |

Die Web-Version ist seit 2026-11-03 online und zeigt immer den neuesten Stand.

## Geplant

| Release | Inhalt |
| --- | --- |
| **1.1.x** | Dunkleres Auswurffach für Schwarz<br>Sprechblase „Annehmen oder Ablehnen“, wenn der Computer doppelt |
| **Microsoft&nbsp;Store** | Windows-Version als MSIX, ohne Warnung beim ersten Start und mit automatischen Updates |
| **2.0.0** | Coach, der Züge in Alltagssprache erklärt<br>Regel-Nachschlagewerk<br>Würfelbecher<br>Feiner abgestufte Spielstärken |

Weitere Ideen ohne Version stehen in der [Roadmap](docs/roadmap-und-anforderungen.md#später).

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

### Releases

| Version | Date | Platforms | New |
| --- | --- | --- | --- |
| **1.1.0**&nbsp;(8) | 2026&#8209;11&#8209;11 | Android,&nbsp;Windows,&nbsp;Web | The app is now available in English<br>First Windows version, as a ZIP on GitHub Releases<br>Personal leaderboard with total points per level and your latest games<br>"Play to the end" bears off faster and saves the gammon and backgammon where it can<br>Adjustable pace with a countdown ring<br>App icon with a smaller logo<br>Arrows to page through long texts |
| **1.0.0**&nbsp;(6) | 2026&#8209;11&#8209;07 | Android,&nbsp;Web | First version: backgammon against the computer in three levels, with doubling cube, 3D board, dice statistics and saved game |

The web version has been online since 2026-11-03 and always shows the latest state.

### Planned

| Release | Content |
| --- | --- |
| **1.1.x** | Darker bear-off tray for Black<br>Speech bubble "Take or pass" when the computer doubles |
| **Microsoft&nbsp;Store** | Windows version as MSIX, without the warning on first start and with automatic updates |
| **2.0.0** | Coach that explains moves in plain language<br>Rules reference<br>Dice cup<br>Finer-grained levels |

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
