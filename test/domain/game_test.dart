import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedRoller implements DiceRoller {
  FixedRoller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++];
}

/// White plays its last checker with a 1 from point 1.
Game lastMove({required Board board, Cube cube = const Cube()}) => Game.at(
  board: board,
  turn: Player.white,
  phase: GamePhase.awaitingPlay,
  dice: const Dice(1, 2),
  cube: cube,
);

GameResult finish(Game game) => game.play(game.plays.first).result!;

void main() {
  group('Eröffnung:', () {
    test('A-103: Höherer Würfel beginnt – erwartet: '
        'Weiß wirft 5 gegen 3 und spielt beide Zahlen', () {
      final game = Game.start(FixedRoller([5, 3]));

      expect(game.turn, Player.white);
      expect(game.phase, GamePhase.awaitingPlay);
      expect(game.dice!.moves, [5, 3]);
    });

    test('A-103: Gleiche Zahl – erwartet: '
        'Bei gleichem Wurf wird wiederholt, hier beginnt Schwarz', () {
      final game = Game.start(FixedRoller([4, 4, 2, 6]));

      expect(game.turn, Player.black);
      expect(game.dice!.moves, [2, 6]);
    });
  });

  group('Würfel:', () {
    test('A-501: Faire Würfel – erwartet: '
        'Jede Zahl von 1 bis 6 kommt bei 60000 Würfen etwa gleich oft vor', () {
      final roller = RandomDiceRoller();
      final counts = List.filled(7, 0);
      for (var i = 0; i < 60000; i++) {
        counts[roller.roll()]++;
      }

      expect(counts[0], 0);
      for (final count in counts.skip(1)) {
        expect(count, inInclusiveRange(9500, 10500));
      }
    });
  });

  group('Ablauf:', () {
    test('A-107: Kein Zug möglich – erwartet: '
        'Der Zug verfällt, und der Gegner ist an der Reihe', () {
      final game = Game.at(
        board: Board.fromCounts(
          white: const {13: 5},
          black: const {22: 2, 19: 2},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 6),
      );

      final next = game.pass();

      expect(next.turn, Player.black);
      expect(next.phase, GamePhase.awaitingRoll);
    });

    test('A-104: Unerlaubter Zug – erwartet: '
        'Die Partie lehnt einen Zug ab, den die Regeln nicht erlauben', () {
      final game = Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 1),
      );
      final illegal = Play(const [], Board.fromCounts());

      expect(() => game.play(illegal), throwsArgumentError);
    });
  });

  group('Wertung:', () {
    test('A-109: Einfacher Sieg – erwartet: '
        'Der Verlierer hat einen Stein draußen und zahlt 1 Punkt', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {24: 2},
            blackOff: 13,
          ),
        ),
      );

      expect(result.winner, Player.white);
      expect(result.type, WinType.single);
      expect(result.points, 1);
    });

    test('A-109: Gammon – erwartet: '
        'Ohne ausgewürfelten Stein zahlt der Verlierer 2 Punkte', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {12: 15},
          ),
        ),
      );

      expect(result.type, WinType.gammon);
      expect(result.points, 2);
    });

    test('A-109: Backgammon im Heimfeld – erwartet: '
        'Ein Stein im Heimfeld des Siegers ergibt 3 Punkte', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {3: 1, 12: 14},
          ),
        ),
      );

      expect(result.type, WinType.backgammon);
      expect(result.points, 3);
    });

    test('A-109: Backgammon von der Bar – erwartet: '
        'Ein Stein auf der Bar ergibt ebenfalls 3 Punkte', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {12: 14},
            blackBar: 1,
          ),
        ),
      );

      expect(result.type, WinType.backgammon);
    });

    test('A-111: Ohne Jacoby – erwartet: '
        'Ein Gammon zählt auch ohne gedrehten Dopplerwürfel doppelt', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {12: 15},
          ),
        ),
      );

      expect(result.points, 2);
    });

    test('A-109: Dopplerwürfel in der Wertung – erwartet: '
        'Ein Gammon bei Würfelwert 4 ergibt 8 Punkte', () {
      final result = finish(
        lastMove(
          board: Board.fromCounts(
            white: const {1: 1},
            whiteOff: 14,
            black: const {12: 15},
          ),
          cube: const Cube(value: 4, owner: Player.white),
        ),
      );

      expect(result.points, 8);
    });
  });

  group('Aufgeben:', () {
    test('A-112: Aufgeben – erwartet: '
        'Der Gegner gewinnt sofort den aktuellen Würfelwert', () {
      final game = Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
        cube: const Cube(value: 4, owner: Player.black),
      );

      final result = game.resign(Player.white).result!;

      expect(result.winner, Player.black);
      expect(result.points, 4);
      expect(result.type, WinType.single);
    });

    test('A-112: Beendete Partie – erwartet: '
        'Nach dem Ende kann niemand mehr aufgeben', () {
      final over = Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ).resign(Player.white);

      expect(() => over.resign(Player.black), throwsStateError);
    });
  });

  group('Dopplerwürfel:', () {
    Game beforeRoll({Cube cube = const Cube()}) => Game.at(
      board: Board.start(),
      turn: Player.white,
      phase: GamePhase.awaitingRoll,
      cube: cube,
    );

    test('A-110: Annehmen – erwartet: '
        'Der Wert verdoppelt sich, und der Gegner besitzt den Würfel', () {
      final game = beforeRoll().offerDouble().acceptDouble();

      expect(game.cube.value, 2);
      expect(game.cube.owner, Player.black);
      expect(game.turn, Player.white);
      expect(game.phase, GamePhase.awaitingRoll);
    });

    test('A-110: Ablehnen – erwartet: '
        'Die Partie endet, und der Ablehnende zahlt den bisherigen Wert', () {
      final game = beforeRoll(cube: const Cube(value: 4, owner: Player.white))
          .offerDouble()
          .refuseDouble();

      expect(game.phase, GamePhase.finished);
      expect(game.result!.winner, Player.white);
      expect(game.result!.points, 4);
    });

    test('A-110: Besitz – erwartet: '
        'Wem der Würfel gehört, der darf als Einziger doppeln', () {
      expect(
        beforeRoll(cube: const Cube(value: 2, owner: Player.black)).canDouble,
        isFalse,
      );
      expect(
        beforeRoll(cube: const Cube(value: 2, owner: Player.white)).canDouble,
        isTrue,
      );
    });

    test('A-110: Nur vor dem Wurf – erwartet: '
        'Nach dem Würfeln ist Doppeln nicht mehr erlaubt', () {
      final rolled = beforeRoll().roll(FixedRoller([3, 1]));

      expect(rolled.canDouble, isFalse);
      expect(rolled.offerDouble, throwsStateError);
    });

    test('A-110: Obergrenze – erwartet: '
        'Bei Wert 64 ist kein weiteres Doppeln möglich', () {
      final game = beforeRoll(cube: const Cube(value: 64, owner: Player.white));

      expect(game.canDouble, isFalse);
    });
  });
}
