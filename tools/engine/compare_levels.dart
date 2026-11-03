// Compares the levels: error against GNU Backgammon and games played.
// Run: dart run tools/engine/compare_levels.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/position_id.dart';
import 'package:backgammon/engine/engine.dart';

import 'players.dart';

const games = 300;

Map<int, int> counts(dynamic json) => (json as Map<String, dynamic>).map(
  (point, count) => MapEntry(int.parse(point), count as int),
);

Future<double> meanLoss(HeuristicEngine engine, Difficulty level) async {
  final entries = (jsonDecode(
    File('test/fixtures/gnubg_move_equity.json').readAsStringSync(),
  ) as List<dynamic>).cast<Map<String, dynamic>>();
  var total = 0.0;
  for (final entry in entries) {
    final player = entry['turn'] == 'white' ? Player.white : Player.black;
    final dice = entry['dice'] as List<dynamic>;
    final board = Board.fromCounts(
      white: counts(entry['white']),
      black: counts(entry['black']),
      whiteBar: entry['whiteBar'] as int,
      blackBar: entry['blackBar'] as int,
      whiteOff: entry['whiteOff'] as int,
      blackOff: entry['blackOff'] as int,
    );
    final moves = (entry['moves'] as Map<String, dynamic>).map(
      (id, equity) => MapEntry(id, (equity as num).toDouble()),
    );
    final play = await engine.choosePlay(
      board,
      player,
      Dice(dice[0] as int, dice[1] as int),
      level,
    );
    final id = positionId(play.result, player.opponent);
    total += moves.values.reduce(max) - (moves[id] ?? moves.values.reduce(min));
  }
  return total / entries.length;
}

Future<int> wins(HeuristicEngine engine, Difficulty a, Difficulty b) async {
  final roller = SeededRoller(Random(11));
  var won = 0;
  for (var i = 0; i < games; i++) {
    final first = i.isEven ? Player.white : Player.black;
    var game = Game.start(roller);
    while (game.phase != GamePhase.finished) {
      if (game.phase == GamePhase.awaitingRoll) {
        game = game.roll(roller);
      } else if (game.plays.isEmpty) {
        game = game.pass();
      } else {
        game = game.play(
          await engine.choosePlay(
            game.board,
            game.turn,
            game.dice!,
            game.turn == first ? a : b,
          ),
        );
      }
    }
    if (game.result!.winner == first) {
      won++;
    }
  }
  return won;
}

Future<void> main() async {
  final engine = HeuristicEngine(random: Random(5));
  for (final level in Difficulty.values) {
    final loss = await meanLoss(engine, level);
    stdout.writeln('${level.name}: Fehler ${loss.toStringAsFixed(4)}');
  }
  final hardMedium = await wins(engine, Difficulty.hard, Difficulty.medium);
  final mediumEasy = await wins(engine, Difficulty.medium, Difficulty.easy);
  final hardEasy = await wins(engine, Difficulty.hard, Difficulty.easy);
  stdout.writeln(
    'Schwer gegen Mittel $hardMedium, Mittel gegen Leicht $mediumEasy, '
    'Schwer gegen Leicht $hardEasy, je von $games',
  );

  // Simple opponents, with the doubling cube, show how beatable each level is.
  for (final (name, opponent) in [
    ('Anfänger', BeginnerPlayer(Random(21))),
    ('Zufall', RandomPlayer(Random(22))),
  ]) {
    for (final level in Difficulty.values) {
      final match = await playMatch(
        opponent,
        Difficulty.easy,
        HeuristicEngine(random: Random(23)),
        level,
        games,
      );
      stdout.writeln(
        '$name gegen ${level.name}: ${match.games} von $games Partien, '
        'Punkte ${match.won}:${match.lost}',
      );
    }
  }
}
