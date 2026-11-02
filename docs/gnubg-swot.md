# SWOT: Nutzung von GNU Backgammon

Stand: 2026-11-02

**Empfehlung:** GNU Backgammon nicht in Version 1 einbauen, sondern während der Entwicklung als Prüfwerkzeug nutzen. Die App bekommt eine eigene Dart-Engine, und GNU Backgammon kontrolliert deren Bewertungen. Der Einbau bleibt später möglich, weil die Engine hinter einer austauschbaren Schnittstelle liegt.

## SWOT

| | Positiv | Negativ |
| --- | --- | --- |
| **Intern** | **Stärken:** sehr starke, frei verfügbare Engine; läuft offline; bewertet Züge und Dopplerwürfel; Android-Einsatz durch [CBG](https://f-droid.org/de/packages/com.clavierhaus.gnubg/) belegt | **Schwächen:** C-Code mit Pufferüberläufen in der Vergangenheit; liefert Zahlen, keine Erklärungen; GPL gilt für die ganze App; kein Sicherheitsaudit gefunden |
| **Extern** | **Chancen:** ersetzt fehlendes eigenes Spielwissen beim Prüfen; Open-Source-Code passt zum Portfolio; [gnubg-web](https://github.com/hwatheod/gnubg-web) zeigt, dass WebAssembly möglich ist | **Risiken:** kleines Projekt, wenige sichtbare Sicherheitsprüfungen; Einbindung auf drei Plattformen aufwändig; Web-Port basiert nur auf Version 1.05.000 und nennt Einschränkungen |

## Sicherheitslage

Es sind keine CVEs bekannt, aber eine systematische Sicherheitsprüfung habe ich ebenfalls nicht gefunden.

| Prüfung | Ergebnis |
| --- | --- |
| [NVD](https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=gnubg), Suche „gnubg“ | 0 Treffer |
| [NVD](https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=GNU%20Backgammon), Suche „GNU Backgammon“ | 0 Treffer |
| [Debian Security Tracker](https://security-tracker.debian.org/tracker/source-package/gnubg) | Keine Einträge |
| Audit oder Fuzzing | Nichts gefunden |
| Mailingliste bug-gnubg | Einzelne Abstürze, u. a. ein [Pufferüberlauf in `OutputEquity()`](https://lists.gnu.org/archive/html/bug-gnubg/2018-11/msg00011.html) in 1.06.002; ob er behoben ist, ist offen |

Null CVEs bedeuten nicht „sicher“. Bei einem kleinen Spielprogramm kann das auch heißen, dass kaum jemand gezielt gesucht hat.

## Risikoeinschätzung

Die Einstufung ist eine eigene Bewertung, keine Messung.

| Einsatz | Risiko | Begründung |
| --- | --- | --- |
| Entwicklungswerkzeug auf dem eigenen Rechner | Niedrig | Nur selbst erzeugte Positionen, nichts wird ausgeliefert |
| Eingebaut, nur Positionen aus der eigenen Dart-Logik | Niedrig | Keine fremden Eingaben, kein Netzwerk; Hauptrisiko sind Abstürze |
| Eingebaut im Web per WebAssembly | Niedrig | Browser-Sandbox begrenzt Fehlerfolgen |
| Eingebaut mit Import fremder Dateien (SGF, Position-IDs) | Mittel | Fremde Daten treffen auf C-Parser ohne bekanntes Fuzzing |
| Auf einem öffentlichen Server | Mittel bis hoch | Fremde Eingaben aus dem Netz treffen auf C-Code |

Die Vision sieht weder Server noch Dateiimport vor, das Sicherheitsrisiko wäre also auch beim Einbau niedrig. Entscheidend ist der Aufwand, nicht die Sicherheit.

## Nicht geprüft

- Die Projektseiten auf gnu.org und Savannah ließen sich nicht lesen. Release-Datum, Aktivität und Lizenz der Gewichtsdateien sind deshalb nicht direkt bestätigt.
- Quellcode und Commit-Verlauf von GNU Backgammon wurden nicht untersucht.
- Rechtlich verbindlich ist diese Einschätzung nicht, auch nicht zur GPL.
