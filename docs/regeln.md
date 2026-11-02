# Backgammon-Regeln

Stand: 2026-11-02 · Quelle: [bkgm.com, How to Play](https://bkgm.com/rules.html)

Diese Datei legt fest, welche Regeln die App umsetzt. Die Nummern verweisen auf die [Anforderungen](roadmap-und-anforderungen.md).

## Brett und Aufstellung (`A-102`)

- Das Brett hat 24 Zungen, die Bar und das Ablagefach. Jeder Spieler hat 15 Steine.
- Die Zungen sind aus Sicht von Weiß nummeriert. Weiß zieht von 24 nach 1, Schwarz von 1 nach 24.
- Das Heimfeld von Weiß sind die Zungen 1 bis 6, das von Schwarz die Zungen 19 bis 24.
- Weiß beginnt mit 2 Steinen auf 24, 5 auf 13, 3 auf 8 und 5 auf 6.
- Schwarz beginnt gespiegelt mit 2 Steinen auf 1, 5 auf 12, 3 auf 17 und 5 auf 19.

## Eröffnung (`A-103`)

- Jeder Spieler wirft einen Würfel. Die höhere Zahl beginnt und spielt beide Würfel dieses Wurfs.
- Bei gleicher Zahl wird wiederholt.
- Danach wirft jeder Spieler in seinem Zug zwei Würfel.

## Ziehen (`A-104`, `A-105`, `A-106`, `A-107`)

- Jeder Würfel ist ein eigener Zug. Ein Stein darf beide Würfel nacheinander nutzen, wenn auch der Zwischenpunkt offen ist.
- Ein Stein darf nur auf eine offene Zunge ziehen: Dort stehen höchstens ein gegnerischer Stein.
- Ein einzelner gegnerischer Stein ist ein Blot. Wer auf ihm landet, schlägt ihn, und er kommt auf die Bar.
- Mit Steinen auf der Bar muss zuerst eingesetzt werden, im gegnerischen Heimfeld auf der Zunge des Würfels. Solange das nicht geht, ist kein anderer Zug erlaubt.
- Ein Pasch ergibt vier Züge dieser Zahl.

## Zugpflicht (`A-107`)

- Beide Würfel müssen gespielt werden, wenn das regelkonform möglich ist.
- Lässt sich nur einer der Würfel spielen, muss dieser gespielt werden.
- Lässt sich jeder einzeln, aber nicht beide spielen, muss der höhere gespielt werden.
- Bei einem Pasch werden so viele Züge gespielt wie möglich.
- Ohne möglichen Zug verfällt der Zug.

## Auswürfeln (`A-108`)

- Auswürfeln ist erst erlaubt, wenn alle 15 eigenen Steine im Heimfeld oder schon draußen sind. Ein geschlagener Stein muss erst wieder zurück.
- Ein Würfel nimmt einen Stein von der passenden Zunge.
- Steht dort keiner, muss mit diesem Würfel ein Stein von einer höheren Zunge ziehen.
- Steht auch auf höheren Zungen keiner, wird der Stein von der höchsten besetzten Zunge genommen.
- Auswürfeln ist nicht Pflicht, wenn ein anderer Zug möglich ist.

## Partieende und Wertung (`A-109`)

Wer zuerst alle 15 Steine ausgewürfelt hat, gewinnt.

| Art | Bedingung beim Verlierer | Wert |
| --- | --- | --- |
| Sieg | Mindestens ein Stein ist ausgewürfelt | 1 × Würfelwert |
| Gammon | Kein Stein ausgewürfelt | 2 × Würfelwert |
| Backgammon | Kein Stein ausgewürfelt, und ein Stein steht auf der Bar oder im Heimfeld des Siegers | 3 × Würfelwert |

## Dopplerwürfel (`A-110`)

- Die Partie beginnt mit dem Wert 1, und der Würfel gehört niemandem.
- Nur wer am Zug ist, darf vor seinem Wurf doppeln. Das erste Doppeln darf jeder, danach nur der Besitzer.
- Der Gegner nimmt an, dann verdoppelt sich der Wert und er wird Besitzer. Oder er lehnt ab und verliert sofort den bisherigen Wert.
- Der Würfel ist mit 64 ausgereizt. Die Quelle kennt keine Obergrenze, der echte Würfel endet aber bei 64.

## Nicht in Version 1 (`A-111`)

Die Zusatzregeln Jacoby, Beaver und automatisches Doppeln gelten nicht. Sie kommen in Version 3 als Einstellung. Gammon und Backgammon zählen deshalb auch ohne gedrehten Dopplerwürfel.
