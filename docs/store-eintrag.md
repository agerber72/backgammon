# Store-Eintrag Google Play

Stand: 2026-11-12 · Version 1.1.1 (9) · Sprachen Deutsch (de-DE) und Englisch (en-US)

Texte zum Kopieren in die Play Console. Die Grafiken liegen je Version in `store/<version>/`: deutsch in [store/1.1.1/de/](store/1.1.1/de/), englisch in [store/1.1.1/en/](store/1.1.1/en/), das Symbol in [store/1.1.1/](store/1.1.1/). Sie entstehen mit `flutter test tools/store/store_graphics_test.dart` aus der echten Oberfläche, und zwar im Ordner der Version aus `pubspec.yaml`. Die Bilder früherer Versionen bleiben liegen, etwa [store/1.1.0/](store/1.1.0/) und [store/1.0.0/](store/1.0.0/).

## App erstellen

| Feld | Wert |
| --- | --- |
| App-Name | Backgammon |
| Standardsprache | Deutsch – de-DE |
| App oder Spiel | Spiel |
| Kostenlos oder kostenpflichtig | Kostenlos |

## Hauptstore-Eintrag

**App-Name** (höchstens 30 Zeichen)

```
Backgammon
```

**Kurzbeschreibung** (höchstens 80 Zeichen)

```
Backgammon gegen den Computer: kostenlos, ohne Werbung, ohne Konto, offline.
```

**Vollständige Beschreibung** (höchstens 4000 Zeichen)

```
Backgammon wie am echten Brett: ein Turnierbrett aus hellem Holz mit grünem Filz, Steine und Würfel im 3D-Stil. Ohne Werbung, ohne Konto und ohne Internet.

GEGEN DEN COMPUTER
• Drei Spielstärken: Leicht für den Einstieg, Mittel und Schwer für erfahrene Spieler
• Der Computer entscheidet auch beim Dopplerwürfel: doppeln, annehmen oder ablehnen
• Alle Regeln: Schlagen, Einsetzen von der Bar, Pasch, Auswürfeln, Gammon und Backgammon

EINFACH ZU BEDIENEN
• Stein antippen oder ziehen, die erlaubten Ziele werden angezeigt
• Züge lassen sich bis zur Bestätigung zurücknehmen
• Ein Pfeil zeigt zu Beginn die Spielrichtung
• Flüssiges Spiel: Wo es nichts zu entscheiden gibt, geht es sofort weiter; das Spieltempo ist einstellbar, ein Ring zeigt, wann die App von selbst weitermacht
• Ist das Rennen entschieden, spielt die App die Partie auf Wunsch zügig zu Ende
• Das Brett lässt sich aus Sicht von Weiß oder Schwarz zeigen
• Auf Deutsch und Englisch, die Sprache lässt sich in den Einstellungen wählen

FAIR UND NACHVOLLZIEHBAR
• Faire Würfel, die keine Seite und keine Spielstärke bevorzugen
• Würfelstatistik für die laufende Partie und alle Partien
• Persönliche Bestenliste: Gesamtpunkte je Spielstärke und deine letzten Partien mit Spielzeit
• Die laufende Partie bleibt beim Beenden erhalten und lässt sich fortsetzen

DEINE DATEN BLEIBEN BEI DIR
• Keine Werbung, keine In-App-Käufe, kein Konto
• Kein Tracking und keine Berechtigung für den Internetzugriff
• Spielstand, Einstellungen und Statistik bleiben auf deinem Gerät

FREIE SOFTWARE
Backgammon ist freie Software unter der GNU General Public License Version 3. Den Quellcode gibt es auf GitHub: https://github.com/agerber72/backgammon

Auch im Browser spielbar: https://agerber72.github.io/backgammon/
```

## Englischer Store-Eintrag (en-US)

In der Play Console unter Hauptstore-Eintrag → Übersetzungen verwalten → Englisch (USA) – en-US anlegen. Die Grafiken stammen aus [store/1.1.1/en/](store/1.1.1/en/), das App-Symbol ist dasselbe.

**App-Name**

```
Backgammon
```

**Kurzbeschreibung** (höchstens 80 Zeichen)

```
Backgammon against the computer: free, no ads, no account, works offline.
```

**Vollständige Beschreibung** (höchstens 4000 Zeichen)

```
Backgammon like on a real board: a tournament board of light wood with green felt, checkers and dice in 3D style. No ads, no account and no internet needed.

AGAINST THE COMPUTER
• Three levels: Easy for beginners, Medium and Hard for experienced players
• The computer also handles the doubling cube: double, take or pass
• All rules: hitting, entering from the bar, doubles, bearing off, gammon and backgammon

EASY TO PLAY
• Tap or drag a checker, the legal targets are shown
• Moves can be undone until you confirm them
• An arrow shows the direction of play at the start
• Smooth play: where there is nothing to decide, the game goes on at once; the pace is adjustable, and a ring shows when the app goes on by itself
• Once the race is decided, the app can quickly play the game to the end
• The board can be shown from White's or Black's side
• In English and German, the language can be chosen in the settings

FAIR AND TRANSPARENT
• Fair dice that favor neither side nor any level
• Dice statistics for the current game and all games
• Personal leaderboard: total points per level and your latest games with play time
• The current game is kept when you close the app and can be continued

YOUR DATA STAYS WITH YOU
• No ads, no in-app purchases, no account
• No tracking and no permission to access the internet
• Game, settings and statistics stay on your device

FREE SOFTWARE
Backgammon is free software under the GNU General Public License version 3. The source code is on GitHub: https://github.com/agerber72/backgammon

Also playable in the browser: https://agerber72.github.io/backgammon/
```

## Grafiken

| Feld | Datei | Vorgabe von Google |
| --- | --- | --- |
| App-Symbol | [store/1.1.1/icon_512.png](store/1.1.1/icon_512.png) | 512 × 512, PNG; Google rundet die Ecken selbst ab |
| Vorstellungsgrafik | [store/1.1.1/de/feature_graphic.png](store/1.1.1/de/feature_graphic.png) | 1024 × 500 |
| Screenshots Smartphone | `store/screenshot_*.png` | 2 bis 8 Bilder; 1920 × 1080 im Querformat |
| Screenshots Tablet 7 Zoll | `store/tablet7_screenshot_*.png` | 1920 × 1200 im Querformat |
| Screenshots Tablet 10 Zoll | `store/tablet10_screenshot_*.png` | 2560 × 1600 im Querformat |
| Englisch | `store/1.1.1/en/` mit denselben Namen | wie oben |

Reihenfolge der Screenshots für jedes Gerät: 2 Spielbeginn mit Richtungspfeil, 3 Zug mit Zielen, 4 Doppelangebot, 7 Bestenliste, 5 Ergebnis, 1 Farbwahl, 6 Einstellungen. Die ersten Bilder sieht man im Store zuerst, deshalb steht das Spiel vorn.

Keine eigenen Assets für Google Play Games auf dem PC (eigene Plattform; Windows hat die eigene Version), Desktop/ChromeOS (optional) und Android XR (nicht relevant).

## Kategorie und Kontakt

| Feld | Wert |
| --- | --- |
| App-Kategorie | Spiele → Brettspiele |
| Tags | Backgammon, Brettspiel, Würfelspiel |
| E-Mail-Adresse | apps@passion-to-grow.com |
| Telefon | leer lassen |
| Website | https://agerber72.github.io/backgammon/ |
| Datenschutzerklärung | https://agerber72.github.io/backgammon/datenschutz.html |
| Externes Marketing | an: Google darf die App auf eigene Kosten außerhalb von Google Play bewerben; ohne Einfluss auf die App und ihre Daten |

## App-Inhalte

| Punkt | Antwort |
| --- | --- |
| Datenschutzerklärung | https://agerber72.github.io/backgammon/datenschutz.html |
| App-Zugriff | Alle Funktionen sind ohne besonderen Zugriff verfügbar |
| Anzeigen | Nein, die App enthält keine Werbung |
| Einstufung des Inhalts | Kategorie Spiel; Gewalt, Angst, Sexualität, Sprache, Drogen: Nein; simuliertes Glücksspiel: Nein, Brettspiel ohne Einsätze; Nutzerinteraktion, Standortfreigabe, Käufe: Nein. Ergebnis vom 2026-11-04: USK ab 0 Jahren, PEGI 3, ESRB Jedes Alter, IARC ab 3 Jahren, ohne Inhaltsbeschreibungen |
| Zielgruppe | ab 13 Jahren: 13–15, 16–17 und 18+; keine Gruppe unter 13, sonst gilt die Familienrichtlinie. App-Präsenz: spricht nicht unbeabsichtigt Kinder an (klassisches Brettspiel, realistische Grafik, keine Comicfiguren). Anzeigen: Nein |
| Datensicherheit | Die App erfasst keine Daten und gibt keine Daten weiter |
| Werbe-ID | Nein, die App nutzt keine Werbe-ID |
| Behörden-App, Finanzfunktionen, Gesundheit, Nachrichten | jeweils Nein |

## Länder

Alle Länder, die Google Play anbietet (Entscheidung vom 2026-11-04). Version 1.0.0 war nur auf Deutsch; ab Version 1.1.0 gibt es App und Store-Eintrag auch auf Englisch. Die App zeigt Deutsch bei deutscher Systemsprache, sonst Englisch.

## Release

| Feld | Wert |
| --- | --- |
| Track | zuerst Interner Test, danach dasselbe Bundle in Produktion übernehmen |
| Bundle | `build/release/de.p2g_it.backgammon_1.1.1-9.aab` aus `./tools/android/build_bundle.ps1`; das Skript prüft Versionscode und Berechtigungen |
| Release-Name | 1.1.1 (9) |
| Veröffentlicht | noch offen; am 2026-11-12 nach dem internen Test in Produktion übernommen und mit Versionshinweisen und Screenshots aus `store/1.1.1/` zur Prüfung eingereicht |
| Vorher | 1.1.0 (8), veröffentlicht am 2026-11-11 mit vollständigem Roll-out; 1.0.0 (6), eingereicht am 2026-11-04, laut Play Console veröffentlicht am 2026-11-07 |
| Verwaltete Veröffentlichung | aktiviert: Von Google freigegebene Änderungen gehen erst mit „Änderungen veröffentlichen“ live |

**Optimierungen beim Release**

| Optimierung | Einstellung | Grund |
| --- | --- | --- |
| Play App Signing | an | Google signiert, wir laden mit dem Upload-Schlüssel hoch |
| Automatischer Schutz | **aus** | Er fügt `com.android.vending.CHECK_LICENSE` ein und sperrt Installationen außerhalb von Google Play. Das passt nicht zur Datenschutzerklärung („sendet keine Daten“) und nicht zur GPL. Build 5 wurde deshalb verworfen. |
| Play Games Sidekick | aus | bindet Google-Play-Games-Dienste ein |
| Automatische Übersetzung | aus | ungeprüfte Texte; Englisch ist ab 1.1.0 selbst übersetzt |

Nach einer Änderung an den Optimierungen verlangt Google ein neu hochgeladenes Bundle mit neuem Versionscode.

**Versionshinweise** (je Sprache höchstens 500 Zeichen)

```
<de-DE>
Neu in 1.1.1:
• Antippen wählt den Stein zuverlässig, auch wenn der Finger etwas verrutscht
• Doppelt der Computer, fragt eine Sprechblase „Annehmen oder Ablehnen“
• Dunkelgraues Auswurffach für Schwarz, damit die schwarzen Steine besser zu sehen sind
</de-DE>
<en-US>
New in 1.1.1:
• Tapping selects a checker reliably, even if your finger slips a little
• When the computer doubles, a speech bubble asks "Take or Pass"
• Dark grey bear-off tray for Black, so the black checkers stand out
</en-US>
```

Versionshinweise von 1.1.0 (8): „Die App gibt es jetzt auch auf Englisch; persönliche Bestenliste; „Zu Ende spielen“ würfelt schneller aus und rettet Gammon und Backgammon; einstellbares Spieltempo mit Countdown-Ring; neues App-Symbol.“ Versionshinweise von 1.0.0 (6): „Erste Version: Backgammon gegen den Computer in drei Spielstärken, mit Dopplerwürfel, Würfelstatistik und gespeicherter Partie.“
