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

/// A clock the test moves forward by hand.
class FakeClock {
  var now = DateTime(2026, 11, 9, 20, 15);

  void advance(Duration time) => now = now.add(time);
}

GameRecord record({
  Difficulty difficulty = Difficulty.medium,
  int points = 1,
  int computerPoints = 0,
}) => GameRecord(
  finishedAt: DateTime(2026, 11, 9),
  difficulty: difficulty,
  color: Player.white,
  playTime: const Duration(minutes: 5),
  points: points,
  computerPoints: computerPoints,
);

void main() {
  final store = SharedPreferencesSessionStore();
  late FakeClock clock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = FakeClock();
  });

  GameController controllerWith({SessionStore? sessionStore}) => GameController(
    roller: FixedRoller([3, 1, 6, 5]),
    engine: ScriptedEngine(),
    store: sessionStore,
    computerPause: Duration.zero,
    autoActionDelay: null,
    clock: () => clock.now,
  );

  test('A-219: Partie festhalten – erwartet: '
      'Eine beendete Partie steht mit Stufe, Farbe, Spielzeit und den '
      'Punkten beider Seiten in der Bestenliste', () {
    final controller = controllerWith(sessionStore: store)
      ..startGame(human: Player.black, difficulty: Difficulty.hard);
    clock.advance(const Duration(minutes: 7, seconds: 12));

    controller.resign();

    final game = controller.records.games.single;
    expect(game.difficulty, Difficulty.hard);
    expect(game.color, Player.black);
    expect(game.playTime, const Duration(minutes: 7, seconds: 12));
    expect(game.points, 0);
    expect(game.computerPoints, 1);
    expect(game.finishedAt, clock.now);
    controller.dispose();
  });

  test('A-219: Gesamtpunkte – erwartet: '
      'Je Stufe und über alle Stufen zählen Partien, Siege und die Punkte '
      'von Spieler und Computer', () {
    final records = GameRecords()
      ..add(record(difficulty: Difficulty.easy, points: 2))
      ..add(record(difficulty: Difficulty.easy, computerPoints: 4, points: 0))
      ..add(record(difficulty: Difficulty.hard, points: 1));

    final easy = records.totalsOf(Difficulty.easy);
    expect(easy.games, 2);
    expect(easy.wins, 1);
    expect(easy.points, 2);
    expect(easy.computerPoints, 4);
    expect(records.totalsOf(Difficulty.medium).games, 0);
    expect(records.total.games, 3);
    expect(records.total.points, 3);
  });

  test(
    'A-219: Neueste zuerst, höchstens 100 – erwartet: '
    'Ältere Partien fallen aus der Liste, die Gesamtpunkte zählen weiter',
    () {
      final records = GameRecords();
      for (var game = 0; game < GameRecords.maxGames + 5; game++) {
        records.add(record(points: game == GameRecords.maxGames + 4 ? 9 : 1));
      }

      expect(records.games, hasLength(GameRecords.maxGames));
      expect(records.games.first.points, 9);
      expect(records.total.games, GameRecords.maxGames + 5);
    },
  );

  test(
    'A-219: Neustart der App – erwartet: '
    'Bestenliste und Spielzeit der laufenden Partie bleiben erhalten',
    () async {
      final first = controllerWith(sessionStore: store)
        ..startGame(human: Player.white, difficulty: Difficulty.easy);
      clock.advance(const Duration(minutes: 3));
      first.resign();
      first.startGame(human: Player.white);
      clock.advance(const Duration(minutes: 2));
      first.updatePace(GamePace.off);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Time while the app is closed does not count.
      clock.advance(const Duration(hours: 5));
      final second = controllerWith(sessionStore: store);
      await second.restore();
      clock.advance(const Duration(minutes: 1));

      expect(second.records.games.single.playTime, const Duration(minutes: 3));
      expect(second.records.totalsOf(Difficulty.easy).computerPoints, 1);
      expect(second.playTime, const Duration(minutes: 3));
      first.dispose();
      second.dispose();
    },
  );

  test('A-219: Älterer Spielstand – erwartet: '
      'Ein Stand aus Version 1.0 ohne Bestenliste lädt mit leerer Liste', () {
    final json =
        Session(gameStats: DiceStats(), totalStats: DiceStats()).toJson()
          ..remove('records')
          ..remove('playSeconds');

    final session = Session.fromJson(json);

    expect(session.records.games, isEmpty);
    expect(session.playSeconds, 0);
  });

  test('A-219: Web-Version – erwartet: '
      'Ohne Speicher führt die App keine Bestenliste', () {
    final controller = controllerWith()..startGame(human: Player.white);

    controller.resign();

    expect(controller.keepsRecords, isFalse);
    expect(controller.records.games, isEmpty);
    controller.dispose();
  });

  test('A-219: Zwei Spieler am Gerät – erwartet: '
      'Partien ohne Computer zählen nicht', () {
    final controller = controllerWith(sessionStore: store)..startGame();

    controller.resign();

    expect(controller.records.games, isEmpty);
    controller.dispose();
  });
}
