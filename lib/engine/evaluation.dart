import 'dart:math' as math;

import '../domain/board.dart';

/// Weights of the position features, tuned by tools/engine/tune.dart against
/// reference ratings of GNU Backgammon.
class EvaluationWeights {
  const EvaluationWeights({
    this.pipLead = 1.5,
    this.homePoints = 0.162,
    this.outerPoints = 0.03,
    this.prime = 0.087,
    this.blots = 0.034,
    this.exposure = 0.5,
    this.bar = 0.25,
    this.off = 0.05,
    this.anchors = 0.033,
    this.stacking = 0.019,
    this.raceScale = 5.0,
  });

  EvaluationWeights.fromList(List<double> values)
    : pipLead = values[0],
      homePoints = values[1],
      outerPoints = values[2],
      prime = values[3],
      blots = values[4],
      exposure = values[5],
      bar = values[6],
      off = values[7],
      anchors = values[8],
      stacking = values[9],
      raceScale = values[10];

  final double pipLead;
  final double homePoints;
  final double outerPoints;
  final double prime;
  final double blots;
  final double exposure;
  final double bar;
  final double off;
  final double anchors;
  final double stacking;
  final double raceScale;

  List<double> toList() => [
    pipLead,
    homePoints,
    outerPoints,
    prime,
    blots,
    exposure,
    bar,
    off,
    anchors,
    stacking,
    raceScale,
  ];
}

/// Rates a position for [player] just after that player has moved, so the
/// opponent rolls next. Higher is better; the unit roughly follows equity.
double evaluate(
  Board board,
  Player player, [
  EvaluationWeights weights = const EvaluationWeights(),
]) {
  final opponent = player.opponent;
  final mine = _Side.of(board, player);
  final theirs = _Side.of(board, opponent);
  final lead = (theirs.pips - mine.pips) / 100;

  if (!board.hasContact) {
    return lead * weights.raceScale +
        (board.off(player) - board.off(opponent)) * weights.off;
  }
  return lead * weights.pipLead +
      (mine.homePoints - theirs.homePoints) * weights.homePoints +
      (mine.outerPoints - theirs.outerPoints) * weights.outerPoints +
      (mine.prime - theirs.prime) * weights.prime -
      (mine.blots - theirs.blots) * weights.blots -
      _exposure(board, player) * weights.exposure +
      (board.bar(opponent) - board.bar(player)) * weights.bar +
      (board.off(player) - board.off(opponent)) * weights.off +
      (mine.anchors - theirs.anchors) * weights.anchors -
      (mine.stacked - theirs.stacked) * weights.stacking;
}

/// Estimated chance that [player] wins when about to roll, from 0 to 1.
double estimateWin(Board board, Player player) {
  final score = evaluate(board, player) + _rollBonus;
  return 1 / (1 + math.exp(-_winSlope * score));
}

const _rollBonus = 0.46;
const _winSlope = 1.0;

class _Side {
  const _Side({
    required this.pips,
    required this.homePoints,
    required this.outerPoints,
    required this.prime,
    required this.blots,
    required this.anchors,
    required this.stacked,
  });

  factory _Side.of(Board board, Player player) {
    var pips = board.bar(player) * (Board.pointCount + 1);
    var homePoints = 0;
    var outerPoints = 0;
    var anchors = 0;
    var blots = 0;
    var stacked = 0;
    var run = 0;
    var prime = 0;
    for (var distance = 1; distance <= Board.pointCount; distance++) {
      final count = board.count(player, Board.pointAt(player, distance));
      pips += count * distance;
      if (count >= 2) {
        run++;
        prime = math.max(prime, run);
        if (distance <= Board.homeSize) {
          homePoints++;
        } else if (distance <= 2 * Board.homeSize) {
          outerPoints++;
        } else if (distance > Board.pointCount - Board.homeSize) {
          anchors++;
        }
      } else {
        run = 0;
      }
      if (count == 1) {
        blots++;
      }
      if (count > 3) {
        stacked += count - 3;
      }
    }
    return _Side(
      pips: pips,
      homePoints: homePoints,
      outerPoints: outerPoints,
      prime: prime,
      blots: blots,
      anchors: anchors,
      stacked: stacked,
    );
  }

  final int pips;
  final int homePoints;
  final int outerPoints;
  final int prime;
  final int blots;
  final int anchors;
  final int stacked;
}

/// Share of the 36 rolls that hit one of the player's blots, each weighted by
/// the progress the blot would lose. Blocked paths are ignored for speed.
double _exposure(Board board, Player player) {
  final opponent = player.opponent;
  final gaps = <int>{};
  final losses = <int, double>{};
  for (var point = 1; point <= Board.pointCount; point++) {
    if (board.count(player, point) != 1) {
      continue;
    }
    final lost =
        (Board.pointCount - Board.distance(player, point)) / Board.pointCount;
    final distanceToMe = Board.distance(opponent, point);
    for (var from = distanceToMe + 1; from <= Board.pointCount + 1; from++) {
      final hasChecker = from > Board.pointCount
          ? board.bar(opponent) > 0
          : board.count(opponent, Board.pointAt(opponent, from)) > 0;
      if (hasChecker) {
        final gap = from - distanceToMe;
        gaps.add(gap);
        losses[gap] = math.max(losses[gap] ?? 0, lost);
      }
    }
  }
  if (gaps.isEmpty) {
    return 0;
  }
  var total = 0.0;
  for (var a = 1; a <= 6; a++) {
    for (var b = 1; b <= 6; b++) {
      var worst = 0.0;
      for (final gap in [a, b, a + b]) {
        worst = math.max(worst, losses[gap] ?? 0);
      }
      if (a == b) {
        for (final gap in [3 * a, 4 * a]) {
          worst = math.max(worst, losses[gap] ?? 0);
        }
      }
      total += worst;
    }
  }
  return total / 36;
}
