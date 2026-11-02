// Tunes the evaluation weights against the ratings of GNU Backgammon.
// Run: dart run tools/engine/tune.dart
// Prints the error of the current and the tuned weights and the new values.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/domain/position_id.dart';
import 'package:backgammon/engine/evaluation.dart';

const rounds = 6;
const unratedPenalty = 0.1;

class Reference {
  Reference(this.board, this.plays, this.player, this.moves, this.win);

  final Board board;
  final List<Play> plays;
  final Player player;
  final Map<String, double> moves;
  final double win;
}

Map<int, int> counts(dynamic json) => (json as Map<String, dynamic>).map(
  (point, count) => MapEntry(int.parse(point), count as int),
);

List<Reference> load() {
  final entries = jsonDecode(
    File('test/fixtures/gnubg_move_equity.json').readAsStringSync(),
  ) as List<dynamic>;
  return [
    for (final entry in entries.cast<Map<String, dynamic>>())
      () {
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
        return Reference(
          board,
          legalPlays(board, player, Dice(dice[0] as int, dice[1] as int)),
          player,
          (entry['moves'] as Map<String, dynamic>).map(
            (id, equity) => MapEntry(id, (equity as num).toDouble()),
          ),
          (entry['positionWin'] as num).toDouble(),
        );
      }(),
  ];
}

/// Mean equity lost against the best reference move.
double loss(List<Reference> references, EvaluationWeights weights) {
  var total = 0.0;
  for (final reference in references) {
    final chosen = reference.plays.reduce(
      (a, b) =>
          evaluate(a.result, reference.player, weights) >=
              evaluate(b.result, reference.player, weights)
          ? a
          : b,
    );
    final best = reference.moves.values.reduce(max);
    final worst = reference.moves.values.reduce(min);
    final id = positionId(chosen.result, reference.player.opponent);
    final equity = reference.moves[id] ?? worst - unratedPenalty;
    total += best - equity;
  }
  return total / references.length;
}

/// Mean distance between the win estimate and the reference win chance.
double winError(
  List<Reference> references,
  EvaluationWeights weights,
  double slope,
  double bonus,
) {
  var total = 0.0;
  for (final reference in references) {
    final score = evaluate(reference.board, reference.player, weights) + bonus;
    total += (1 / (1 + exp(-slope * score)) - reference.win).abs();
  }
  return total / references.length;
}

void main() {
  final all = load();
  // Weights are tuned on one half and judged on the other, unseen half.
  final training = [for (var i = 0; i < all.length; i += 2) all[i]];
  final unseen = [for (var i = 1; i < all.length; i += 2) all[i]];

  var values = const EvaluationWeights().toList();
  var bestLoss = loss(training, const EvaluationWeights());
  final startUnseen = loss(unseen, const EvaluationWeights());
  stdout.writeln(
    'start training ${bestLoss.toStringAsFixed(4)} '
    'unseen ${startUnseen.toStringAsFixed(4)}',
  );

  var step = 0.5;
  for (var round = 0; round < rounds; round++) {
    for (var i = 0; i < values.length; i++) {
      for (final factor in [1 + step, 1 - step]) {
        final trial = List.of(values);
        trial[i] *= factor;
        final trialLoss = loss(training, EvaluationWeights.fromList(trial));
        if (trialLoss < bestLoss) {
          bestLoss = trialLoss;
          values = trial;
        }
      }
    }
    step *= 0.7;
  }
  final weights = EvaluationWeights.fromList(values);
  stdout.writeln(
    'tuned training ${bestLoss.toStringAsFixed(4)} '
    'unseen ${loss(unseen, weights).toStringAsFixed(4)}',
  );
  stdout.writeln(values.map((v) => v.toStringAsFixed(3)).join(', '));

  var bestSlope = 0.0;
  var bestBonus = 0.0;
  var bestError = double.infinity;
  for (var slope = 0.4; slope < 4; slope += 0.1) {
    for (var bonus = -0.2; bonus < 0.5; bonus += 0.02) {
      final error = winError(training, weights, slope, bonus);
      if (error < bestError) {
        bestError = error;
        bestSlope = slope;
        bestBonus = bonus;
      }
    }
  }
  final unseenError = winError(unseen, weights, bestSlope, bestBonus);
  stdout.writeln(
    'win slope ${bestSlope.toStringAsFixed(2)} '
    'bonus ${bestBonus.toStringAsFixed(2)} '
    'training ${bestError.toStringAsFixed(3)} '
    'unseen ${unseenError.toStringAsFixed(3)}',
  );
}
