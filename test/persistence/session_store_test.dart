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
  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async => legalPlays(board, player, dice).first;

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async => false;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async => true;
}

void main() {
  final store = SharedPreferencesSessionStore();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  GameController controllerWith(List<int> rolls) => GameController(
    roller: FixedRoller(rolls),
    engine: ScriptedEngine(),
    store: store,
    computerPause: Duration.zero,
    autoActionDelay: null,
  );

  test('A-208: Partie fortsetzen – erwartet: '
      'Stellung, Spieler am Zug, Würfel, Dopplerwürfel und Stufe '
      'bleiben erhalten', () async {
    final game = Game.at(
      board: Board.fromCounts(
        white: const {6: 3, 5: 2},
        black: const {19: 2},
        whiteBar: 1,
        blackOff: 4,
      ),
      turn: Player.black,
      phase: GamePhase.awaitingPlay,
      dice: const Dice(6, 2),
      cube: const Cube(value: 4, owner: Player.white),
    );
    await store.save(
      Session(
        game: game,
        human: Player.black,
        difficulty: Difficulty.hard,
        gameStats: DiceStats(),
        totalStats: DiceStats(),
      ),
    );

    final loaded = (await store.load())!;

    expect(loaded.game!.board.key, game.board.key);
    expect(loaded.game!.turn, Player.black);
    expect(loaded.game!.phase, GamePhase.awaitingPlay);
    expect(loaded.game!.dice!.first, 6);
    expect(loaded.game!.dice!.second, 2);
    expect(loaded.game!.cube.value, 4);
    expect(loaded.game!.cube.owner, Player.white);
    expect(loaded.human, Player.black);
    expect(loaded.difficulty, Difficulty.hard);
  });

  test(
    'A-208: Neustart der App – erwartet: '
    'Eine zweite App-Sitzung setzt die Partie mit demselben Wurf fort',
    () async {
      final first = controllerWith([3, 1, 6, 5])
        ..startGame(human: Player.white, difficulty: Difficulty.hard);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final second = controllerWith([6, 6]);
      await second.restore();

      expect(second.game!.board.key, first.game!.board.key);
      expect(second.game!.dice!.first, 3);
      expect(second.game!.dice!.second, 1);
      expect(second.human, Player.white);
    },
  );

  test('A-208: Beendete Partie – erwartet: '
      'Nach dem Ende gibt es nichts mehr fortzusetzen, '
      'die Statistik bleibt', () async {
    final first = controllerWith([3, 1])..startGame(human: Player.white);
    first.resign();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = controllerWith([6, 5]);
    await second.restore();

    expect(second.game, isNull);
    expect(second.totalStats.white.faces[2], 1);
  });

  test('A-208: Beschädigter Stand – erwartet: '
      'Die App startet ohne Partie, statt abzustürzen', () async {
    SharedPreferences.setMockInitialValues({'session.v1': '{kaputt'});

    expect(await store.load(), isNull);
  });

  test(
    'A-209: Einstellungen – erwartet: '
    'Farbe und Stufe gelten ab der nächsten Partie und bleiben gespeichert',
    () async {
      final first = controllerWith([3, 1])
        ..startGame(human: Player.white, difficulty: Difficulty.easy);

      first.updateSettings(human: Player.black, difficulty: Difficulty.hard);
      expect(first.human, Player.white);

      first.restart();
      expect(first.human, Player.black);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final second = controllerWith([3, 1]);
      await second.restore();

      expect(second.preferredHuman, Player.black);
      expect(second.difficulty, Difficulty.hard);
    },
  );

  group('Wartezeit:', () {
    test('A-113: Standard – erwartet: '
        'Ohne Einstellung beträgt die Wartezeit 3 Sekunden', () {
      expect(GameController().autoActionDelay, const Duration(seconds: 3));
    });

    test(
      'A-113: Wartezeit speichern – erwartet: '
      'Die gewählte Zeit und das Ausschalten bleiben nach einem Neustart',
      () async {
        final first = controllerWith([3, 1])
          ..updateAutoDelay(const Duration(seconds: 10));
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final second = controllerWith([3, 1]);
        await second.restore();
        expect(second.autoActionDelay, const Duration(seconds: 10));

        first.updateAutoDelay(null);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final third = controllerWith([3, 1]);
        await third.restore();

        expect(third.autoActionDelay, isNull);
      },
    );

    test('A-113: Älterer Spielstand – erwartet: '
        'Ein Stand ohne Wartezeit nutzt den Standard', () {
      final session = Session.fromJson({
        'game': null,
        'human': null,
        'difficulty': 'medium',
        'preferredHuman': null,
        'preferredDifficulty': null,
        'gameStats': DiceStats().toJson(),
        'totalStats': DiceStats().toJson(),
      });

      expect(session.autoDelaySeconds, 3);
    });

    test(
      'A-113: Ausgeschaltet – erwartet: '
      'Ohne Wartezeit bleibt der gesetzte Zug stehen, bis er beendet wird',
      () async {
        final controller = controllerWith([3, 1, 5, 2])
          ..startGame(human: Player.white);

        controller
          ..tap(8)
          ..tap(5)
          ..tap(6)
          ..tap(5);
        await Future<void>.delayed(const Duration(milliseconds: 40));

        expect(controller.canConfirm, isTrue);
        expect(controller.game!.turn, Player.white);
      },
    );

    test('A-113: Während des Countdowns ausschalten – erwartet: '
        'Der laufende Countdown stoppt sofort', () async {
      final controller = GameController(
        roller: FixedRoller([3, 1, 5, 2]),
        engine: ScriptedEngine(),
        computerPause: Duration.zero,
        autoActionDelay: const Duration(milliseconds: 30),
      )..startGame(human: Player.white);

      controller
        ..tap(8)
        ..tap(5)
        ..tap(6)
        ..tap(5)
        ..updateAutoDelay(null);
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(controller.game!.turn, Player.white);
      controller.dispose();
    });
  });

  group('Würfelstatistik:', () {
    test('A-502: Eröffnung – erwartet: '
        'Jeder Spieler bekommt seinen einen Würfel, ohne Wurf und Pasch', () {
      final stats = DiceStats()..addOpening(const Dice(3, 5));

      expect(stats.white.faces[2], 1);
      expect(stats.black.faces[4], 1);
      expect(stats.white.rolls, 0);
    });

    test('A-502: Normaler Wurf – erwartet: '
        'Beide Würfel und der Pasch werden dem richtigen Spieler gezählt', () {
      final stats = DiceStats()
        ..addRoll(Player.black, const Dice(4, 4))
        ..addRoll(Player.black, const Dice(2, 6));

      expect(stats.black.rolls, 2);
      expect(stats.black.doubles, 1);
      expect(stats.black.faces[3], 2);
      expect(stats.black.dice, 4);
      expect(stats.white.dice, 0);
    });

    test(
      'A-502: Partie und gesamt – erwartet: '
      'Eine neue Partie leert die Partie-Statistik, nicht die Gesamtzahl',
      () {
        final controller = controllerWith([3, 1, 2, 4])
          ..startGame()
          ..startGame();

        expect(controller.gameStats.white.dice, 1);
        expect(controller.gameStats.white.faces[1], 1);
        expect(controller.totalStats.white.dice, 2);
      },
    );

    test('A-502: Auch der Computer zählt – erwartet: '
        'Die Würfe des Computers landen in der Statistik', () async {
      final controller = controllerWith([3, 1, 6, 5])
        ..startGame(human: Player.white);

      controller
        ..tap(8)
        ..tap(5)
        ..tap(6)
        ..tap(5)
        ..confirm();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(controller.gameStats.black.rolls, 1);
    });
  });
}
