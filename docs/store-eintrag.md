# Store-Eintrag Google Play

Stand: 2026-11-04 · Version 1.0.0 (6) · Sprache Deutsch (de-DE)

Texte zum Kopieren in die Play Console. Die Grafiken liegen in [store/](store/) und entstehen mit `flutter test tools/store/store_graphics_test.dart` aus der echten Oberfläche.

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
• Zug beenden und Würfeln gehen auf Wunsch nach einer Wartezeit von selbst weiter
• Das Brett lässt sich aus Sicht von Weiß oder Schwarz zeigen

FAIR UND NACHVOLLZIEHBAR
• Faire Würfel, die keine Seite und keine Spielstärke bevorzugen
• Würfelstatistik für die laufende Partie und alle Partien
• Die laufende Partie bleibt beim Beenden erhalten und lässt sich fortsetzen

DEINE DATEN BLEIBEN BEI DIR
• Keine Werbung, keine In-App-Käufe, kein Konto
• Kein Tracking und keine Berechtigung für den Internetzugriff
• Spielstand, Einstellungen und Statistik bleiben auf deinem Gerät

FREIE SOFTWARE
Backgammon ist freie Software unter der GNU General Public License Version 3. Den Quellcode gibt es auf GitHub: https://github.com/agerber72/backgammon

Auch im Browser spielbar: https://agerber72.github.io/backgammon/
```

## Grafiken

| Feld | Datei | Vorgabe von Google |
| --- | --- | --- |
| App-Symbol | [store/icon_512.png](store/icon_512.png) | 512 × 512, PNG; Google rundet die Ecken selbst ab |
| Vorstellungsgrafik | [store/feature_graphic.png](store/feature_graphic.png) | 1024 × 500 |
| Screenshots Smartphone | `store/screenshot_*.png` | 2 bis 8 Bilder; 1920 × 1080 im Querformat |
| Screenshots Tablet 7 Zoll | `store/tablet7_screenshot_*.png` | 1920 × 1200 im Querformat |
| Screenshots Tablet 10 Zoll | `store/tablet10_screenshot_*.png` | 2560 × 1600 im Querformat |

Reihenfolge der Screenshots für jedes Gerät: 2 Spielbeginn mit Richtungspfeil, 3 Zug mit Zielen, 4 Doppelangebot, 5 Ergebnis, 1 Farbwahl, 6 Einstellungen. Die ersten Bilder sieht man im Store zuerst, deshalb steht das Spiel vorn.

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

Alle Länder, die Google Play anbietet (Entscheidung vom 2026-11-04). App und Store-Eintrag sind bis Version 1.1.0 nur auf Deutsch; das ist im Eintrag sofort zu sehen. Englisch folgt mit Version 1.1.0 (D7).

## Release

| Feld | Wert |
| --- | --- |
| Track | zuerst Interner Test, danach dasselbe Bundle in Produktion übernehmen |
| Bundle | `build/release/de.p2g_it.backgammon_1.0.0-6.aab` aus `./tools/android/build_bundle.ps1`; das Skript prüft Versionscode und Berechtigungen |
| Release-Name | 1.0.0 (6) |

**Optimierungen beim Release**

| Optimierung | Einstellung | Grund |
| --- | --- | --- |
| Play App Signing | an | Google signiert, wir laden mit dem Upload-Schlüssel hoch |
| Automatischer Schutz | **aus** | Er fügt `com.android.vending.CHECK_LICENSE` ein und sperrt Installationen außerhalb von Google Play. Das passt nicht zur Datenschutzerklärung („sendet keine Daten“) und nicht zur GPL. Build 5 wurde deshalb verworfen. |
| Play Games Sidekick | aus | bindet Google-Play-Games-Dienste ein |
| Automatische Übersetzung | aus | ungeprüfte Texte; Englisch kommt mit 1.1.0 (D7) |

Nach einer Änderung an den Optimierungen verlangt Google ein neu hochgeladenes Bundle mit neuem Versionscode.

**Versionshinweise** (de-DE, höchstens 500 Zeichen)

```
<de-DE>
Erste Version: Backgammon gegen den Computer in drei Spielstärken, mit Dopplerwürfel, Würfelstatistik und gespeicherter Partie.
</de-DE>
```
