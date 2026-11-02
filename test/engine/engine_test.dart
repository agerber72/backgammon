import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/domain/position_id.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

class Reference {
  Reference(this.board, this.player, this.dice, this.moves);

  final Board board;
  final Player player;
  final Dice dice;
  final Map<String, double> moves;
}

class SeededRoller implements DiceRoller {
  SeededRoller(this.random);

  final Random random;

  @override
  int roll() => random.nextInt(6) + 1;
}

Map<int, int> counts(dynamic json) => (json as Map<String, dynamic>).map(
  (point, count) => MapEntry(int.parse(point), count as int),
);

List<Reference> loadReferences() {
  final entries = jsonDecode(
    File('test/fixtures/gnubg_move_equity.json').readAsStringSync(),
  ) as List<dynamic>;
  return [
    for (final entry in entries.cast<Map<String, dynamic>>())
      Reference(
        Board.fromCounts(
          white: counts(entry['white']),
          black: counts(entry['black']),
          whiteBar: entry['whiteBar'] as int,
          blackBar: entry['blackBar'] as int,
          whiteOff: entry['whiteOff'] as int,
          blackOff: entry['blackOff'] as int,
        ),
        entry['turn'] == 'white' ? Player.white : Player.black,
        Dice(
          (entry['dice'] as List<dynamic>)[0] as int,
          (entry['dice'] as List<dynamic>)[1] as int,
        ),
        (entry['moves'] as Map<String, dynamic>).map(
          (id, equity) => MapEntry(id, (equity as num).toDouble()),
        ),
      ),
  ];
}

/// Mean equity an engine gives away against GNU Backgammon's best move.
Future<double> meanLoss(List<Reference> references, Difficulty level) async {
  final engine = HeuristicEngine(random: Random(7));
  var total = 0.0;
  for (final reference in references) {
    final play = await engine.choosePlay(
      reference.board,
      reference.player,
      reference.dice,
      level,
    );
    final id = positionId(play.result, reference.player.opponent);
    final values = reference.moves.values;
    total += values.reduce(max) - (reference.moves[id] ?? values.reduce(min));
  }
  return total / references.length;
}

/// Lets two levels play; returns the games the first level won.
Future<int> wins(Difficulty first, Difficulty second, int games) async {
  final random = Random(11);
  final roller = SeededRoller(random);
  final engine = HeuristicEngine(random: random);
  var won = 0;
  for (var i = 0; i < games; i++) {
    // The first level swaps sides so that color has no influence.
    final firstPlays = i.isEven ? Player.white : Player.black;
    var game = Game.start(roller);
    while (game.phase != GamePhase.finished) {
      if (game.phase == GamePhase.awaitingRoll) {
        game = game.roll(roller);
        continue;
      }
      if (game.plays.isEmpty) {
        game = game.pass();
        continue;
      }
      game = game.play(
        await engine.choosePlay(
          game.board,
          game.turn,
          game.dice!,
          game.turn == firstPlays ? first : second,
        ),
      );
    }
    if (game.result!.winner == firstPlays) {
      won++;
    }
  }
  return won;
}

void main() {
  final references = loadReferences();

  group('Zugwahl:', () {
    test(
      'A-402: Erlaubte Züge – erwartet: '
      'Jede Stufe spielt in allen Referenzstellungen nur erlaubte Züge',
      () async {
        final engine = HeuristicEngine(random: Random(3));
        for (final reference in references) {
          final legal = legalPlays(
            reference.board,
            reference.player,
            reference.dice,
          ).map((play) => play.result.key).toSet();
          for (final level in Difficulty.values) {
            final play = await engine.choosePlay(
              reference.board,
              reference.player,
              reference.dice,
              level,
            );
            expect(legal, contains(play.result.key));
          }
        }
      },
    );

    test('A-403: Drei Stufen – erwartet: '
        'Der Fehler gegenüber GNU Backgammon sinkt von Leicht über Mittel '
        'zu Schwer', () async {
      final easy = await meanLoss(references, Difficulty.easy);
      final medium = await meanLoss(references, Difficulty.medium);
      final hard = await meanLoss(references, Difficulty.hard);

      // ignore: avoid_print
      print(
        'Equity-Verlust je Zug: leicht $easy, mittel $medium, schwer $hard',
      );
      expect(easy, greaterThan(medium));
      expect(medium, greaterThan(hard));
    });

    test('A-406: Stärke messen – erwartet: '
        'Schwer verliert im Schnitt weniger als 0,06 Equity je Zug', () async {
      expect(await meanLoss(references, Difficulty.hard), lessThan(0.06));
    });

    test('A-403: Stufen im Spiel – erwartet: '
        'In je 300 Partien schlägt jede Stufe die schwächere klar', () async {
      final hardMedium = await wins(Difficulty.hard, Difficulty.medium, 300);
      final mediumEasy = await wins(Difficulty.medium, Difficulty.easy, 300);

      // ignore: avoid_print
      print('Schwer gegen Mittel $hardMedium, Mittel gegen Leicht $mediumEasy');
      expect(hardMedium, greaterThan(170));
      expect(mediumEasy, greaterThan(190));
    }, timeout: const Timeout(Duration(minutes: 3)));
  });

  group('Dopplerwürfel:', () {
    Game rollingWith(Board board, {Cube cube = const Cube()}) => Game.at(
      board: board,
      turn: Player.white,
      phase: GamePhase.awaitingRoll,
      cube: cube,
    );

    // White is far ahead in a pure race.
    final leading = Board.fromCounts(
      white: const {1: 5, 2: 5, 3: 5},
      black: const {1: 0, 13: 8, 14: 7},
    );

    test('A-404: Klarer Vorsprung – erwartet: '
        'Der Computer doppelt auf jeder Stufe', () async {
      final engine = HeuristicEngine();
      for (final level in Difficulty.values) {
        expect(await engine.wantsToDouble(rollingWith(leading), level), isTrue);
      }
    });

    test(
      'A-404: Aussichtslos – erwartet: '
      'Der Computer lehnt ein Doppeln ab, das er kaum gewinnen kann',
      () async {
        final engine = HeuristicEngine();
        final offered = rollingWith(leading).offerDouble();

        expect(await engine.acceptsDouble(offered, Difficulty.hard), isFalse);
      },
    );

    test(
      'A-404: Ausgeglichen – erwartet: '
      'Zu Beginn doppelt der Computer nicht und nimmt ein Doppeln an',
      () async {
        final engine = HeuristicEngine();
        final start = rollingWith(Board.start());

        expect(await engine.wantsToDouble(start, Difficulty.hard), isFalse);
        expect(
          await engine.acceptsDouble(start.offerDouble(), Difficulty.hard),
          isTrue,
        );
      },
    );

    test('A-404: Fremder Würfel – erwartet: '
        'Gehört der Würfel dem Gegner, doppelt der Computer nicht', () async {
      final engine = HeuristicEngine();
      final game = rollingWith(
        leading,
        cube: const Cube(value: 2, owner: Player.black),
      );

      expect(await engine.wantsToDouble(game, Difficulty.hard), isFalse);
    });
  });

  test('A-405: Bedienbar beim Rechnen – erwartet: '
      'Keine Berechnung dauert länger als ein Zehntel einer Sekunde', () async {
    final engine = HeuristicEngine(random: Random(1));
    var longest = Duration.zero;

    for (final reference in references) {
      final watch = Stopwatch()..start();
      await engine.choosePlay(
        reference.board,
        reference.player,
        reference.dice,
        Difficulty.hard,
      );
      if (watch.elapsed > longest) {
        longest = watch.elapsed;
      }
    }

    // ignore: avoid_print
    print('Längste Berechnung: ${longest.inMilliseconds} ms');
    expect(longest, lessThan(const Duration(milliseconds: 100)));
  });
}
