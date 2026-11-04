import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/dice_stats.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:backgammon/persistence/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixedRoller implements DiceRoller {
  FixedRoller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++ % values.length];
}

class ScriptedEngine implements Engine {
  ScriptedEngine({this.doubles = false, this.accepts = true});

  final bool doubles;
  final bool accepts;

  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async => legalPlays(board, player, dice).first;

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async =>
      doubles && game.canDouble;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async => accepts;
}

GameController controllerWith(Engine engine, List<int> rolls) => GameController(
  roller: FixedRoller(rolls),
  engine: engine,
  computerPause: Duration.zero,
);

/// Gives the computer time for all its pauses.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

void main() {
  test('A-404: Computer beginnt – erwartet: '
      'Gewinnt der Computer die Eröffnung, zieht er selbst, '
      'dann ist der Spieler dran', () async {
    final controller = controllerWith(ScriptedEngine(), [1, 3]);

    controller.startGame(human: Player.white);
    await settle();

    expect(controller.game!.turn, Player.white);
    expect(controller.game!.phase, GamePhase.awaitingRoll);
    expect(controller.isHumanTurn, isTrue);
  });

  test('A-202: Während der Computer zieht – erwartet: '
      'Der Spieler kann keinen Stein wählen', () {
    final controller = GameController(
      roller: FixedRoller([1, 3]),
      engine: ScriptedEngine(),
      computerPause: const Duration(milliseconds: 500),
    );

    controller.startGame(human: Player.white);
    controller.tap(6);

    expect(controller.isHumanTurn, isFalse);
    expect(controller.selected, isNull);
    controller.dispose();
  });

  test('A-404: Computer doppelt – erwartet: '
      'Der Spieler muss antworten, und nach dem Annehmen zieht der Computer '
      'weiter', () async {
    final controller = controllerWith(ScriptedEngine(doubles: true), [
      3,
      1,
      5,
      2,
    ]);
    controller.startGame(human: Player.white);
    controller
      ..tap(8)
      ..tap(5)
      ..tap(6)
      ..tap(5)
      ..confirm();
    await settle();

    expect(controller.game!.phase, GamePhase.awaitingDoubleResponse);
    expect(controller.isHumanTurn, isTrue);

    controller.acceptDouble();
    await settle();

    expect(controller.game!.cube.value, 2);
    expect(controller.game!.cube.owner, Player.white);
    expect(controller.game!.turn, Player.white);
  });

  test('A-404: Spieler doppelt – erwartet: '
      'Lehnt der Computer ab, gewinnt der Spieler sofort', () async {
    final controller = GameController(
      engine: ScriptedEngine(accepts: false),
      computerPause: Duration.zero,
      roller: FixedRoller([3, 1, 5, 2]),
    );
    controller.startGame(human: Player.black);
    await settle();

    controller.offerDouble();
    await settle();

    expect(controller.game!.result!.winner, Player.black);
    expect(controller.game!.result!.points, 1);
  });

  test('A-404: Neue Partie – erwartet: '
      'Eine neue Partie behält Farbe und Spielstärke', () async {
    final controller = controllerWith(ScriptedEngine(accepts: false), [
      3,
      1,
      5,
      2,
    ]);
    controller.startGame(human: Player.black, difficulty: Difficulty.hard);
    await settle();
    controller.offerDouble();
    await settle();

    controller.restart();
    await settle();

    expect(controller.game!.phase, isNot(GamePhase.finished));
  });

  test('A-112: Aufgeben im Zug des Computers – erwartet: '
      'Die Partie endet sofort, und der Computer zieht nicht weiter', () async {
    final controller = GameController(
      roller: FixedRoller([1, 3]),
      engine: ScriptedEngine(),
      computerPause: const Duration(milliseconds: 5),
    );
    controller.startGame(human: Player.white);
    final boardAtResign = controller.board.key;

    controller.resign();
    await settle();

    expect(controller.game!.result!.winner, Player.black);
    expect(controller.board.key, boardAtResign);
    expect(controller.canResign, isFalse);
  });

  group('Automatisch weiter:', () {
    GameController timed() => GameController(
      roller: FixedRoller([3, 1, 5, 2]),
      engine: ScriptedEngine(),
      computerPause: const Duration(seconds: 5),
      autoActionDelay: const Duration(milliseconds: 20),
    );

    test('A-113: Zug nicht beendet – erwartet: '
        'Nach Ablauf der Zeit endet der gesetzte Zug von selbst', () async {
      final controller = timed()..startGame(human: Player.white);

      controller
        ..tap(8)
        ..tap(5)
        ..tap(6)
        ..tap(5);
      expect(controller.game!.turn, Player.white);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.game!.turn, Player.black);
      expect(controller.game!.board.count(Player.white, 5), 2);
      controller.dispose();
    });

    test('A-113: Zurücknehmen – erwartet: '
        'Wer zurücknimmt, stoppt das automatische Zugende', () async {
      final controller = timed()..startGame(human: Player.white);

      controller
        ..tap(8)
        ..tap(5)
        ..tap(6)
        ..tap(5)
        ..undo();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.game!.turn, Player.white);
      expect(controller.hasPendingSteps, isTrue);
      controller.dispose();
    });

    test('A-113: Halber Zug – erwartet: '
        'Solange noch ein Würfel offen ist, läuft keine Zeit', () async {
      final controller = timed()..startGame(human: Player.white);

      controller
        ..tap(8)
        ..tap(5);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.game!.turn, Player.white);
      expect(controller.hasPendingSteps, isTrue);
      controller.dispose();
    });
  });

  group('Kein Zug möglich:', () {
    /// White has a checker on the bar and cannot enter with 6-6.
    GameController blocked(Duration? delay) => GameController(
      roller: FixedRoller([6, 6]),
      game: Game.at(
        board: Board.fromCounts(
          white: const {24: 1},
          black: const {18: 2, 19: 2, 20: 2, 21: 2, 22: 2, 23: 2},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
      autoActionDelay: delay,
    );

    test(
      'A-117: Nach der Wartezeit – erwartet: '
      'Ist nach dem Wurf kein Zug möglich, geht das Spiel von selbst weiter',
      () async {
        final controller = blocked(const Duration(milliseconds: 20))..roll();
        expect(controller.mustPass, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(controller.game!.turn, Player.black);
        controller.dispose();
      },
    );

    test(
      'A-117: Wartezeit ausgeschaltet – erwartet: '
      'Ohne Wartezeit bleibt Kein Zug möglich stehen, bis man es drückt',
      () async {
        final controller = blocked(null)..roll();

        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(controller.mustPass, isTrue);
        controller.pass();
        expect(controller.game!.turn, Player.black);
        controller.dispose();
      },
    );
  });

  group('Automatisch würfeln:', () {
    /// Computer opens and has finished after the pauses.
    Future<GameController> afterComputer({bool doubles = false}) async {
      final controller = GameController(
        roller: FixedRoller([1, 3, 5, 2]),
        engine: ScriptedEngine(),
        computerPause: Duration.zero,
        autoActionDelay: const Duration(milliseconds: 250),
      )..startGame(human: Player.white);
      await settle();
      return controller;
    }

    test('A-116: Nach dem Computer – erwartet: '
        'Ohne Eingabe wird nach Ablauf der Zeit gewürfelt', () async {
      final controller = await afterComputer();
      expect(controller.game!.phase, GamePhase.awaitingRoll);

      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(controller.game!.phase, GamePhase.awaitingPlay);
      expect(controller.game!.turn, Player.white);
      controller.dispose();
    });

    test('A-116: Selbst würfeln – erwartet: '
        'Wer vorher würfelt, würfelt nur einmal', () async {
      final controller = await afterComputer();
      controller.roll();
      final dice = controller.game!.dice;

      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(identical(controller.game!.dice, dice), isTrue);
      controller.dispose();
    });

    test('A-116: Doppeln in der Wartezeit – erwartet: '
        'Doppeln stoppt das automatische Würfeln', () async {
      final controller = GameController(
        roller: FixedRoller([1, 3, 5, 2]),
        engine: ScriptedEngine(),
        computerPause: const Duration(milliseconds: 5),
        autoActionDelay: const Duration(milliseconds: 80),
      )..startGame(human: Player.white);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(controller.game!.phase, GamePhase.awaitingRoll);

      controller.offerDouble();
      expect(controller.game!.phase, GamePhase.awaitingDoubleResponse);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(controller.game!.cube.value, 2);
      expect(controller.game!.phase, GamePhase.awaitingRoll);
      controller.dispose();
    });
  });

  group('Zu Ende spielen:', () {
    final race = Board.fromCounts(
      white: const {6: 5, 5: 5, 4: 5},
      black: const {19: 5, 20: 5, 21: 5},
    );
    Game raceGame() =>
        Game.at(board: race, turn: Player.white, phase: GamePhase.awaitingRoll);

    test('A-114: Kontakt erkennen – erwartet: '
        'Zu Beginn besteht Kontakt, im reinen Rennen nicht', () {
      expect(Board.start().hasContact, isTrue);
      expect(race.hasContact, isFalse);
    });

    test('A-114: Noch Kontakt – erwartet: '
        'Solange Steine sich treffen können, gibt es den Knopf nicht', () {
      final controller = GameController(
        game: Game.at(
          board: Board.start(),
          turn: Player.white,
          phase: GamePhase.awaitingRoll,
        ),
      );

      expect(controller.canAutoFinish, isFalse);
    });

    test('A-114: Rennen zu Ende spielen – erwartet: '
        'Die Partie läuft ohne Eingabe bis zum Ergebnis', () async {
      final controller = GameController(
        roller: FixedRoller([6, 5, 4, 3, 2, 1, 5, 5]),
        engine: HeuristicEngine(),
        game: raceGame(),
        autoFinishPause: Duration.zero,
      );

      expect(controller.canAutoFinish, isTrue);
      controller.autoFinish();
      for (var i = 0; i < 400 && controller.game!.result == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }

      expect(controller.game!.phase, GamePhase.finished);
      expect(controller.game!.result!.points, greaterThanOrEqualTo(1));
    });

    test('A-114: Eigener Zug offen – erwartet: '
        'Der noch nicht beendete Zug wird verworfen, und der Knopf bleibt nutzbar', () {
      final controller = GameController(
        roller: FixedRoller([6, 5, 4, 3]),
        engine: ScriptedEngine(),
        game: Game.at(
          board: race,
          turn: Player.white,
          phase: GamePhase.awaitingPlay,
          dice: const Dice(3, 1),
        ),
        autoFinishPause: const Duration(seconds: 5),
      );
      controller
        ..tap(6)
        ..tap(3);
      expect(controller.hasPendingSteps, isTrue);
      expect(controller.canAutoFinish, isTrue);

      controller.autoFinish();

      expect(controller.hasPendingSteps, isFalse);
      expect(controller.board.key, race.key);
      controller.dispose();
    });

    test(
      'A-114: Im Zug des Computers – erwartet: '
      'Der Knopf ist nutzbar, und die Partie läuft bis zum Ende durch',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = SharedPreferencesSessionStore();
        await store.save(
          Session(
            game: Game.at(
              board: race,
              turn: Player.black,
              phase: GamePhase.awaitingRoll,
            ),
            human: Player.white,
            difficulty: Difficulty.medium,
            gameStats: DiceStats(),
            totalStats: DiceStats(),
          ),
        );
        final controller = GameController(
          roller: FixedRoller([6, 5, 4, 3, 2, 1]),
          engine: HeuristicEngine(),
          store: store,
          computerPause: const Duration(milliseconds: 5),
          autoFinishPause: Duration.zero,
        );
        await controller.restore();
        expect(controller.isHumanTurn, isFalse);
        expect(controller.canAutoFinish, isTrue);

        controller.autoFinish();
        while (controller.game!.phase != GamePhase.finished) {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        }

        expect(controller.game!.phase, GamePhase.finished);
        controller.dispose();
      },
    );

    test('A-114: Keine Eingabe beim Abspielen – erwartet: '
        'Während des Abspielens kann niemand einen Stein wählen', () {
      final controller = GameController(
        roller: FixedRoller([6, 5]),
        engine: ScriptedEngine(),
        game: raceGame(),
        autoFinishPause: const Duration(seconds: 5),
      );

      controller.autoFinish();

      expect(controller.isHumanTurn, isFalse);
      expect(controller.canAutoFinish, isFalse);
      controller.dispose();
    });
  });
}
