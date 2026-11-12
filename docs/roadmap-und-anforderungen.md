# Anforderungen und Roadmap

Stand: 2026-11-11 · Grundlage: [vision.md](vision.md)

Die Tasks werden von oben nach unten abgearbeitet. Ein Haken wird erst gesetzt, wenn der Task die [Definition of Done](#definition-of-done) erfüllt. Verweise wie `A-101` zeigen auf die [Anforderungen](#anforderungen) weiter unten.

| Delivery | Ergebnis | Version |
| --- | --- | --- |
| [D0 Fundament](#d0-fundament) | Projekt, Werkzeuge und Mehrsprachigkeit stehen | 1 |
| [D1 Brett-Prototyp](#d1-brett-prototyp) | Gerendertes Brett in beiden Ansichten auf allen Plattformen, Look and Feel sichtbar | 1 |
| [D2 Regel-Engine](#d2-regel-engine) | Vollständige, getestete Backgammon-Regeln in reinem Dart | 1 |
| [D3 Spielbare Partie](#d3-spielbare-partie) | Eine Partie lässt sich am Brett bedienen | 1 |
| [D4 Computer-Gegner](#d4-computer-gegner) | Gegner in mehreren Stufen, inklusive Dopplerwürfel | 1 |
| [D5 Fertigstellung](#d5-fertigstellung) | Speichern, Würfelstatistik, Einstellungen, Feinschliff | 1 |
| [D6 Release Version 1](#d6-release-version-1) | Version 1 ist auf allen Plattformen veröffentlicht | 1 |
| [D7 Englisch](#d7-englisch) | App, Rechtstexte und Store-Eintrag auch auf Englisch; persönliche Bestenliste, schnelleres Zu-Ende-Spielen und besserer Spielfluss | 1.1 |
| [D8 Coach](#d8-coach) | Coach und Regel-Nachschlagewerk | 2 |

Der Brett-Prototyp kommt zuerst: Er macht das Look and Feel früh sichtbar und prüft das größte technische Risiko, die Grafik. Bis die Regel-Engine steht, zeigt er eine feste Beispielstellung. Was danach kommt, steht unter [Später](#später).

## Versionen

Die App-Version steht nur in `pubspec.yaml` als `Hauptversion.Nebenversion.Korrektur+Build`. Flutter übernimmt sie für Android (`versionName`, `versionCode`), Windows und Web.

| Version | Bedeutung |
| --- | --- |
| `0.D.n` | Vor dem Release: `D` ist die Delivery, an der gerade gearbeitet wird; `n` zählt Korrekturen innerhalb dieser Delivery |
| `1.0.0` | Release von Version 1, also D6 abgeschlossen |
| `1.y.0` | Neue Funktionen aus [Später](#später) ohne neue Hauptversion |
| `1.y.n` | Fehlerbehebungen ohne neue Funktion |
| `1.1.0` | Zwischenrelease mit Englisch, Bestenliste und schnellerem Zu-Ende-Spielen aus D7 |
| `2.0.0` | Release von Version 2 mit dem Coach aus D8 |

- Die Hauptversion entspricht der Spalte Version in der Tabelle oben.
- Ist eine Delivery abgeschlossen, steigt die Nebenversion im selben Schritt, in dem der letzte Haken gesetzt wird.
- Die Build-Nummer hinter `+` wird vor jedem Build erhöht, der das Gerät des Entwicklers verlässt, etwa für den Play Store oder für Tester. Sie wird nie zurückgesetzt, denn Google Play verlangt einen steigenden `versionCode`.
- Jede veröffentlichte Version bekommt auf GitHub ein Tag `vX.Y.Z`.

Aktueller Stand: Version 1.1.0 (8) ist seit 2026-11-11 im Play Store in Produktion, auf Deutsch und Englisch, und auf GitHub als `v1.1.0` markiert; 1.0.0 (6) trägt das Tag `v1.0.0`. Die Windows-Version 1.1.0 liegt als ZIP im GitHub-Release `v1.1.0`, die Web-Version ist öffentlich. D6 ist damit abgeschlossen. Die Befunde aus T7.10 sind umgesetzt: Version 1.1.1 (9) liegt seit 2026-11-12 bei Google zur Prüfung für die Produktion, die Windows-Version 1.1.1 im GitHub-Release `v1.1.1` (T7.11).

## Tasks

### D0 Fundament

- [x] **T0.1 Projekt anlegen**
    - [x] Flutter-Projekt für Android, Windows und Web erzeugen
    - [x] Paketkennung `de.p2g_it.backgammon` setzen
    - [x] `CLAUDE.md` anlegen
- [x] **T0.2 GitHub einrichten**
    - [x] Öffentliches Repository anlegen
    - [x] GPL-3.0 und Copyright eintragen
    - [x] Private Notizen ausschließen
- [x] **T0.3 GNU Backgammon als Testwerkzeug einrichten**
    - [x] Installation per Skript mit Prüfsumme
    - [x] Bewertung über `hint.ps1` in wählbarer Tiefe
- [x] **T0.4 Mehrsprachigkeit vorbereiten** (`A-601`, `A-602`)
    - [x] Freigabe für die Pakete `flutter_localizations` und `intl` einholen
    - [x] Sprachdatei für Deutsch anlegen
    - [x] Vorlagentext der App aus der Sprachdatei laden
    - [x] Test: Kein sichtbarer Text ist fest im Code verdrahtet
- [x] **T0.5 Projektstruktur festlegen** (`A-701`)
    - [x] Ordner für Spiellogik, Oberfläche und Grafiken anlegen
    - [x] Vorlagencode von `flutter create` entfernen
    - [x] Automatische Prüfung auf GitHub einrichten: `flutter analyze` und `flutter test`

### D1 Brett-Prototyp

- [x] **T1.1 Blender einrichten** (`A-301`)
    - [x] Portable Blender-Version per Skript nach `tools/` installieren
    - [x] Von Git ausschließen
- [x] **T1.2 Render-Skript schreiben** (`A-301`, `A-302`)
    - [x] Brett mit 24 Zungen und Bar modellieren
    - [x] Steine, Würfel und Dopplerwürfel modellieren
    - [x] Eine Kamera je Ansicht festlegen
    - [x] Bilder für Schwarz und Weiß erzeugen
- [x] **T1.3 Brett in Flutter anzeigen** (`A-302`, `A-303`)
    - [x] Position jeder Zunge in beiden Ansichten berechnen
    - [x] Steine einer festen Beispielstellung an der richtigen Stelle und in richtiger Größe zeichnen
    - [x] Auf verschiedene Bildschirmgrößen anpassen
- [x] **T1.4 Ansicht wechseln** (`A-304`)
    - [x] Wechsel zwischen Schwarz und Weiß mit kurzem Übergang
- [x] **T1.5 Ablagefach umsetzen** (`A-306` bis `A-308`)
    - [x] Drei Fächer, Breite, Tiefe und Steindicke aus der Geometrie
    - [x] Steine hochkant in einer Reihe, 15 Steine füllen ein Fach exakt
- [x] **T1.7 Brett an die Anzeige anpassen** (`A-311`)
    - [x] Außenkante des Bretts exportieren und auf die Anzeige skalieren
    - [x] Tisch transparent rendern, Systemleisten ausblenden
- [x] **T1.8 Licht beim Ansichtswechsel prüfen** (`A-312`)
    - [x] Licht folgt der Kamera, beide Ansichten wirken natürlich; vom Benutzer abgenommen
- [x] **T1.6 Prototyp bewerten** (`A-305`)
    - [x] Optik prüfen
    - [x] Leistung auf Windows prüfen
    - [x] Leistung auf Android prüfen
    - [x] Leistung auf Web prüfen
    - [x] Entscheidung: weiter so, vom Benutzer abgenommen

### D2 Regel-Engine

- [x] **T2.1 Regeln festhalten** (`A-101`)
    - [x] Regeln aus einer belastbaren Quelle in `docs/regeln.md` zusammenfassen
    - [x] Offene Regelentscheidungen klären (siehe [Offene Punkte](#offene-punkte))
- [x] **T2.2 Spielzustand modellieren** (`A-102`, `A-701`)
    - [x] Brett mit 24 Zungen, Bar und ausgewürfelten Steinen abbilden
    - [x] Startaufstellung und Spieler am Zug abbilden
    - [x] Zustand unveränderlich und ohne Flutter-Abhängigkeit halten
- [x] **T2.3 Würfel umsetzen** (`A-103`, `A-501`)
    - [x] Fairen Zufallsgenerator kapseln
    - [x] Eröffnungswurf umsetzen
    - [x] Festgelegte Würfelfolgen für Tests ermöglichen
- [x] **T2.4 Erlaubte Züge berechnen** (`A-104` bis `A-108`)
    - [x] Einfache Züge und Schlagen
    - [x] Wiedereinsetzen von der Bar
    - [x] Pasch mit vier Zügen
    - [x] Pflicht, beide Würfel beziehungsweise den höheren zu nutzen
    - [x] Auswürfeln
- [x] **T2.5 Partieende und Wertung** (`A-109`)
    - [x] Sieg, Gammon und Backgammon erkennen
- [x] **T2.6 Dopplerwürfel** (`A-110`)
    - [x] Anbieten, annehmen, ablehnen
    - [x] Besitz des Würfels und Wert in der Wertung
- [x] **T2.7 Gegen GNU Backgammon absichern** (`A-702`)
    - [x] Konverter für die GNU-Position-ID schreiben
    - [x] Skript um eine Liste aller erlaubten Züge erweitern
    - [x] Erlaubte Züge für viele Positionen automatisch vergleichen

### D3 Spielbare Partie

- [x] **T3.1 Regel-Engine anbinden** (`A-201`)
    - [x] Partiezustand der Oberfläche bereitstellen
    - [x] Würfeln auslösen und anzeigen
- [x] **T3.2 Züge bedienen** (`A-202`, `A-203`)
    - [x] Stein auswählen und erlaubte Ziele anzeigen
    - [x] Gewählten Stein markieren, Ziele als durchsichtige Steine zeigen (`A-314`)
    - [x] Knöpfe auf den Filz legen und mit dem Brett skalieren (`A-313`, `A-315`)
    - [x] Stein per Tippen, Klicken oder Ziehen bewegen
    - [x] Treffer auf der Zunge in beiden Ansichten zuverlässig machen
- [x] **T3.3 Zug zurücknehmen** (`A-204`)
    - [x] Zurücknehmen bis zur Bestätigung des Zugs
- [x] **T3.4 Animationen** (`A-205`)
    - [x] Gezogene Steine gleiten auf ihr Ziel
    - [x] Ausgewürfelte Steine gleiten ins Fach
    - [x] Abnahme durch den Benutzer; Schlagen und Würfelwurf stehen unter Später
- [x] **T3.5 Partieablauf** (`A-206`, `A-207`)
    - [x] Farbe wählen und Partie starten
    - [x] Dopplerwürfel bedienen
    - [x] Ergebnis anzeigen und neue Partie starten

### D4 Computer-Gegner

- [x] **T4.1 Stellungsbewertung** (`A-401`, `A-402`)
    - [x] Austauschbare Engine-Schnittstelle festlegen
    - [x] Stellungsbewertung in Dart schreiben
- [x] **T4.2 Zugwahl** (`A-402`, `A-403`)
    - [x] Besten Zug nach Bewertung wählen
    - [x] Drei Stufen über gezielte Bewertungsfehler abbilden
- [x] **T4.3 Würfelentscheidungen** (`A-404`)
    - [x] Doppeln, annehmen und ablehnen entscheiden
- [x] **T4.4 Ohne Ruckeln rechnen** (`A-405`)
    - [x] Berechnung so kurz halten, dass sie das Zeichnen nicht stört
- [x] **T4.5 Stärke messen** (`A-406`, `A-702`)
    - [x] Gewinnschätzung für Würfelentscheidungen gegen GNU Backgammon abstimmen
    - [x] Zugwahl mit GNU Backgammon vergleichen

### D5 Fertigstellung

- [x] **T5.1 Partie speichern** (`A-208`)
    - [x] Laufende Partie lokal sichern und fortsetzen
- [x] **T5.2 Würfelstatistik** (`A-502`)
    - [x] Würfe je Partie und gesamt erfassen
    - [x] Statistik anzeigen
- [x] **T5.3 Einstellungen** (`A-209`)
    - [x] Stufe, Farbe und Ansicht wählen
- [x] **T5.4 Feinschliff**
    - [x] App-Symbol aus dem P2G-Logo (`tools/icon/`)
    - [x] Startbildschirm
    - [x] Texte auf Länge und Verständlichkeit prüfen (`A-602`)
    - [x] Bedienung mit jemandem testen, der die App nicht kennt
- [x] **T5.5 Praxistest** (Befunde aus dem Test auf echten Geräten, abgeschlossen am 2026-11-03)
    - [x] Handy: Knöpfe als lesbares Popup statt auf dem schmalen Filz (`A-313`)
    - [x] Handy: Zu Ende spielen als fester Knopf rechts, jederzeit wählbar (`A-114`)
    - [x] Handy: Würfel doppelt so groß (`A-317`)
    - [x] Kombinierter Zug nimmt bei zwei Reihenfolgen den Weg, der unterwegs schlägt (`A-215`)
    - [x] Knöpfe, Dialoge und Symbole skalieren mit der Fenstergröße (`A-318`, P-1, P-7); unter Windows in drei Fenstergrößen geprüft
    - [x] Popup am Partieende breit genug für Ergebnis und Knopf (`A-313`, P-2)
    - [x] Symbolspalte liegt neben dem Brett (`A-319`, P-3)
    - [x] Lizenzseite erklärt vor der Liste, was sie zeigt (`A-806`, P-6)
    - [x] Entscheidungen im Spiel als Symbole unten in der rechten Leiste, Brett bleibt frei (`A-320`, P-8)
    - [x] Farben der Knöpfe aus dem App-Symbol (`A-321`, P-8)
    - [x] Ziele mit Ring in der Gegenfarbe (`A-314`, P-11)
    - [x] Pfeil für die Spielrichtung zu Beginn einer Partie (`A-322`, P-12)
    - [x] Brettrahmen aus hellem Holz (`A-323`, P-13)

    Neue Befunde hier eintragen, eine Zeile pro Befund. Die Spalte Anforderung bleibt leer, bis klar ist, welche Anforderung sich ändert oder neu entsteht.

    | Nr. | Gerät | Befund | Wunsch | Anforderung |
    | --- | --- | --- | --- | --- |
    | P-1 | Windows, kleines Fenster | Knöpfe, Dialoge sowie Kopf- und Fußzeile der Einstellungen wachsen und schrumpfen nicht mit der Fenstergröße. Im kleinen Fenster nehmen Titel und „Schließen“ fast den ganzen Dialog ein, vom Inhalt ist nur „Deine Farbe“ sichtbar. | Knöpfe und Dialoge skalieren mit der Größe der App, der Inhalt der Einstellungen bleibt nutzbar. | `A-318`, umgesetzt am 2026-11-03 |
    | P-2 | Windows, kleines Fenster | Das Popup am Partieende ist zu schmal: Der Ergebnistext ist abgeschnitten („nt: 1 Punkt“), „Neue Partie“ bricht Buchstabe für Buchstabe senkrecht um. | Ergebnis vollständig lesbar, Knopf einzeilig. | `A-313`, umgesetzt am 2026-11-03 |
    | P-3 | Windows, kleines Fenster | Die Symbolspalte rechts (Ansicht, Einstellungen, Statistik, Aufgeben) überdeckt das Brett mit Zungen und Fach, weil die Symbole ihre Größe behalten. | Symbole verdecken das Brett nicht oder skalieren mit. | `A-319`, umgesetzt am 2026-11-03 |
    | P-4 | alle | Gegen „Leicht“ in mehreren Partien kein einziges Mal gewonnen. Das macht keinen Spaß. | „Leicht“ ist für Einsteiger tatsächlich schlagbar. | `A-407` bis `A-409`, Task T5.6, umgesetzt am 2026-11-03 |
    | P-5 | alle | Bei einem kombinierten Zug wie 5-1 mit zwei möglichen Reihenfolgen nahm die App den Weg ohne Schlag, auch wenn unterwegs ein gegnerischer Blot stand. | Den Weg nehmen, auf dem der gegnerische Stein geschlagen wird. | `A-215`, umgesetzt am 2026-11-03 |
    | P-6 | Handy | Die Seite Lizenzen ist für Spieler unverständlich: Sie zeigt nur „Powered by Flutter“ und eine lange Liste technischer Paketnamen (abseil-cpp, accessibility, angle, args …) mit Lizenzanzahlen, ohne Erklärung. | Verständlich machen: zuerst kurz erklären, was die Seite zeigt und unter welcher Lizenz die App selbst steht; die technische Liste erst danach. | `A-806`, umgesetzt am 2026-11-03 |
    | P-7 | Windows | Nach der Umsetzung von P-1 passen sich Knöpfe und Dialoge immer noch nicht an das Fenster an; die Bedienbarkeit ist nicht gegeben. Ursachen: Der Faktor war auf höchstens 1,5 begrenzt, das maximierte Fenster (3840 × 2036 Pixel bei 175 %) braucht 2,4; auf dem Desktop macht Flutter Knöpfe zudem kompakter; der Einstellungsdialog war für das Querformat zu hoch. | Knöpfe und Dialoge passen in jeder Fenstergröße zum Brett und bleiben bedienbar. | `A-318`, umgesetzt am 2026-11-03 |
    | P-8 | Windows | Popups wie „Zurücknehmen“ stören im Spielverlauf auf dem Spielfeld. Die Knöpfe haben noch das grüne Farbschema. | Eine Leiste rechts mit allen Entscheidungen als Symbole am unteren Ende; Farben der Knöpfe aus dem App-Symbol. | `A-320`, `A-321`, umgesetzt am 2026-11-03 |
    | P-9 | Windows | Die Knopffarbe passt noch nicht zur Marke, „Aufgeben“ springt in der Leiste, und eine neue Partie startet ohne Frage nach der Farbe. | Knopffarbe aus `icon.png`, Aufgeben ganz unten, bei neuer Partie erneut nach der Farbe fragen. | `A-216`, `A-320`, `A-321`, umgesetzt am 2026-11-03 |
    | P-10 | alle | Im App-Symbol dominiert das dunkle Blau des Hintergrunds. | Markenblau `#5B84C3` als Hintergrund, das dunklere Blau auf die Zungen; Zungen reichen ohne Rand bis an die Kanten, oben und unten gleich groß; Steine 10 % kleiner, Zungen entsprechend kürzer, damit in der Mitte mehr Markenblau bleibt. | umgesetzt am 2026-11-03 in `tools/icon/render_icon_art.py`, verteilt auf Android, Web und Windows |
    | P-11 | alle | Zugvorschläge sind schlecht zu sehen: Die weiß-transparente Markierung verschwindet auf einer weißen Zunge und als sechster Stein auf einem weißen Stein. | Kontrast verbessern, zum Beispiel die Zielfelder mit einem deutlich markierten Kreis in der Komplementärfarbe (Schwarz auf Weiß, Weiß auf Schwarz). | `A-314`, umgesetzt am 2026-11-03 |
    | P-12 | alle | Am Anfang ist nicht klar, in welche Richtung die eigenen Steine ziehen. | Zu Beginn kurz einen Pfeil als liegendes U in Spielrichtung einblenden. | `A-322`, umgesetzt am 2026-11-03 |
    | P-13 | alle | Anregung zur Optik des Bretts. | Brett aus hellem Holz, zum Beispiel Birne. | `A-323`, umgesetzt am 2026-11-03 |
- [x] **T5.6 Stufe Leicht schlagbar machen** (`A-407` bis `A-409`, Befund P-4)
    - [x] Messen: Leicht gegen einen Zufallsspieler und einen einfachen Anfängerspieler, der Steine möglichst weit vorzieht; Ausgangswert: Der Anfänger gewann 46 von 300 Partien (15 %), Punkte 58 zu 705 (`tools/engine/compare_levels.dart`)
    - [x] Leicht macht in der Hälfte der Züge einen typischen Anfängerfehler, wenn der Wurf einen zulässt: Stein ungeschützt stehen lassen, Treffer auslassen, fertigen Punkt aufbrechen, zu früh in die Heimat ziehen. In den übrigen Zügen bleibt der Zufallsfehler von 0,5.
    - [x] Dopplerwürfel für Leicht entschärfen: doppelt erst ab 95 % Gewinnchance und nimmt Doppel ab 10 % an
    - [x] Erneut gemessen: Der Anfänger gewinnt 137 von 300 Partien (46 %), Punkte 195 zu 269; ein Test sichert mindestens 40 % ab
    - [x] Mittel und Schwer bleiben unverändert; Vergleich der Stufen in [architektur.md](architektur.md) eingetragen

### D6 Release Version 1

- [x] **T6.1 Release vorbereiten** (`A-801` bis `A-803`)
    - [x] Fremdlizenzen in der App anzeigen
    - [x] Datenschutz und Impressum in der App anzeigen
    - [x] Web-Version ohne Google-Server ausliefern
    - [x] Datenschutzerklärung entwerfen, je Plattform passend angezeigt (`A-805`)
    - [x] Impressum als eigene Seite für GitHub Pages erzeugen: `web/impressum.html` aus `assets/legal/imprint_de.md` (`A-809`)
    - [x] Datenschutzerklärung ebenso als Seite für GitHub Pages erzeugen, mit den Abschnitten aller Plattformen: `web/datenschutz.html`; Google Play verlangt einen öffentlichen Link
    - [x] ENTWURF und Platzhalter entfernen, Stand 3. November 2026, Seiten neu erzeugen und mit der Web-Version auf GitHub Pages veröffentlichen
    - [x] Datenschutzerklärung und Impressum vom Benutzer geprüft und freigegeben (2026-11-04), ohne externe juristische Prüfung: Das Risiko gilt bei einer App ohne Datenverarbeitung als gering. Impressum mit USt-IdNr. DE326044499; ein Hinweis zur Verbraucherstreitbeilegung entfällt, weil die GmbH weniger als 10 Beschäftigte hat. Datenschutzerklärung mit Stand 4. November 2026
    - [x] Android-Sicherung und Geräteübertragung abschalten (`A-807`)
    - [x] Berechtigungen des Release-APK geprüft: keine Internetberechtigung, nur die interne Berechtigung `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` von AndroidX (Stand 2026-11-03)
    - [x] Web-Version speichert nichts im Browser (`A-808`); geprüft: Local Storage, Session Storage und Cookies bleiben leer
    - [x] Geprüft am 2026-11-04, Version 0.6.3: keine Werbung, Tracker oder Konten. Laufzeit-Abhängigkeiten sind nur Flutter, `intl`, `cupertino_icons` und `shared_preferences`; das Release-Manifest fordert nur `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` an, keine Internetberechtigung und keine Werbe-ID; der Code im Bundle enthält keine Klassen von Google Ads, Firebase, Analytics, Facebook, Adjust, AppsFlyer, Sentry oder Google-Login
- [x] **T6.2 Veröffentlichen** (`A-804`)
    - [x] Android-Signatur einrichten: Upload-Schlüssel außerhalb des Repos, signiertes Bundle gebaut und auf einem Handy installiert (Stand 2026-11-03)
    - [x] Interner Test über Google Play mit 1.0.0 (6) bestanden (2026-11-04): aus dem Play Store installiert und gespielt; automatischer Schutz aus, Bundle ohne `CHECK_LICENSE`
    - [x] Im Play Store eingereicht (2026-11-04): Produktion 1.0.0 (6), alle Länder, ohne verwaltete Veröffentlichung, also live direkt nach der Freigabe
    - [x] Freigabe durch Google: 1.0.0 (6) ist in Produktion, laut Play Console veröffentlicht am 2026-11-07; seitdem ist die verwaltete Veröffentlichung aktiviert, freigegebene Änderungen gehen also erst nach einem Klick auf „Änderungen veröffentlichen“ live
    - [x] Windows-Build bereitstellen (mit Version 1.1.0)
        - [x] ZIP bauen: `./tools/windows/build_release.ps1` erzeugt `build/release/backgammon_windows_1.1.0-8.zip` mit Visual-C++-Laufzeit und Lizenz und startet die entpackte App zur Probe (2026-11-11, bestanden)
        - [x] ZIP an das GitHub-Release `v1.1.0` gehängt (2026-11-11): https://github.com/agerber72/backgammon/releases/tag/v1.1.0; geprüft: `releases/latest` führt dorthin, das heruntergeladene ZIP ist identisch und die App startet daraus
        - Der Microsoft Store folgt als eigener Punkt unter [Später](#später)
    - [x] Web-Version bereitstellen (2026-11-03, Version 0.6.0): Workflow `.github/workflows/pages.yml` veröffentlicht jeden Stand auf `main` nach `https://agerber72.github.io/backgammon/`
    - [x] Version in `pubspec.yaml` auf `1.0.0+6` gesetzt; Build 5 wurde nur hochgeladen und verworfen, weil Google den automatischen Schutz mit `CHECK_LICENSE` eingefügt hatte (siehe [Versionen](#versionen))
    - [x] Store-Eintrag vorbereitet: Texte in [store-eintrag.md](store-eintrag.md), Symbol, Vorstellungsgrafik und sechs Screenshots in `docs/store/1.0.0/` aus `tools/store/store_graphics_test.dart`
    - [x] Version 1.0.0 auf GitHub markieren: Tag `v1.0.0` auf dem Commit `f04baea` (2026-11-11)
- [x] **T6.3 Befunde vor dem Release** (Test auf echten Geräten)

    | Nr. | Gerät | Befund | Wunsch | Anforderung |
    | --- | --- | --- | --- | --- |
    | P-14 | Android | Ist nach dem Wurf kein Zug möglich, etwa weil ein geschlagener Stein nicht einsetzen kann, wartet die App auf „Kein Zug möglich“ (⏭). Die Spielerin empfand das als Hänger: Der Knopf sah aus wie alle anderen, und anders als beim Zug beenden und Würfeln läuft hier keine Wartezeit ab. | Knöpfe, die nur in bestimmten Situationen erscheinen, fallen auf: invertiert, weiß mit blauem Symbol. | `A-324` und `A-117`, umgesetzt am 2026-11-04 in Version 0.6.1: invertierte Farben, und „Kein Zug möglich“ geht nach der Wartezeit von selbst weiter |

- [x] **T6.4 Feinschliff vor dem Release**
    - [x] App-Version rechts oben in den Einstellungen (`A-218`)
    - [x] Zweite Bildstufe für hohe Auflösungen, etwa 4K (`A-325`)
    - [x] Stein auf der Bar ist zum Einsetzen schon gewählt (`A-217`)
    - [x] Pfeil der Spielrichtung in P2G-Blau, auf dem freien Filz bis ins Auswurffach (`A-322`)
    - [x] Filz in Billardgrün `#2D5746`
    - [x] Ungenutzte Bilder `checker_*_edge.png` entfernt
    - [x] Struktur des Filzes: Variante „fein“ aus drei Vorschauen gewählt, beide Stufen neu gerendert

### D7 Englisch

Zwischenrelease 1.1.0 nach Version 1.

- [x] **T7.1 Oberfläche übersetzen** (`A-603`)
    - [x] `app_en.arb` mit allen Texten; Begriffe beim Dopplerwürfel wie im Englischen üblich: *Double*, *Take*, *Pass*
    - [x] Systemsprache wählt die Sprache: Deutsch bei `de`, sonst Englisch (`appLocale` in `backgammon_app.dart`)
    - [x] Sprache in den Einstellungen über zwei Flaggen wählbar, gespeichert auf Android und Windows (`A-605`, Wunsch vom 2026-11-09)
    - [x] Test: Jeder Text hat eine englische Fassung; bestehende Tests laufen über `test/flutter_test_config.dart` fest auf Deutsch
    - [x] Englische Texte gegengelesen (2026-11-09): in Ordnung
- [x] **T7.2 Rechtstexte auf Englisch** (`A-604`)
    - [x] `privacy_en.md` und `imprint_en.md`, mit dem Hinweis, dass die deutsche Fassung maßgeblich ist; beide Fassungen nennen die Bestenliste, Stand 9. November 2026
    - [x] App lädt die Rechtstexte in ihrer Sprache
    - [x] Englische Seiten für GitHub Pages erzeugen: `web/imprint.html` und `web/privacy.html`
    - [x] Übersetzung und Ergänzung der Datenschutzerklärung durch den Anbieter prüfen: mit der Veröffentlichung von 1.1.0 am 2026-11-11 freigegeben
- [x] **T7.3 Store-Eintrag auf Englisch**
    - [x] Kurzbeschreibung, Beschreibung und Versionshinweise in [store-eintrag.md](store-eintrag.md); Screenshots und Vorstellungsgrafik in `docs/store/1.1.0/en/`
    - [x] Länder: schon mit Version 1.0.0 weltweit freigegeben (Entscheidung vom 2026-11-04), weil der deutsche Store-Eintrag die Sprache klar zeigt
    - [x] Englischen Eintrag (en-US) in der Play Console anlegen: von Google freigegeben und am 2026-11-11 veröffentlicht
- [x] **T7.4 Persönliche Bestenliste** (`A-219`, Rückmeldung eines Benutzers vom 2026-11-09)
    - [x] Jede beendete Partie gegen den Computer festhalten: Datum, Spielstärke, Farbe, Spielzeit, Punkte des Spielers und Punkte des Computers
    - [x] Bestenliste im Statistik-Dialog: Gesamtpunkte je Stufe und über alle Stufen, darunter die letzten 100 Partien, neueste zuerst; die Gesamtpunkte zählen auch Partien, die aus der Liste gefallen sind (Entscheidung vom 2026-11-09)
    - [x] Spielzeit zählt, solange die App geöffnet ist; die Zeit bei geschlossener App zählt nicht
    - [x] Web-Version: keine Bestenliste, `A-808` bleibt (Entscheidung vom 2026-11-09)
- [x] **T7.5 Schneller auswürfeln beim Zu-Ende-Spielen** (`A-410`, Rückmeldung eines Benutzers vom 2026-11-09)
    - [x] Beim automatischen Zu-Ende-Spielen (`A-114`) kommen alle Steine so schnell wie möglich ins Heimfeld, den letzten Quadranten (`lib/engine/race.dart`)
    - [x] Im Heimfeld wird möglichst mit jedem Würfel ein Stein ausgewürfelt, statt Steine innerhalb des Heimfelds zu ziehen
    - [x] Test mit Beispielstellungen und Vergleich der durchschnittlichen Zahl an Würfen bis zum Ende: 13,1 statt 15,5 Würfe in 200 zufälligen Rennen (Stand 2026-11-09)
- [x] **T7.6 P2G-Logo im App-Symbol kleiner** (`A-326`, Wunsch vom 2026-11-09)
    - [x] P2G-Logo im App-Symbol um 8 % verkleinern (`tools/icon/render_icon_art.py`), auf Android, Web und Windows verteilen
    - [x] Test: Auf Android ist das Logo in jeder Maskenform des adaptiven Symbols (Kreis, Squircle, abgerundetes Quadrat) vollständig sichtbar und hat rundum einen angenehmen Abstand zum Rand. Gemessen reichte das Logo bisher 36,9 dp weit, die Schutzzone aber nur 33 dp, runde Masken schnitten also die Spitze ab. Mit 8 % kleinerem Logo und dem Motiv auf 70 statt 85 % im adaptiven Symbol reicht es 28,3 dp weit (`test/app/app_icon_test.dart`)
    - [x] Auf dem Emulator angesehen (2026-11-09, runde Maske): Logo vollständig sichtbar
    - [x] Auf dem echten Handy angesehen (2026-11-09): in Ordnung
    - [x] Symbol im Store-Eintrag (`docs/store/1.1.0/icon_512.png`) erneuern, jetzt aus `tools/icon/render_icon.py`
- [x] **T7.8 Spielfluss** (`A-220` bis `A-224`, Vorschlag vom 2026-11-09)
    - [x] Je nach Situation warten: Ein Zug ohne Alternative endet sofort; ohne Recht zum Doppeln würfelt die App nach dem Computer gleich; „Kein Zug möglich“ geht nach 60 % der Wartezeit weiter
    - [x] Spieltempo statt Sekunden: Aus, Ruhig, Normal, Zügig; alte Einstellungen werden übernommen (0 s → Aus, 3 s → Normal, 5 und 10 s → Ruhig)
    - [x] Countdown als Ring um das Symbol, das gleich ausgelöst wird; ein weiterer Tipp aufs Brett startet das Zugende neu
    - [x] „Kein Zug möglich“ als Hinweis auf dem Filz
    - [x] Schalter „Pflichtzüge selbst setzen“, voreingestellt aus
    - [x] Dopplerwürfel immer zeigen, solange man doppeln darf; außerhalb des eigenen Wurfs merkt ein Tipp das Doppeln vor, und vor dem nächsten Wurf fragt die App nach, statt selbst zu würfeln (`A-225`, Rückmeldung vom 2026-11-09: im flüssigen Spiel blieb kaum Zeit zum Doppeln)
    - [x] Der Name „Gemütlich“ aus dem Vorschlag passte auf dem Handy nicht in die Einstellungen; die Stufe heißt „Ruhig“
    - [x] Rückmeldung vom 2026-11-09 umgesetzt: Der Ring machte die rechte Leiste breiter, und die Hinweise auf dem Filz gehörten optisch nicht zu ihrem Symbol; jetzt liegt der Ring auf dem Symbol, und die Hinweise stehen direkt daneben. Der vorgemerkte Würfel war bei der Nachfrage weiß auf weiß
    - [x] Praxistest am Handy: über den internen Test im Play Store am 2026-11-11, die Befunde stehen in T7.9 und T7.10
- [x] **T7.9 Befunde aus dem Spielen** (Rückmeldung vom 2026-11-11, gehören noch in 1.1.0)
    - [x] Statistik: Bestenliste als erster Reiter und beim Öffnen gewählt, Würfelstatistik danach (`A-219`)
    - [x] Zu Ende spielen: Wer das Rennen verloren und noch keinen Stein abgetragen hat, wendet zuerst Backgammon, dann Gammon ab (`A-411`, `lib/engine/race.dart`); gilt für beide Seiten und jede Spielstärke
    - [x] Test: Beispielstellungen und 1000 zufällige verlorene Rennen: 0 statt 48 Backgammons, im Schnitt 1,44 statt 1,53 verlorene Punkte; Gammons bleiben gleich häufig (452 statt 450), weil sie meist schon durch den Rennstand feststehen (Stand 2026-11-11)
    - [x] Scrollbare Dialoge und Rechtstexte zeigen weiteren Text mit auslaufendem Rand und kleinen Pfeilen am rechten Rand, die beim Tippen eine Seite nach unten oder oben scrollen (`A-327`, Rückmeldung vom 2026-11-11: kleiner, invertiert, rechts, auch zurück, `lib/presentation/scroll_hint.dart`)
    - [x] Die Pfeile halten rechts einen schmalen Streifen frei, damit sie keinen Text verdecken; die beiden Spalten der Einstellungen schrumpfen bei zu wenig Platz leicht, statt überzulaufen
    - [x] Test auf Windows (2026-11-11)
    - [x] Test am Handy über den internen Test im Play Store (2026-11-11)
- [x] **T7.7 Release 1.1.0**
    - [x] Version `1.1.0+7` setzen und Bundle bauen
    - [x] Version `1.1.0+8` mit T7.9 setzen und Bundle neu bauen; Store-Screenshots der Einstellungen und der Bestenliste neu erzeugt; Store-Grafiken je Version in `docs/store/<version>/<sprache>/`, die von 1.0.0 wiederhergestellt
    - [x] Im Play Store und auf GitHub veröffentlichen (2026-11-11): Produktion 1.1.0 (8) mit vollständigem Roll-out, englischer Store-Eintrag und Erklärung zum Händlerstatus; Tag `v1.1.0` auf dem Commit `9d84ba1`
- [x] **T7.10 Befunde für das nächste Release** (Rückmeldungen vom 2026-11-11 und 2026-11-12 nach dem Test von 1.1.0 am Handy; umgesetzt in 1.1.1)
    - [x] Fach von Schwarz: Der schwarze Filz im Auswurffach von Schwarz ist jetzt dunkelgrau, damit sich die ausgewürfelten schwarzen Steine besser vom Grund abheben (`A-328`): `tray_felt_black` von `#232529` auf `#4B4E54` in `tools/blender/board_config.json`, Bilder in beiden Auflösungen neu gerendert, Store-Grafiken in `docs/store/1.1.1/` neu erzeugt (2026-11-12)
    - [x] Doppelangebot des Computers: Doppelt der Computer, steht neben dem neuen Einsatz über Annehmen und Ablehnen eine anklickbare Sprechblase wie beim eigenen Doppeln (`A-225`), etwa „×4 Annehmen oder Ablehnen“, damit der Spieler sieht, dass er sich entscheiden muss (`A-226`, Rückmeldung vom 2026-11-11, umgesetzt am 2026-11-12 mit Widget-Tests)
    - [x] Auswahl per Touch flackert: Am Handy geht seit 1.1.0 die Markierung eines angetippten Steins vor allem im schnellen Spieltempo kurz an und gleich wieder aus, sodass der Stein nicht sicher gewählt wirkt (`A-203`, Rückmeldung vom 2026-11-12). Ursache in `lib/presentation/game/game_page.dart`: Rutscht der Finger beim Tippen, erkennt der `GestureDetector` ein Ziehen statt eines Tipps; `onPanStart` wählte den Stein, `onPanEnd` tippte auf derselben Zunge noch einmal und wählte ihn wieder ab. Jetzt zählt ein Ziehen, das dort endet, wo es den Stein gewählt hat, als ein einziger Tipp (umgesetzt am 2026-11-12, Widget-Test mit verrutschendem Finger)
    - [x] Test am Handy: Touch-Korrektur per Release-APK über USB geprüft (2026-11-12)
- [ ] **T7.11 Release 1.1.1**
    - [x] Version `1.1.1+9` setzen, Bundle bauen, Store-Grafiken und Versionshinweise in `docs/store-eintrag.md` (2026-11-12)
    - [x] Interner Test im Play Store (2026-11-12), danach in Produktion übernommen, mit Versionshinweisen und neuen Screenshots zur Prüfung eingereicht
    - [ ] Nach der Freigabe durch Google mit „Änderungen veröffentlichen“ live schalten
    - [x] Windows-ZIP gebaut und gestartet, GitHub-Release `v1.1.1` mit Tag angelegt (2026-11-12)

### D8 Coach

Die Tasks werden erst nach Version 1 verfeinert.

- [ ] **T8.1 Regel-Nachschlagewerk** (`A-901`)
- [ ] **T8.2 Merkmale berechnen** (`A-902`)
    - [ ] Blots, Trefferchancen, Pip-Stand, Punkte, Primes
- [ ] **T8.3 Coach-Erklärungen** (`A-903`, `A-904`)
    - [ ] Züge bewerten und in Alltagssprache erklären
    - [ ] Tipps von erfahrenen Spielern prüfen lassen

## Definition of Done

Ein Task ist erledigt, wenn:

- `flutter analyze` und `flutter test` fehlerfrei durchlaufen,
- die Logik automatisiert getestet ist und jeder Testname Anforderung und Erwartung nennt,
- sichtbare Texte aus der Sprachdatei kommen,
- die Oberfläche auf Android, Windows und Web geprüft wurde, sofern der Task sie betrifft,
- Architekturentscheidungen in [architektur.md](architektur.md) nachgetragen sind.

## Anforderungen

### 1xx Spielregeln

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-101 | Die umgesetzten Regeln sind in `docs/regeln.md` mit Quelle dokumentiert. | D2 |
| A-102 | Das Spiel bildet 24 Zungen, Bar, ausgewürfelte Steine und je 15 Steine in der Startaufstellung ab. | D2 |
| A-103 | Der Eröffnungswurf bestimmt den ersten Spieler; bei gleicher Augenzahl wird wiederholt. | D2 |
| A-104 | Steine ziehen nur in Spielrichtung und nur auf Zungen mit höchstens einem gegnerischen Stein. | D2 |
| A-105 | Ein einzelner gegnerischer Stein wird geschlagen und kommt auf die Bar. | D2 |
| A-106 | Steine auf der Bar müssen zuerst wieder eingesetzt werden. | D2 |
| A-107 | Ein Pasch ergibt vier Züge. Beide Würfel müssen genutzt werden, wenn möglich; geht nur einer, dann der höhere. | D2 |
| A-108 | Auswürfeln ist nur möglich, wenn alle eigenen Steine im Heimfeld sind. | D2 |
| A-109 | Die Partie erkennt Sieg, Gammon und Backgammon und wertet einfach, doppelt und dreifach. | D2 |
| A-112 | Der Spieler kann die Partie jederzeit nach einer Sicherheitsabfrage aufgeben und verliert den aktuellen Würfelwert. | D3 |
| A-113 | Ist ein Zug vollständig gesetzt und wird er bis zum Ablauf der Wartezeit nicht beendet, endet er von selbst. Die Wartezeit folgt dem Spieltempo (`A-220`). | D3, geändert D7 |
| A-116 | Nach dem Zug des Computers wird nach derselben Wartezeit automatisch gewürfelt. Bis dahin kann der Spieler selbst würfeln oder doppeln; ohne Recht zum Doppeln gilt `A-221`. | D3, geändert D7 |
| A-117 | Ist nach dem Wurf kein Zug möglich, geht das Spiel nach 60 % der Wartezeit von selbst weiter. Bis dahin kann der Spieler selbst auf „Kein Zug möglich“ drücken; bei Spieltempo Aus wartet die App darauf. | D6, geändert D7 |
| A-114 | Können sich die Steine nicht mehr treffen, lässt sich die Partie jederzeit über einen festen Knopf rechts animiert zu Ende spielen, auch im Zug des Computers. Noch nicht beendete eigene Züge werden dabei verworfen. | D3 |
| A-111 | Version 1 spielt ohne die Zusatzregeln Jacoby, Beaver und automatisches Doppeln. Gammon und Backgammon zählen auch ohne gedrehten Dopplerwürfel. | D2 |
| A-110 | Der Dopplerwürfel unterstützt Anbieten, Annehmen und Ablehnen, Besitz und Wert bis 64. Ablehnen beendet die Partie. | D2 |

### 2xx Spielablauf und Bedienung

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-201 | Eine Partie startet ohne Konto und ohne Internetverbindung. | D3 |
| A-202 | Die App zeigt die erlaubten Züge des gewählten Steins an. | D3 |
| A-203 | Züge lassen sich mit Finger und Maus zuverlässig ausführen. | D3 |
| A-204 | Ein Zug lässt sich bis zu seiner Bestätigung zurücknehmen. | D3 |
| A-215 | Ein Stein kann in einem Schritt mehrere Würfel ziehen, wenn mindestens eine Reihenfolge frei ist. Führen zwei Reihenfolgen ans Ziel, nimmt er die, die unterwegs einen gegnerischen Stein schlägt. Bei einem Pasch sind alle noch offenen Vielfachen wählbar. Zurücknehmen nimmt immer nur den letzten Einzelzug zurück. | D3 |
| A-205 | Steine und Würfel bewegen sich animiert, damit der Gegnerzug nachvollziehbar ist. | D3 |
| A-206 | Der Spieler wählt Schwarz oder Weiß. | D3 |
| A-207 | Die App zeigt Ergebnis und Wertung und bietet eine neue Partie an. | D3 |
| A-208 | Eine laufende Partie bleibt beim Beenden erhalten und lässt sich fortsetzen. | D5 |
| A-209 | Spielstärke, Farbe und Ansicht lassen sich einstellen. | D5 |
| A-210 | Die App läuft nur im Querformat. | D0 |
| A-216 | Bei einer neuen Partie fragt die App erneut nach der Farbe. Die Spielstärke bleibt wie eingestellt. | D5 |
| A-217 | Kann nur ein Stein ziehen, etwa ein geschlagener Stein auf der Bar, der zuerst eingesetzt werden muss, ist er zu Beginn des Zugs und nach jedem Teilzug schon gewählt und zeigt seine Ziele. Erneutes Antippen wählt ihn nicht ab. | D6 |
| A-218 | Die Einstellungen zeigen rechts oben die App-Version mit Build-Nummer, zum Beispiel „Version 1.0.0 (6)“, vollständig lesbar in jeder Fenstergröße. Sie entspricht `version:` in `pubspec.yaml`. | D6 |
| A-220 | Die Einstellungen bieten ein Spieltempo: Aus, Ruhig, Normal (voreingestellt) und Zügig. Es setzt die Wartezeit für Zugende und Würfeln auf 4, 2 oder 1 Sekunde und die Pause zwischen den Zügen des Computers auf 0,8, 0,55 oder 0,3 Sekunden. Bei Aus geschieht nichts von selbst. | D7 |
| A-221 | Wo es keine Wahl gibt, wartet die App nicht: Ein Zug ohne Alternative endet sofort, und darf der Spieler nicht doppeln, würfelt die App nach dem Zug des Computers, sobald dessen Stein angekommen ist. Gilt nicht bei Spieltempo Aus. | D7 |
| A-222 | Um das Symbol, das die App gleich von selbst auslöst, läuft ein blauer Ring als Countdown ab. Er liegt auf dem Rand des Symbols und macht die rechte Leiste nicht breiter. Ein weiterer Tipp aufs Brett startet die Wartezeit bis zum Zugende neu. | D7 |
| A-223 | Hinweise zu einem Symbol stehen als weiße Sprechblase in dessen Farben direkt links daneben und lassen sich antippen, etwa „Kein Zug möglich“ neben Weiter und „Doppeln oder Würfeln“ neben dem Dopplerwürfel. | D7 |
| A-225 | Gegen den Computer steht der Dopplerwürfel rechts, solange der Spieler das Recht zum Doppeln hat, auch im Zug des Computers und beim eigenen Ziehen. Darf er gerade nicht doppeln, merkt ein Tipp das Doppeln vor, ein zweiter nimmt es zurück. Vor dem nächsten eigenen Wurf würfelt die App dann nicht von selbst, sondern fragt neben dem Würfel mit einer anklickbaren Sprechblase „×2 Doppeln oder Würfeln“; Würfeln oder Doppeln erledigt den Wunsch. | D7 |
| A-226 | Doppelt der Computer, steht neben Annehmen und Ablehnen eine anklickbare Sprechblase nach `A-223` mit dem neuen Einsatz, etwa „×4 Annehmen oder Ablehnen“. Sie erinnert daran, dass der Spieler sich entscheiden muss: annehmen und weiterspielen oder ablehnen und die Partie zum bisherigen Einsatz verlieren. | D7 |
| A-224 | Der Schalter „Pflichtzüge selbst setzen“ lässt die App einen Zug ohne Alternative Stein für Stein setzen und beenden. Voreingestellt ist er aus; die Einstellung bleibt gespeichert. | D7 |
| A-219 | Eine persönliche Bestenliste zeigt die gespielten Partien mit Spielstärke, Farbe, Spielzeit und Punkten des Spielers und des Computers sowie die Gesamtpunkte beider Seiten. Im Statistik-Dialog steht sie vor der Würfelstatistik und ist beim Öffnen gewählt. | D7 |

### 3xx Grafik

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-301 | Alle 3D-Grafiken entstehen reproduzierbar aus einem Blender-Skript im Repository. Farben, Material, Kamera und Maße stehen in `tools/blender/board_config.json`. | D1 |
| A-302 | Die App zeigt ein Turnierbrett im 3D-Stil mit Brett, 30 Steinen, Würfeln und Dopplerwürfel. Würfelbecher folgen in Version 2. | D1 |
| A-303 | Steine und Würfel passen in Perspektive und Größe exakt zum Brett. | D1 |
| A-304 | Das Brett lässt sich zwischen den Ansichten für Schwarz und Weiß wechseln. Ein freies Drehen gibt es nicht. | D1 |
| A-305 | Das Brett läuft flüssig auf Android, Windows und im Web. | D1 |
| A-306 | Das Ablagefach hat drei gleich große Fächer: je eines pro Spieler an den Enden und eines in der Mitte. In der Ansicht liegt das eigene Fach vorn. | D1 |
| A-307 | Herausgespielte Steine stehen hochkant in einer Reihe im Fach, beginnend am Rand der eigenen Seite. | D1 |
| A-310 | Der Dopplerwürfel liegt zu Beginn im mittleren Fach. Die Steine sind matt. | D1 |
| A-311 | Das Spielbrett füllt den angezeigten Ausschnitt so weit wie möglich aus, ohne verzerrt oder abgeschnitten zu werden. Die Systemleisten sind ausgeblendet. | D1 |
| A-312 | Licht und Schatten wirken in beiden Ansichten natürlich. | D1 |
| A-313 | Gilt für Farbwahl, Stufenwahl und Ergebnis; Entscheidungen im Spiel regelt `A-320`. Die Knöpfe liegen auf dem Filz zwischen den Zungenspitzen, auf der Bretthälfte ohne Würfel, und skalieren mit dem Brett. Wäre ein Knopf dort niedriger als 48 dp, erscheinen sie stattdessen als Popup in voller Größe und dürfen Zungen überdecken. Das Popup ist mindestens 320 dp breit, damit Texte und Knöpfe einzeilig bleiben. | D3 |
| A-317 | Auf kleinen Bildschirmen, auf denen die Knöpfe als Popup erscheinen, werden die Würfel doppelt so groß gezeichnet. | D3 |
| A-314 | Der gewählte Stein trägt eine Markierung. Durchsichtige Steine zeigen die möglichen Ziele, jeweils mit einem Ring in der Gegenfarbe des ziehenden Steins: schwarz mit hellem Rand für Weiß, hell mit dunklem Rand für Schwarz. So bleibt das Ziel auf hellen und dunklen Zungen und auf Steinen beider Farben sichtbar. Beim Auswürfeln trägt das Fach den Ring. | D3 |
| A-322 | Zu Beginn einer Partie zeigt ein Pfeil als liegendes U einige Sekunden lang die Spielrichtung des Spielers: von seinen hintersten Steinen über das Heimfeld bis in sein Auswurffach. Er ist P2G-blau, läuft auf dem freien Filz zwischen den Zungenspitzen, verdeckt keine Steine der Startaufstellung und richtet Breite und Bogen nach der Zungenbreite. Danach blendet er aus. | D5 |
| A-323 | Der Rahmen des Bretts ist aus hellem Holz in der Art von Birne. | D5 |
| A-315 | Alle Knöpfe auf dem Brett haben in jeder Spielphase dieselbe Höhe, alle Symbole in der Leiste dieselbe Größe. | D3 |
| A-316 | Das Fach, in das ein Spieler auswürfelt, trägt den Filz in dessen Farbe. | D3 |
| A-318 | Knöpfe, Dialoge und Symbole wachsen und schrumpfen mit der Fenstergröße. Bezug ist ein quer gehaltenes Handy mit 900 × 420 dp. Nach oben gibt es keine Grenze, nach unten höchstens auf die Hälfte. Knöpfe haben auf allen Plattformen dieselbe Dichte, und der Einstellungsdialog passt ohne Scrollen auf den Bildschirm. | D5 |
| A-319 | Die Symbolspalte rechts überdeckt das Brett nicht; das Brett lässt ihr Platz. | D5 |
| A-320 | Im Spiel liegt keine Entscheidung auf dem Brett. Würfeln, Doppeln, Annehmen, Ablehnen, Weiter, Zurücknehmen, Zug beenden, Zu Ende spielen und Aufgeben stehen als Symbole am unteren Ende der rechten Leiste; alle in der Markenfarbe, Farben nach `A-324`. Aufgeben steht immer ganz unten, damit es nicht springt. Jedes Symbol hat einen Tooltip, ein Doppelangebot zeigt den neuen Einsatz. | D5 |
| A-325 | Wird das Brett breiter als 2560 physische Pixel gezeichnet, etwa auf einem 4K-Bildschirm, nutzt die App eine zweite Stufe der Bilder in 3840 × 2160. Sie liegt in `assets/board/hd/` und gehört nur zu Web und Windows; Android nutzt immer die normalen Bilder. | D6 |
| A-324 | Symbole in der rechten Leiste, die nur in bestimmten Situationen erscheinen (Würfeln, Doppeln, Annehmen, Ablehnen, Kein Zug möglich, Zurücknehmen, Zug beenden, Zu Ende spielen), sind invertiert: weißer Grund mit blauem Symbol. Symbole, die immer da sind (Ansicht, Einstellungen, Statistik, Aufgeben), bleiben blau mit weißem Symbol. Knöpfe in Dialogen sind nicht betroffen. | D6 |
| A-326 | Das P2G-Logo im App-Symbol ist 8 % kleiner als in Version 1.0. Auf Android bleibt es in jeder Maskenform des adaptiven Symbols vollständig sichtbar, mit einem für das Auge angenehmen Abstand zum Rand: Es reicht höchstens 29 dp weit, die Schutzzone 33 dp. | D7 |
| A-327 | Lässt sich ein Dialog oder Rechtstext scrollen, läuft der Rand dort aus, wo weiterer Text verborgen ist, und kleine Pfeile am rechten Rand zeigen, dass unten oder oben noch Text folgt: blau mit weißem Pfeil, unten nach unten, oben nach oben. Ein Tipp scrollt eine Seite in diese Richtung; am Ende verschwindet der jeweilige Pfeil. Auf dem PC bleibt die Scrollleiste sichtbar. | D7 |
| A-328 | Der Filz im Auswurffach von Schwarz ist dunkelgrau statt schwarz, sodass ausgewürfelte schwarze Steine deutlich vom Grund abstechen. | D7 |
| A-321 | Knöpfe nutzen die Markenfarbe von p2g-it aus dem P2G-Logo (`assets/icon/icon.png`): Blau `#5B84C3` mit weißer Schrift für alle Knöpfe, Symbole und gewählten Auswahlen. | D5 |
| A-308 | Fachbreite, Fachtiefe und Steindicke ergeben sich aus der Geometrie. 15 hochkant stehende Steine füllen ein Fach exakt; hat ein Spieler gesiegt, ist sein Fach voll. | D1 |
| A-309 | Bis zu fünf Steine liegen nebeneinander auf einem Dreieck. Steine am Rand werden vom vorderen Rahmen verdeckt wie auf einem echten Brett. | D1 |

### 4xx Computer-Gegner

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-401 | Die Engine liegt hinter einer austauschbaren Schnittstelle. | D4 |
| A-402 | Die Engine ist in Dart geschrieben und enthält keinen Code oder Gewichtsdateien von GNU Backgammon. | D4 |
| A-403 | Es gibt mehrere Spielstärken. | D4 |
| A-404 | Der Computer trifft Würfelentscheidungen: doppeln, annehmen, ablehnen. | D4 |
| A-405 | Die Oberfläche bleibt bedienbar, während der Computer rechnet. | D4 |
| A-406 | Die Stärke wird gegen GNU Backgammon gemessen. | D4 |
| A-407 | Die Stufe Leicht ist für Einsteiger schlagbar: Ein einfacher Anfängerspieler gewinnt gegen sie mindestens 40 % der Partien. Gemessen am 2026-11-03: 46 %. | D5 |
| A-408 | Leicht macht erkennbare, menschliche Fehler, etwa ungeschützte Steine oder ausgelassene Treffer, statt zufällig unter guten Zügen zu wählen. | D5 |
| A-409 | Leicht doppelt selten oder nie und nimmt auch ungünstige Doppel an. | D5 |
| A-410 | Beim Zu-Ende-Spielen (`A-114`) bringt die App alle Steine möglichst schnell ins Heimfeld und würfelt dort möglichst mit jedem Würfel einen Stein aus. | D7 |
| A-411 | Beim Zu-Ende-Spielen begrenzt eine Seite, die das Rennen verloren und noch keinen Stein abgetragen hat, den Schaden: zuerst alle Steine aus dem Heimfeld des Gegners (Backgammon), dann alle Steine nach Hause, ohne Augen im Heimfeld zu verschenken, und so, dass möglichst viele Würfe gleich einen Stein abtragen (Gammon). Das gilt für beide Seiten und jede Spielstärke. | D7 |

### 5xx Fairness

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-501 | Die Würfel sind fair und bevorzugen keine Seite und keine Spielstärke. | D2 |
| A-502 | Die App zeigt eine Würfelstatistik. | D5 |

### 6xx Mehrsprachigkeit

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-601 | Alle sichtbaren Texte liegen in Sprachdateien. Die Oberfläche ist in Version 1.0 auf Deutsch. | D0 |
| A-602 | Das Layout verträgt längere Texte. Eine neue Sprache braucht nur eine Übersetzung. | D5 |
| A-603 | Ab Version 1.1 gibt es die Oberfläche auch auf Englisch. Die Systemsprache entscheidet: Deutsch bei Deutsch, sonst Englisch. | D7 |
| A-604 | Datenschutzerklärung und Impressum gibt es in der App und im Web auch auf Englisch; maßgeblich ist die deutsche Fassung. | D7 |
| A-605 | In den Einstellungen wählen zwei Flaggen die Sprache: Großbritannien für Englisch, Deutschland für Deutsch. Die Flagge der Gerätesprache folgt dem System, die andere legt die andere Sprache fest. Die Wahl gilt sofort und bleibt auf Android und Windows gespeichert. | D7 |

### 7xx Technik und Qualität

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-701 | Die Spiellogik ist reines Dart ohne Flutter-Abhängigkeit und gibt keine fertigen Texte aus. | D0 |
| A-702 | Erlaubte Züge und Bewertungen werden gegen GNU Backgammon geprüft. Es bleibt reines Testwerkzeug. | D2, D4 |
| A-703 | Die App läuft offline und braucht keinen Server. | D3 |

### 8xx Veröffentlichung

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-801 | Die App ist kostenlos und enthält keine Werbung, Käufe, Münzen oder Konten. | D6 |
| A-802 | Die App enthält keine Tracker und überträgt keine Spieldaten. | D6 |
| A-805 | Die App zeigt Datenschutzerklärung und Impressum offline an, jeweils nur mit den Abschnitten für die eigene Plattform. Die Web-Version lädt nichts von fremden Servern. | D6 |
| A-806 | Die Seite Lizenzen erklärt vor der technischen Liste, unter welcher Lizenz die App steht und was die Liste zeigt. | D6 |
| A-807 | Unter Android sind die App-Daten von der Geräte-Sicherung und der Übertragung auf ein neues Gerät ausgeschlossen. | D6 |
| A-808 | Die Web-Version speichert nichts im Browser; eine Partie besteht nur, solange die Seite geöffnet ist. | D6 |
| A-809 | Impressum und Datenschutzerklärung sind neben der Web-Version als eigene Seiten erreichbar. Sie entstehen aus demselben Text wie in der App, die Datenschutzerklärung mit den Abschnitten aller Plattformen, und laden nichts von fremden Servern. | D6 |
| A-803 | Die App zeigt ihre Lizenz GPL-3.0 und die Lizenzen der verwendeten Pakete. | D6 |
| A-804 | Version 1 erscheint für Android, Windows und Web. | D6 |

### 9xx Coach (Version 2)

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-901 | Ein Regel-Nachschlagewerk erklärt alle Regeln verständlich. | D8 |
| A-902 | Die App berechnet Merkmale wie Blots, Trefferchancen, Pip-Stand, Punkte und Primes. | D8 |
| A-903 | Der Coach bewertet Züge und erklärt sie in Alltagssprache, regelbasiert und ohne Sprachmodell. | D8 |
| A-904 | Fachbegriffe werden beim ersten Auftreten erklärt. | D8 |

## Später

Diese Punkte stehen in der Vision, sind aber keiner Delivery zugeordnet:

- Windows-Version als MSIX im Microsoft Store: Konto „Windows“ im Partner Center für die Passion to Grow GmbH registriert (2026-11-11, Prüfung durch Microsoft läuft); danach MSIX bauen und einreichen
- Beim kombinierten Zug die Wahl zwischen Reihenfolgen mit und ohne Schlagen anbieten
- Animation beim Schlagen und beim Würfelwurf
- Würfelbecher modellieren und anzeigen (Version 2, aus `A-302` verschoben)
- Spielstärken Leicht und Mittel anpassen (Version 2, Wunsch vom 2026-11-04): Leicht lässt keine offensichtlichen Schlagmöglichkeiten aus, sondern übersieht nur Treffer, die nicht auf der Hand liegen. Ändert den Fehler „Treffer auslassen“ aus `A-408`. Was sich bei Mittel ändern soll, ist noch offen.
- Zwei Spieler am selben Gerät (Version 2 oder 3)
- Zusatzregeln Jacoby, Beaver und automatisches Doppeln als Einstellung (Version 3)
- Matches auf mehrere Punkte
- Interaktives Tutorial, Tagesaufgaben, Partie nachträglich durchgehen
- Prüfbare Würfelfolge offenlegen
- Weitere Sprachen
- Weitere Brett-Designs

## Offene Punkte

- [ ] Leistung gezielt messen: Ansichtswechsel auf Android-Gerät, Windows und Web sind bei der Abnahme von T1.6 nicht gemessen worden. Vorschlag: spätestens in D3 mit echten Animationen.
- [x] Würfelbecher aus `A-302`: in Version 2 verschoben, siehe [Später](#später).
- [ ] Wie viele Spielstärken soll es geben? Vorschlag: drei.
- [x] Play Store: Veröffentlichung nach dem Test aus T5.4 über das Konto der Passion to Grow GmbH.
- [x] Rechtlicher Anbieter: Das Copyright bleibt bei Achim Gerber, die Passion to Grow GmbH veröffentlicht die App und stellt Impressum und Datenschutzerklärung. Die Nutzungserlaubnis an die GmbH ist noch fachlich zu prüfen.
- [x] Datenschutzerklärung und Impressum: am 2026-11-04 vom Benutzer geprüft und freigegeben, ohne externe juristische Prüfung (siehe T6.1). Vor den englischen Fassungen in D7 erneut ansehen. Die Texte liegen in `assets/legal/`, erscheinen in der App unter Einstellungen und werden mit `tools/legal/build_pages.dart` zu Seiten in `web/`.
- [x] Automatische Android-Sicherung des Spielstands: abgeschaltet (`A-807`).
- [x] Wo läuft die Web-Version? Auf GitHub Pages, ohne Speicher im Browser (`A-808`).
- [x] Wie wird die Windows-Version verteilt? Zuerst als ZIP über GitHub Releases, unsigniert, mit Warnung von SmartScreen beim ersten Start; danach über den Microsoft Store als MSIX, Konto der Passion to Grow GmbH im Partner Center (Entscheidung vom 2026-11-11).
