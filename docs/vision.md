# Backgammon-App: Vision

Stand: 2026-11-02

## Vision

Die App macht Backgammon einfach spielbar und bringt es Einsteigern später auch bei, kostenlos und ohne Werbung.

- **Version 1, einfach spielen:** Man startet die App und spielt sofort eine vollständige Partie gegen den Computer.
- **Version 2, verstehen:** Die App erklärt wichtige Züge in verständlicher Sprache.

Das Projekt ist ein Hobby und ein Portfolio-Stück. Erfolg heißt deshalb nicht Umsatz. In Version 1 heißt Erfolg: Das Spiel läuft regelkonform und angenehm auf Android, Windows und im Web, mit sauberem Flutter-Handwerk und getesteter Spiellogik. Ab Version 2 kommt dazu: Ein Einsteiger versteht nach wenigen Partien, warum er gewinnt oder verliert.

## Zielgruppe

Die Hauptzielgruppe sind Menschen, die Backgammon nur selten spielen und ein paar Regeln kennen, aber nicht alle. Genau das ist auch dein eigener Stand, du bist also der erste echte Testnutzer.

- **Hauptzielgruppe:** Einsteiger und Gelegenheitsspieler, die in Version 1 unkompliziert spielen und ab Version 2 auch verstehen wollen.
- **Nebenzielgruppe:** Paare, Freunde und Familien, die am selben Gerät spielen und Regelfragen schnell klären wollen.
- **Nicht die Zielgruppe:** Turnierspieler, die Equity-Werte und Rollouts suchen. Sie sind bei Backgammon Galaxy oder XG besser aufgehoben.

## Marktbild

Der Markt teilt sich in drei Segmente, und keines davon erklärt Einsteigern konsequent das Warum hinter einem Zug.

| Segment | Beispiele | Stärke | Schwäche |
| --- | --- | --- | --- |
| Gelegenheitsspieler | [Easybrain](https://apppricinglab.com/app/google_play/com.easybrain.backgammon.board.games) (ca. 5 Mio. Installationen), [Zynga Backgammon Plus](https://apppricinglab.com/app/google_play/com.zynga.backgammonplus) (ca. 1 Mio.), Lord of the Board | Reichweite, schnelle Partien | Werbung, In-App-Käufe, wenig Lerneffekt |
| Ambitionierte Spieler | [Backgammon Galaxy](https://appgoblin.info/apps/com.backgammongalaxy.app) (50–80 Tsd.), [Nextgammon](https://nextgammon.com/en/blog/top-10-best-online-backgammon-websites-apps-in-2026), [XG Mobile](https://apps.apple.com/app/id536774050) | Analyse, Ratings, Turniere | Für Einsteiger anspruchsvoll, oft kostenpflichtig |
| Offline gegen KI | [Backgammon NJ](https://backgammon-meister.de/en/best-apps/), [CBG](https://f-droid.org/de/packages/com.clavierhaus.gnubg/) | Starke Gegner, CBG mit Zugbewertung | Richtet sich eher an Kenner |

Die häufigsten Klagen in den gesichteten Stichproben sind gefühlt manipulierte Würfel und zu viel Werbung. Installationszahlen stammen von Drittanbietern und weichen voneinander ab, sie zeigen nur die Größenordnung. Eine Auswertung der Google-Play-Rezensionen steht noch aus.

## USP und Leitprinzipien

Der USP entsteht in zwei Stufen:

- **Version 1:** Einfach spielen, ohne Werbung, Käufe, Münzen und Konto. Das ist noch kein Alleinstellungsmerkmal, aber die Grundlage und schon ein klarer Gegenentwurf zu den großen Gratis-Apps.
- **Version 2:** Ein Coach, der in Alltagssprache erklärt, statt Zahlen zu zeigen. Statt „Equity −0,12“ sagt er: „Du lässt hier einen Blot stehen, den dein Gegner mit 11 von 36 Würfen trifft.“ Hier liegt das eigentliche Alleinstellungsmerkmal.

Diese Prinzipien entscheiden, wenn zwei Ideen konkurrieren:

1. **Einfach spielen:** In Version 1 zählt nur, dass eine Partie ohne Hürden startet und Spaß macht.
2. **Verstehen vor Gewinnen, ab Version 2:** Dann muss jede neue Funktion dem Spieler helfen, das Spiel besser zu begreifen.
3. **Einfach vor vollständig:** Profi-Funktionen bleiben außen vor. Ab Version 2 werden Fachbegriffe beim ersten Auftreten erklärt.
4. **Nachprüfbar fair:** Die Würfel lassen sich kontrollieren. In Version 1 gibt es eine sichtbare Statistik, später wird die Würfelfolge vor der Partie festgelegt und danach offengelegt.
5. **Kostenlos und frei von Ablenkung:** Keine Werbung, keine Käufe, keine Münzen, kein Konto.
6. **Offline zuerst:** Das Spiel braucht weder Server noch Internet.

## Umfang

Version 1 ist eine vollständige Partie gegen den Computer zum einfachen Spielen. Das Lernen kommt mit Version 2, alles andere später oder gar nicht.

| Bereich | Version 1 | Version 2 | Später | Bewusst nicht |
| --- | --- | --- | --- | --- |
| Spiel | Vollständige Regeln, Einzelpartie mit Dopplerwürfel, gegen Computer in mehreren Stufen, erlaubte Züge anzeigen, Zug zurücknehmen | | Zwei Spieler am selben Gerät (Version 2 oder 3), Matches auf mehrere Punkte, Zusatzregeln als Einstellung (Version 3) | Live-Multiplayer, Echtgeld |
| Lernen | | Coach bewertet und erklärt Züge, Regel-Nachschlagewerk | Interaktives Tutorial, Tagesaufgaben, Partie nachträglich durchgehen | Equity-Tabellen, Rollouts |
| Fairness | Faire Würfel, Würfelstatistik | | Prüfbare Würfelfolge offenlegen | Zertifizierung |
| Produkt | Android, Windows, Web, Oberfläche auf Deutsch, Mehrsprachigkeit vorbereitet, lokale Speicherung, 3D-Brett mit Ansicht für Schwarz und Weiß, Code öffentlich auf GitHub unter GPL-3.0 | | Englisch und weitere Sprachen, weitere Brett-Designs | Konto, Werbung, Käufe, Münzen |

Mehrsprachigkeit vorbereitet heißt: Alle Texte liegen von Anfang an in Sprachdateien statt im Code, und das Layout verträgt längere Texte. Eine neue Sprache braucht dann nur noch eine Übersetzung.

## Aussehen

Die App soll aussehen wie ein Turnierbrett in 3D: sachlich und hochwertig, mit Brett, 24 Zungen, 30 Steinen, Würfeln, Würfelbechern und Dopplerwürfel.

Eine verbindliche Normgröße für Turnierbretter wurde nicht gefunden. Die [USBGF-Regeln](https://usbgf.org/wp-content/uploads/2023/06/USBGF-rules-2024_proposed_public_comment.pdf) nennen laut Recherche nur die Ausstattung, die Maße einzelner Bretter sind Herstellerangaben. Das Ziel ist deshalb die vertraute Turnier-Anmutung, keine maßstabsgetreue Kopie.

Das Brett hat genau zwei Ansichten: aus Sicht von Schwarz und aus Sicht von Weiß. Der Spieler sieht es von seiner Seite und kann um 180° wechseln. Ein freies Drehen gibt es nicht.

Das Brett wird per Skript mit Blender in 3D vorgerendert, einmal je Ansicht, aus einem festen, leicht geneigten Blickwinkel. Steine, Würfel und Dopplerwürfel liegen als gerenderte Bilder darüber, ihre Position berechnet die App aus dem Spielstand. Der Wechsel der Ansicht bekommt einen kurzen Übergang. So wirkt das Brett hochwertig und läuft stabil auf allen drei Plattformen.

Echtes 3D mit [flutter_scene](https://pub.dev/documentation/flutter_scene/0.21.0/) ist nicht nötig. Es setzt laut Recherche den Flutter-Master-Kanal voraus, das Projekt läuft auf dem Stable-Kanal.

## Risiken und technische Leitplanken

Für Version 1 ist das größte Risiko, dass Regelfehler nicht auffallen, weil im Projekt bisher das Spielwissen fehlt. Ab Version 2 kommt der Coach dazu, denn seine Erklärungen müssen stimmen.

| Risiko | Auswirkung | Vorschlag |
| --- | --- | --- |
| Wenig eigenes Backgammon-Wissen | Regelfehler oder falsche Tipps fallen nicht auf | Regeln aus einer belastbaren Quelle festhalten und vollständig testen, Züge gegen GNU Backgammon prüfen, Strategietipps von erfahrenen Spielern prüfen lassen |
| Engine-Wahl | Bestimmt Stärke und Plattformen | Mit eigener Dart-Bewertung starten, hinter einer austauschbaren Schnittstelle; GNU Backgammon bleibt [Testwerkzeug](../tools/gnubg/README.md) |
| Einbau von [GNU Backgammon](https://f-droid.org/de/packages/com.clavierhaus.gnubg/) | Lizenzrechtlich möglich, weil die App selbst unter GPL-3.0 steht, aber auf Web und Windows aufwändig | Vorerst nur als Testwerkzeug nutzen |
| Kommerzielle Nutzung durch Dritte | GPL-3.0 erlaubt sie ohne Zahlung, verlangt aber offenen Code und Nennung der Urheber | Bewusst akzeptiert |
| Erklärungen sind unzutreffend | Der Coach verliert Vertrauen | Erklärungen aus berechenbaren Merkmalen ableiten: Blots, Trefferchancen, Pip-Stand, Punkte, Primes |
| 3D-Grafik | Die gerenderten Bilder von Brett, Steinen und Würfeln müssen perspektivisch exakt zusammenpassen | Alle Bilder aus demselben Blender-Skript erzeugen und früh einen Prototyp mit beiden Ansichten bauen |
| Dopplerwürfel in Version 1 | Mehr Regeln, und die Computer-Gegner müssen Würfel-Entscheidungen treffen | Früh einplanen; unser Skript für GNU Backgammon deckt Würfel-Entscheidungen noch nicht ab und muss dafür erweitert werden |
| Backgammon Galaxy plant laut Eintrag einen KI-Tutor | Der Vorsprung schrumpft | Akzeptabel, weil das Projekt nicht vom Markterfolg abhängt |

Die Spiellogik bleibt reines Dart ohne Flutter-Abhängigkeit. So läuft sie auf allen drei Plattformen gleich und ist vollständig testbar. Auch für den Coach in Version 2 braucht es weder Server noch laufende Kosten: Er arbeitet regelbasiert und ohne Sprachmodell. Die Spiellogik gibt schon in Version 1 keine fertigen Texte aus, damit Mehrsprachigkeit und Coach darauf aufbauen können.

## Offene Fragen

Sobald diese Fragen entschieden sind, leiten wir daraus die Anforderungen ab.

Für Version 1:

Für Version 1 sind alle Fragen entschieden.

Für Version 2:

- [ ] Soll der Coach während der Partie automatisch eingreifen oder nur auf Wunsch?
- [ ] Wer kann als erfahrener Spieler die Tipps des Coachs prüfen?
