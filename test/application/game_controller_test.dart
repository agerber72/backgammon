import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedRoller implements DiceRoller {
  FixedRoller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++];
}

/// White opens with 3 and 1.
GameController opened() =>
    GameController(roller: FixedRoller([3, 1, 6, 5]))..startGame();

void main() {
  test('A-201: Partie starten – erwartet: '
      'Nach dem Start ist der Spieler mit der höheren Zahl am Zug', () {
    final controller = opened();

    expect(controller.game!.turn, Player.white);
    expect(controller.game!.phase, GamePhase.awaitingPlay);
  });

  test('A-202: Erlaubte Züge anzeigen – erwartet: '
      'Ein gewählter Stein zeigt genau seine möglichen Ziele', () {
    final controller = opened();

    controller.tap(8);

    expect(controller.selected, 8);
    expect(controller.targets, {5, 7, 4});
  });

  test('A-202: Gesperrter Stein – erwartet: '
      'Ein Stein ohne Zug lässt sich nicht auswählen', () {
    final controller = GameController(
      game: Game.at(
        board: Board.fromCounts(
          white: const {13: 2, 6: 2},
          black: const {10: 2, 3: 2, 12: 2},
        ),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 1),
      ),
    );

    controller.tap(13);

    expect(controller.selected, isNull);
  });

  group('Stein auf der Bar:', () {
    /// White has a checker on the bar; black waits on 1 to 5.
    GameController hit() => GameController(
      roller: FixedRoller([3, 1]),
      game: Game.at(
        board: Board.fromCounts(
          white: const {13: 5, 6: 5, 8: 3, 24: 1},
          black: const {1: 2, 12: 5, 17: 3, 19: 5},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
      autoActionDelay: null,
    );

    test('A-217: Einsetzen – erwartet: '
        'Nach dem Wurf ist der Stein auf der Bar gewählt und zeigt seine Ziele, '
        'ohne dass man ihn antippt', () {
      final controller = hit()..roll();

      expect(controller.selected, 25);
      expect(controller.targets, {22, 24, 21});
    });

    test('A-217: Erneut antippen – erwartet: '
        'Ein Tippen auf den einzigen ziehbaren Stein wählt ihn nicht ab', () {
      final controller = hit()
        ..roll()
        ..tap(25);

      expect(controller.selected, 25);
    });

    test('A-217: Mehrere Steine ziehbar – erwartet: '
        'Ohne Stein auf der Bar ist zu Beginn kein Stein gewählt', () {
      final controller = opened();

      expect(controller.selected, isNull);
    });
  });

  test('A-203: Zug ausführen – erwartet: '
      'Tippen auf ein Ziel bewegt den Stein', () {
    final controller = opened();

    controller
      ..tap(8)
      ..tap(5);

    expect(controller.board.count(Player.white, 8), 2);
    expect(controller.board.count(Player.white, 5), 1);
    expect(controller.hasPendingSteps, isTrue);
  });

  test('A-203: Zug beenden – erwartet: '
      'Erst nach beiden Würfeln lässt sich der Zug beenden, '
      'danach ist der Gegner dran', () {
    final controller = opened();

    controller
      ..tap(8)
      ..tap(5);
    expect(controller.canConfirm, isFalse);

    controller
      ..tap(6)
      ..tap(5);
    expect(controller.canConfirm, isTrue);

    controller.confirm();
    expect(controller.game!.turn, Player.black);
    expect(controller.game!.phase, GamePhase.awaitingRoll);
    expect(controller.game!.board.count(Player.white, 5), 2);
  });

  test('A-204: Zug zurücknehmen – erwartet: '
      'Bis zur Bestätigung stellt Zurücknehmen die Ausgangslage her', () {
    final controller = opened();
    final before = controller.board.key;

    controller
      ..tap(8)
      ..tap(5)
      ..undo();

    expect(controller.board.key, before);
    expect(controller.hasPendingSteps, isFalse);
  });

  test('A-107: Kein Zug möglich – erwartet: '
      'Die Oberfläche bietet Weiter an und überspringt den Zug', () {
    final controller = GameController(
      game: Game.at(
        board: Board.fromCounts(
          white: const {13: 5},
          black: const {22: 2, 19: 2},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 6),
      ),
    );

    expect(controller.mustPass, isTrue);
    controller.pass();

    expect(controller.game!.turn, Player.black);
  });

  test('A-110: Doppeln – erwartet: '
      'Nach dem Annehmen steht der Würfel auf 2 beim Gegner', () {
    final controller = GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );

    controller
      ..offerDouble()
      ..acceptDouble();

    expect(controller.game!.cube.value, 2);
    expect(controller.game!.cube.owner, Player.black);
  });

  group('Kombinierter Zug:', () {
    GameController playing(Board board, Dice dice) => GameController(
      game: Game.at(
        board: board,
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: dice,
      ),
    );

    test('A-215: Beide Würfel in einem Zug – erwartet: '
        'Ein Tipp auf das Summenziel setzt zwei Einzelzüge', () {
      final controller = playing(Board.start(), const Dice(5, 1));

      controller
        ..tap(13)
        ..tap(7);

      expect(controller.board.count(Player.white, 7), 1);
      expect(controller.canConfirm, isTrue);
    });

    test('A-215: Zurücknehmen einzeln – erwartet: '
        'Der kombinierte Zug wird in zwei Schritten zurückgenommen', () {
      final controller = playing(Board.start(), const Dice(5, 1));
      final start = controller.board.key;

      controller
        ..tap(13)
        ..tap(7)
        ..undo();

      expect(controller.board.count(Player.white, 7), 0);
      expect(controller.hasPendingSteps, isTrue);

      controller.undo();

      expect(controller.board.key, start);
      expect(controller.hasPendingSteps, isFalse);
    });

    test('A-215: Pasch – erwartet: '
        'Nach zwei gezogenen Dreiern bietet der Stein noch 1× und 2× an', () {
      final controller = playing(
        Board.fromCounts(white: const {20: 1, 19: 1}),
        const Dice(3, 3),
      );

      controller
        ..tap(20)
        ..tap(14);
      controller.tap(14);

      expect(controller.targets, {11, 8});
    });
  });
}
