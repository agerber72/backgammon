import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/dice_stats.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:backgammon/persistence/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Starts the controller with a saved game against the computer.
class MemoryStore implements SessionStore {
  MemoryStore(this.session);

  Session? session;

  @override
  Future<Session?> load() async => session;

  @override
  Future<void> save(Session session) async => this.session = session;
}

/// White, the person, has a single checker left: with 2-1 every order
/// leads to the same board, so the roll allows exactly one move.
Game forcedGame() => Game.at(
  board: Board.fromCounts(
    white: const {20: 1},
    whiteOff: 14,
    black: const {1: 15},
  ),
  turn: Player.white,
  phase: GamePhase.awaitingPlay,
  dice: const Dice(2, 1),
);

/// A clock the test moves forward by hand.
class FakeClock {
  var now = DateTime(2026, 11, 9, 20);
}

Future<GameController> restored(
  Game game, {
  GamePace pace = GamePace.normal,
  bool autoForced = false,
  List<int> rolls = const [3, 1],
  DateTime Function()? clock,
}) async {
  final controller = GameController(
    roller: FixedRoller(rolls),
    engine: ScriptedEngine(),
    computerPause: const Duration(milliseconds: 10),
    clock: clock,
    store: MemoryStore(
      Session(
        game: game,
        human: Player.white,
        gameStats: DiceStats(),
        totalStats: DiceStats(),
        pace: pace,
        autoForced: autoForced,
      ),
    ),
  );
  await controller.restore();
  return controller;
}

void main() {
  test(
    'A-221: Zug ohne Alternative – erwartet: '
    'Lässt der Wurf nur einen Zug zu, endet er sofort ohne Wartezeit',
    () async {
      final controller = await restored(forcedGame());
      expect(controller.game!.plays, hasLength(1));

      controller
        ..tap(20)
        ..tap(17);

      expect(controller.game!.turn, Player.black);
      controller.dispose();
    },
  );

  test(
    'A-221: Ohne Alternative, Tempo Aus – erwartet: '
    'Mit ausgeschaltetem Tempo wartet auch ein Zug ohne Alternative',
    () async {
      final controller = await restored(forcedGame(), pace: GamePace.off);

      controller
        ..tap(20)
        ..tap(17);

      expect(controller.game!.turn, Player.white);
      expect(controller.canConfirm, isTrue);
      controller.dispose();
    },
  );

  test('A-221: Würfeln ohne Doppelrecht – erwartet: '
      'Gehört der Dopplerwürfel dem Computer, würfelt die App nach seinem Zug '
      'gleich, ohne die Wartezeit zum Doppeln', () async {
    final controller = await restored(
      Game.at(
        board: Board.start(),
        turn: Player.black,
        phase: GamePhase.awaitingRoll,
        cube: const Cube(value: 2, owner: Player.black),
      ),
      pace: GamePace.relaxed,
      rolls: const [3, 1, 6, 5],
    );

    await Future<void>.delayed(const Duration(milliseconds: 900));

    expect(controller.game!.turn, Player.white);
    expect(controller.game!.phase, GamePhase.awaitingPlay);
    controller.dispose();
  });

  test('A-222: Countdown sichtbar – erwartet: '
      'Ein gesetzter Zug mit Alternativen zeigt den Countdown zum Zugende, '
      'ein weiterer Tipp startet ihn neu', () async {
    final clock = FakeClock();
    final controller = await restored(
      Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 1),
      ),
      clock: () => clock.now,
    );

    controller
      ..tap(8)
      ..tap(5)
      ..tap(6)
      ..tap(5);
    final first = controller.countdown!;
    expect(first.action, AutoAction.confirm);
    expect(first.duration, const Duration(seconds: 2));

    clock.now = clock.now.add(const Duration(seconds: 1));
    controller.tap(13);

    expect(controller.countdown!.start, clock.now);
    expect(controller.game!.turn, Player.white);
    controller.dispose();
  });

  test('A-222: Countdown endet – erwartet: '
      'Nach dem Zurücknehmen läuft kein Countdown mehr', () async {
    final controller = await restored(
      Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(3, 1),
      ),
    );

    controller
      ..tap(8)
      ..tap(5)
      ..tap(6)
      ..tap(5)
      ..undo();

    expect(controller.countdown, isNull);
    controller.dispose();
  });

  test('A-224: Pflichtzüge selbst setzen – erwartet: '
      'Mit dem Schalter setzt die App den einzigen Zug Stein für Stein und '
      'beendet ihn', () async {
    final controller = await restored(forcedGame(), autoForced: true);
    expect(controller.playingForced, isTrue);
    expect(controller.sources, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Meanwhile the computer has moved, and white waits for its roll.
    expect(controller.game!.board.count(Player.white, 17), 1);
    expect(controller.game!.board.count(Player.white, 20), 0);
    expect(controller.playingForced, isFalse);
    controller.dispose();
  });

  test('A-224: Pflichtzüge ausgeschaltet – erwartet: '
      'Ohne den Schalter wartet der einzige Zug auf den Spieler', () async {
    final controller = await restored(forcedGame());

    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(controller.game!.turn, Player.white);
    expect(controller.sources, {20});
    controller.dispose();
  });

  group('Doppeln vormerken:', () {
    /// The computer, black, is about to roll; white may double later.
    Game computerToRoll() => Game.at(
      board: Board.start(),
      turn: Player.black,
      phase: GamePhase.awaitingRoll,
    );

    test('A-225: Immer sichtbar – erwartet: '
        'Auch während der Computer zieht, darf der Spieler das Doppeln '
        'vormerken; ein zweiter Tipp nimmt es zurück', () async {
      final controller = await restored(
        computerToRoll(),
        pace: GamePace.off,
        rolls: const [3, 1],
      );
      expect(controller.mayDouble, isTrue);

      controller.requestDouble();
      expect(controller.doubleRequested, isTrue);
      controller.requestDouble();
      expect(controller.doubleRequested, isFalse);
      controller.dispose();
    });

    test('A-225: Nachfrage – erwartet: '
        'Ist das Doppeln vorgemerkt, würfelt die App nach dem Computer nicht '
        'von selbst, sondern fragt nach', () async {
      final controller = await restored(
        computerToRoll(),
        pace: GamePace.fast,
        rolls: const [3, 1],
      );
      controller.requestDouble();

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      expect(controller.game!.turn, Player.white);
      expect(controller.game!.phase, GamePhase.awaitingRoll);
      expect(controller.asksToDouble, isTrue);
      expect(controller.countdown, isNull);

      controller.requestDouble();
      expect(controller.game!.phase, GamePhase.awaitingDoubleResponse);
      expect(controller.doubleRequested, isFalse);
      controller.dispose();
    });

    test('A-225: Doch würfeln – erwartet: '
        'Wer bei der Nachfrage würfelt, hat den Wunsch erledigt', () async {
      final controller = await restored(
        computerToRoll(),
        pace: GamePace.off,
        rolls: const [3, 1, 6, 5],
      );
      controller.requestDouble();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      controller.roll();

      expect(controller.doubleRequested, isFalse);
      expect(controller.asksToDouble, isFalse);
      controller.dispose();
    });

    test(
      'A-225: Kein Recht – erwartet: '
      'Gehört der Dopplerwürfel dem Computer, gibt es nichts vorzumerken',
      () async {
        final controller = await restored(
          Game.at(
            board: Board.start(),
            turn: Player.black,
            phase: GamePhase.awaitingRoll,
            cube: const Cube(value: 2, owner: Player.black),
          ),
          pace: GamePace.off,
        );

        expect(controller.mayDouble, isFalse);
        controller.dispose();
      },
    );
  });
}
