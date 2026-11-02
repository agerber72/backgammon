# Anforderungen und Roadmap

Stand: 2026-11-02 · Grundlage: [vision.md](vision.md)

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

- [ ] **T2.1 Regeln festhalten** (`A-101`)
    - [ ] Regeln aus einer belastbaren Quelle in `docs/regeln.md` zusammenfassen
    - [ ] Offene Regelentscheidungen klären (siehe [Offene Punkte](#offene-punkte))
- [ ] **T2.2 Spielzustand modellieren** (`A-102`, `A-701`)
    - [ ] Brett mit 24 Zungen, Bar und ausgewürfelten Steinen abbilden
    - [ ] Startaufstellung und Spieler am Zug abbilden
    - [ ] Zustand unveränderlich und ohne Flutter-Abhängigkeit halten
- [ ] **T2.3 Würfel umsetzen** (`A-103`, `A-501`)
    - [ ] Fairen Zufallsgenerator kapseln
    - [ ] Eröffnungswurf umsetzen
    - [ ] Festgelegte Würfelfolgen für Tests ermöglichen
- [ ] **T2.4 Erlaubte Züge berechnen** (`A-104` bis `A-108`)
    - [ ] Einfache Züge und Schlagen
    - [ ] Wiedereinsetzen von der Bar
    - [ ] Pasch mit vier Zügen
    - [ ] Pflicht, beide Würfel beziehungsweise den höheren zu nutzen
    - [ ] Auswürfeln
- [ ] **T2.5 Partieende und Wertung** (`A-109`)
    - [ ] Sieg, Gammon und Backgammon erkennen
- [ ] **T2.6 Dopplerwürfel** (`A-110`)
    - [ ] Anbieten, annehmen, ablehnen
    - [ ] Besitz des Würfels und Wert in der Wertung
- [ ] **T2.7 Gegen GNU Backgammon absichern** (`A-702`)
    - [ ] Konverter für die GNU-Position-ID schreiben
    - [ ] Skript um eine Liste aller erlaubten Züge erweitern
    - [ ] Erlaubte Züge für viele Positionen automatisch vergleichen

### D3 Spielbare Partie

- [ ] **T3.1 Regel-Engine anbinden** (`A-201`)
    - [ ] Partiezustand der Oberfläche bereitstellen
    - [ ] Würfeln auslösen und anzeigen
- [ ] **T3.2 Züge bedienen** (`A-202`, `A-203`)
    - [ ] Stein auswählen und erlaubte Ziele anzeigen
    - [ ] Stein per Tippen, Klicken oder Ziehen bewegen
    - [ ] Treffer auf der Zunge in beiden Ansichten zuverlässig machen
- [ ] **T3.3 Zug zurücknehmen** (`A-204`)
    - [ ] Zurücknehmen bis zur Bestätigung des Zugs
- [ ] **T3.4 Animationen** (`A-205`)
    - [ ] Steine und Würfel bewegen sich nachvollziehbar
- [ ] **T3.5 Partieablauf** (`A-206`, `A-207`)
    - [ ] Farbe wählen und Partie starten
    - [ ] Dopplerwürfel bedienen
    - [ ] Ergebnis anzeigen und neue Partie starten

### D4 Computer-Gegner

- [ ] **T4.1 Stellungsbewertung** (`A-401`, `A-402`)
    - [ ] Austauschbare Engine-Schnittstelle festlegen
    - [ ] Stellungsbewertung in Dart schreiben
- [ ] **T4.2 Zugwahl** (`A-402`, `A-403`)
    - [ ] Besten Zug nach Bewertung wählen
    - [ ] Stufen über Suchtiefe und gezielte Fehler abbilden
- [ ] **T4.3 Würfelentscheidungen** (`A-404`)
    - [ ] Doppeln, annehmen und ablehnen entscheiden
- [ ] **T4.4 Ohne Ruckeln rechnen** (`A-405`)
    - [ ] Berechnung vom Zeichnen entkoppeln, auch im Web
- [ ] **T4.5 Stärke messen** (`A-406`, `A-702`)
    - [ ] Skript um Würfelentscheidungen erweitern
    - [ ] Zugwahl mit GNU Backgammon vergleichen

### D5 Fertigstellung

- [ ] **T5.1 Partie speichern** (`A-208`)
    - [ ] Laufende Partie lokal sichern und fortsetzen
- [ ] **T5.2 Würfelstatistik** (`A-502`)
    - [ ] Würfe je Partie und gesamt erfassen
    - [ ] Statistik anzeigen
- [ ] **T5.3 Einstellungen** (`A-209`)
    - [ ] Stufe, Farbe und Ansicht wählen
- [ ] **T5.4 Feinschliff**
    - [x] App-Symbol aus dem P2G-Logo (`tools/icon/`)
    - [ ] Startbildschirm
    - [ ] Texte auf Länge und Verständlichkeit prüfen (`A-602`)
    - [ ] Bedienung mit jemandem testen, der die App nicht kennt

### D6 Release Version 1

- [ ] **T6.1 Release vorbereiten** (`A-801` bis `A-803`)
    - [ ] Fremdlizenzen in der App anzeigen
    - [ ] Datenschutzerklärung erstellen
    - [ ] Prüfen, dass keine Werbung, Tracker oder Konten enthalten sind
- [ ] **T6.2 Veröffentlichen** (`A-804`)
    - [ ] Android-Signatur einrichten und im Play Store einreichen
    - [ ] Windows-Build bereitstellen
    - [ ] Web-Version bereitstellen
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
| A-111 | Version 1 spielt ohne die Zusatzregeln Jacoby, Beaver und automatisches Doppeln. Gammon und Backgammon zählen auch ohne gedrehten Dopplerwürfel. | D2 |
| A-110 | Der Dopplerwürfel unterstützt Anbieten, Annehmen und Ablehnen, Besitz und Wert bis 64. Ablehnen beendet die Partie. | D2 |

### 2xx Spielablauf und Bedienung

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-201 | Eine Partie startet ohne Konto und ohne Internetverbindung. | D3 |
| A-202 | Die App zeigt die erlaubten Züge des gewählten Steins an. | D3 |
| A-203 | Züge lassen sich mit Finger und Maus zuverlässig ausführen. | D3 |
| A-204 | Ein Zug lässt sich bis zu seiner Bestätigung zurücknehmen. | D3 |
| A-205 | Steine und Würfel bewegen sich animiert, damit der Gegnerzug nachvollziehbar ist. | D3 |
| A-206 | Der Spieler wählt Schwarz oder Weiß. | D3 |
| A-207 | Die App zeigt Ergebnis und Wertung und bietet eine neue Partie an. | D3 |
| A-208 | Eine laufende Partie bleibt beim Beenden erhalten und lässt sich fortsetzen. | D5 |
| A-209 | Spielstärke, Farbe und Ansicht lassen sich einstellen. | D5 |
| A-210 | Die App läuft nur im Querformat. | D0 |

### 3xx Grafik

| ID | Anforderung | Delivery |
| --- | --- | --- |
| A-301 | Alle 3D-Grafiken entstehen reproduzierbar aus einem Blender-Skript im Repository. Farben, Material, Kamera und Maße stehen in `tools/blender/board_config.json`. | D1 |
| A-302 | Die App zeigt ein Turnierbrett im 3D-Stil mit Brett, 30 Steinen, Würfeln, Würfelbechern und Dopplerwürfel. | D1 |
| A-303 | Steine und Würfel passen in Perspektive und Größe exakt zum Brett. | D1 |
| A-304 | Das Brett lässt sich zwischen den Ansichten für Schwarz und Weiß wechseln. Ein freies Drehen gibt es nicht. | D1 |
| A-305 | Das Brett läuft flüssig auf Android, Windows und im Web. | D1 |
| A-306 | Das Ablagefach hat drei gleich große Fächer: je eines pro Spieler an den Enden und eines in der Mitte. In der Ansicht liegt das eigene Fach vorn. | D1 |
| A-307 | Herausgespielte Steine stehen hochkant in einer Reihe im Fach, beginnend am Rand der eigenen Seite. | D1 |
| A-310 | Der Dopplerwürfel liegt zu Beginn im mittleren Fach. Die Steine sind matt. | D1 |
| A-311 | Das Spielbrett füllt den angezeigten Ausschnitt so weit wie möglich aus, ohne verzerrt oder abgeschnitten zu werden. Die Systemleisten sind ausgeblendet. | D1 |
| A-312 | Licht und Schatten wirken in beiden Ansichten natürlich. | D1 |
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

- Zwei Spieler am selben Gerät (Version 2 oder 3)
- Zusatzregeln Jacoby, Beaver und automatisches Doppeln als Einstellung (Version 3)
- Matches auf mehrere Punkte
- Interaktives Tutorial, Tagesaufgaben, Partie nachträglich durchgehen
- Prüfbare Würfelfolge offenlegen
- Englisch und weitere Sprachen
- Weitere Brett-Designs

## Offene Punkte

- [ ] Leistung gezielt messen: Ansichtswechsel auf Android-Gerät, Windows und Web sind bei der Abnahme von T1.6 nicht gemessen worden. Vorschlag: spätestens in D3 mit echten Animationen.
- [ ] Würfelbecher aus `A-302` modellieren oder streichen.
- [ ] Wie viele Spielstärken soll es geben? Vorschlag: drei.
- [ ] Wo läuft die Web-Version? Vorschlag: GitHub Pages.
- [ ] Wie wird die Windows-Version verteilt? Vorschlag: als Download über GitHub Releases.
