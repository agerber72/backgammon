# Anforderungen und Roadmap

Stand: 2026-11-03 · Grundlage: [vision.md](vision.md)

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
| [D7 Coach](#d7-coach) | Coach und Regel-Nachschlagewerk | 2 |

Der Brett-Prototyp kommt zuerst: Er macht das Look and Feel früh sichtbar und prüft das größte technische Risiko, die Grafik. Bis die Regel-Engine steht, zeigt er eine feste Beispielstellung. Was danach kommt, steht unter [Später](#später).

## Versionen

Die App-Version steht nur in `pubspec.yaml` als `Hauptversion.Nebenversion.Korrektur+Build`. Flutter übernimmt sie für Android (`versionName`, `versionCode`), Windows und Web.

| Version | Bedeutung |
| --- | --- |
| `0.D.n` | Vor dem Release: `D` ist die Delivery, an der gerade gearbeitet wird; `n` zählt Korrekturen innerhalb dieser Delivery |
| `1.0.0` | Release von Version 1, also D6 abgeschlossen |
| `1.y.0` | Neue Funktionen aus [Später](#später) ohne neue Hauptversion |
| `1.y.n` | Fehlerbehebungen ohne neue Funktion |
| `2.0.0` | Release von Version 2 mit dem Coach aus D7 |

- Die Hauptversion entspricht der Spalte Version in der Tabelle oben.
- Ist eine Delivery abgeschlossen, steigt die Nebenversion im selben Schritt, in dem der letzte Haken gesetzt wird.
- Die Build-Nummer hinter `+` wird vor jedem Build erhöht, der das Gerät des Entwicklers verlässt, etwa für den Play Store oder für Tester. Sie wird nie zurückgesetzt, denn Google Play verlangt einen steigenden `versionCode`.
- Jede veröffentlichte Version bekommt auf GitHub ein Tag `vX.Y.Z`.

Aktueller Stand: `0.6.0+1`, D5 ist abgeschlossen, D6 ist in Arbeit, noch nichts veröffentlicht.

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

- [ ] **T6.1 Release vorbereiten** (`A-801` bis `A-803`)
    - [x] Fremdlizenzen in der App anzeigen
    - [x] Datenschutz und Impressum in der App anzeigen
    - [x] Web-Version ohne Google-Server ausliefern
    - [x] Datenschutzerklärung entwerfen, je Plattform passend angezeigt (`A-805`)
    - [x] Impressum als eigene Seite für GitHub Pages erzeugen: `web/impressum.html` aus `assets/legal/imprint_de.md` (`A-809`)
    - [ ] Datenschutzerklärung ebenso als Seite für GitHub Pages erzeugen; Google Play verlangt einen öffentlichen Link
    - [ ] Datenschutzerklärung und Impressum rechtlich prüfen lassen, ENTWURF und Platzhalter entfernen, Seiten neu erzeugen und mit der Web-Version auf GitHub Pages veröffentlichen
    - [x] Android-Sicherung und Geräteübertragung abschalten (`A-807`)
    - [x] Berechtigungen des Release-APK geprüft: keine Internetberechtigung, nur die interne Berechtigung `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` von AndroidX (Stand 2026-11-03)
    - [x] Web-Version speichert nichts im Browser (`A-808`); geprüft: Local Storage, Session Storage und Cookies bleiben leer
    - [ ] Prüfen, dass keine Werbung, Tracker oder Konten enthalten sind
- [ ] **T6.2 Veröffentlichen** (`A-804`)
    - [x] Android-Signatur einrichten: Upload-Schlüssel außerhalb des Repos, signiertes Bundle gebaut und auf einem Handy installiert (Stand 2026-11-03)
    - [ ] Im Play Store einreichen
    - [ ] Windows-Build bereitstellen
    - [ ] Web-Version bereitstellen
    - [ ] Version in `pubspec.yaml` auf `1.0.0` setzen und die Build-Nummer erhöhen (siehe [Versionen](#versionen))
    - [ ] Version 1.0.0 auf GitHub markieren

### D7 Coach

Die Tasks werden erst nach Version 1 verfeinert.

- [ ] **T7.1 Regel-Nachschlagewerk** (`A-901`)
- [ ] **T7.2 Merkmale berechnen** (`A-902`)
    - [ ] Blots, Trefferchancen, Pip-Stand, Punkte, Primes
- [ ] **T7.3 Coach-Erklärungen** (`A-903`, `A-904`)
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
| A-113 | Ist ein Zug vollständig gesetzt und wird er bis zum Ablauf der Wartezeit nicht beendet, endet er von selbst. Die Wartezeit beträgt 3 Sekunden und lässt sich in den Einstellungen auf 5 oder 10 Sekunden ändern oder ausschalten. | D3 |
| A-116 | Nach dem Zug des Computers wird nach derselben Wartezeit automatisch gewürfelt. Bis dahin kann der Spieler selbst würfeln oder doppeln. | D3 |
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
| A-322 | Zu Beginn einer Partie zeigt ein Pfeil als liegendes U einige Sekunden lang die Spielrichtung des Spielers: von seinen hintersten Steinen bis ins Heimfeld. Danach blendet er aus. | D5 |
| A-323 | Der Rahmen des Bretts ist aus hellem Holz in der Art von Birne. | D5 |
| A-315 | Alle Knöpfe auf dem Brett haben in jeder Spielphase dieselbe Höhe, alle Symbole in der Leiste dieselbe Größe. | D3 |
| A-316 | Das Fach, in das ein Spieler auswürfelt, trägt den Filz in dessen Farbe. | D3 |
| A-318 | Knöpfe, Dialoge und Symbole wachsen und schrumpfen mit der Fenstergröße. Bezug ist ein quer gehaltenes Handy mit 900 × 420 dp. Nach oben gibt es keine Grenze, nach unten höchstens auf die Hälfte. Knöpfe haben auf allen Plattformen dieselbe Dichte, und der Einstellungsdialog passt ohne Scrollen auf den Bildschirm. | D5 |
| A-319 | Die Symbolspalte rechts überdeckt das Brett nicht; das Brett lässt ihr Platz. | D5 |
| A-320 | Im Spiel liegt keine Entscheidung auf dem Brett. Würfeln, Doppeln, Annehmen, Ablehnen, Weiter, Zurücknehmen, Zug beenden, Zu Ende spielen und Aufgeben stehen als Symbole am unteren Ende der rechten Leiste; alle in der Markenfarbe. Aufgeben steht immer ganz unten, damit es nicht springt. Jedes Symbol hat einen Tooltip, ein Doppelangebot zeigt den neuen Einsatz. | D5 |
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

### 5xx Fairness

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-501 | Die Würfel sind fair und bevorzugen keine Seite und keine Spielstärke. | D2 |
| A-502 | Die App zeigt eine Würfelstatistik. | D5 |

### 6xx Mehrsprachigkeit

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-601 | Alle sichtbaren Texte liegen in Sprachdateien. Die Oberfläche ist in Version 1 auf Deutsch. | D0 |
| A-602 | Das Layout verträgt längere Texte. Eine neue Sprache braucht nur eine Übersetzung. | D5 |

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
| A-809 | Das Impressum ist neben der Web-Version als eigene Seite erreichbar. Sie entsteht aus demselben Text wie in der App und lädt nichts von fremden Servern. | D6 |
| A-803 | Die App zeigt ihre Lizenz GPL-3.0 und die Lizenzen der verwendeten Pakete. | D6 |
| A-804 | Version 1 erscheint für Android, Windows und Web. | D6 |

### 9xx Coach (Version 2)

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-901 | Ein Regel-Nachschlagewerk erklärt alle Regeln verständlich. | D7 |
| A-902 | Die App berechnet Merkmale wie Blots, Trefferchancen, Pip-Stand, Punkte und Primes. | D7 |
| A-903 | Der Coach bewertet Züge und erklärt sie in Alltagssprache, regelbasiert und ohne Sprachmodell. | D7 |
| A-904 | Fachbegriffe werden beim ersten Auftreten erklärt. | D7 |

## Später

Diese Punkte stehen in der Vision, sind aber keiner Delivery zugeordnet:

- Beim kombinierten Zug die Wahl zwischen Reihenfolgen mit und ohne Schlagen anbieten
- Animation beim Schlagen und beim Würfelwurf
- Würfelbecher modellieren und anzeigen (Version 2, aus `A-302` verschoben)
- Zwei Spieler am selben Gerät (Version 2 oder 3)
- Zusatzregeln Jacoby, Beaver und automatisches Doppeln als Einstellung (Version 3)
- Matches auf mehrere Punkte
- Interaktives Tutorial, Tagesaufgaben, Partie nachträglich durchgehen
- Prüfbare Würfelfolge offenlegen
- Englisch und weitere Sprachen
- Weitere Brett-Designs

## Offene Punkte

- [ ] Leistung gezielt messen: Ansichtswechsel auf Android-Gerät, Windows und Web sind bei der Abnahme von T1.6 nicht gemessen worden. Vorschlag: spätestens in D3 mit echten Animationen.
- [x] Würfelbecher aus `A-302`: in Version 2 verschoben, siehe [Später](#später).
- [ ] Wie viele Spielstärken soll es geben? Vorschlag: drei.
- [x] Play Store: Veröffentlichung nach dem Test aus T5.4 über das Konto der Passion to Grow GmbH.
- [x] Rechtlicher Anbieter: Das Copyright bleibt bei Achim Gerber, die Passion to Grow GmbH veröffentlicht die App und stellt Impressum und Datenschutzerklärung. Die Nutzungserlaubnis an die GmbH ist noch fachlich zu prüfen.
- [ ] Datenschutzerklärung und Impressum prüfen lassen, den Vermerk ENTWURF entfernen und auf GitHub Pages veröffentlichen. Die Texte liegen in `assets/legal/`, erscheinen in der App unter Einstellungen und werden mit `tools/legal/build_pages.dart` zu Seiten in `web/`.
- [x] Automatische Android-Sicherung des Spielstands: abgeschaltet (`A-807`).
- [x] Wo läuft die Web-Version? Auf GitHub Pages, ohne Speicher im Browser (`A-808`).
- [ ] Wie wird die Windows-Version verteilt? Vorschlag: als Download über GitHub Releases.
