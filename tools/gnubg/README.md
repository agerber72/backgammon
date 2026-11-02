# GNU Backgammon als Testwerkzeug

GNU Backgammon 1.08.003 dient nur während der Entwicklung als Referenz für Regeln, Zugbewertungen und Coach-Tipps. Es wird nicht mit der App ausgeliefert und ist kein Teil des Dart-Codes.

## Einrichtung

```powershell
./tools/gnubg/setup.ps1
```

Das Skript lädt den offiziellen Installer von ftp.gnu.org, prüft den SHA-256-Wert und installiert nach `tools/gnubg/app/`. Dieser Ordner und `tools/gnubg/.download/` werden von Git ignoriert. Die GPG-Signatur des Installers (Maintainer Philippe Michel) wurde beim Festlegen des SHA-256-Werts einmalig geprüft.

## Nutzung

```powershell
./tools/gnubg/hint.ps1 -PositionId 4HPwATDgc/ABMA -Die1 3 -Die2 1 -Plies 2
```

`4HPwATDgc/ABMA` ist die Startstellung. Die Ausgabe nennt die besten Züge mit Equity und dem Abstand zum besten Zug, danach die Wahrscheinlichkeiten für Sieg, Gammon und Backgammon, jeweils für beide Seiten. `-MaxMoves` legt fest, wie viele Kandidaten bewertet werden (Standard: 10).

Was man beim Auswerten wissen muss:

- Die Equity ist **ohne Dopplerwürfel** (cubeless) berechnet. Sie weicht deshalb von den Werten in `hint` ab, die den Würfel einrechnen.
- Der Befehl `hint` von gnubg bleibt in diesem Windows-Build unabhängig von den Einstellungen bei 0-ply. Darum spielt [hint.py](hint.py) jeden Kandidaten und bewertet die Folgestellung per `evaluate` in der gewünschten Tiefe.
- Die Kandidaten wählt `hint` weiterhin in 0-ply aus. Ein Zug außerhalb der ersten `-MaxMoves` wird nicht betrachtet.
- `findbestmove` der Python-Schnittstelle scheint die Tiefe zu ignorieren und wird daher nicht verwendet.

## Referenzdaten für die Tests

```powershell
./tools/gnubg/update_reference.ps1
```

Das Skript spielt Zufallspartien mit der eigenen Spiellogik und lässt GNU Backgammon zu jeder ausgewählten Stellung alle erlaubten Züge berechnen. Das Ergebnis liegt in `test/fixtures/gnubg_legal_plays.json` und wird committet, damit die Tests auch ohne GNU Backgammon laufen.

Neben einer allgemeinen Stichprobe sucht das Skript gezielt seltene Fälle: Stellungen beim Auswürfeln und Stellungen, in denen nur der höhere Würfel gespielt werden darf. Ohne diese Suche kam die zweite Regel in fast 1000 Stellungen nicht vor.

Die Referenz prüft nur die erlaubten Züge. Wertung und Dopplerwürfel sind nicht dagegen geprüft, dafür gibt es eigene Tests aus [docs/regeln.md](../../docs/regeln.md).

## Lizenz

GNU Backgammon steht unter der GPL, die App unter GPL-3.0. Ein Einbau wäre daher nicht grundsätzlich ausgeschlossen, ist aber nicht geplant: Es bleibt ein Testwerkzeug. Vor einem Einbau wären die Lizenzen von Engine und Gewichtsdateien im Detail zu prüfen.

## Entfernen

`tools/gnubg/app/unins000.exe` ausführen. Der Installer trägt das Programm in die Windows-Liste der installierten Programme ein.
