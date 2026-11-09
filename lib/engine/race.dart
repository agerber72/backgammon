import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/move_generator.dart';

/// The play that ends a pure race fastest: it bears off as many checkers as
/// the roll allows, otherwise brings as many checkers home as it can, and
/// leaves a position that bears off smoothly. Used when the game plays itself
/// to the end, where both sides want to finish as fast as possible.
Play racePlay(Board board, Player player, Dice dice) {
  final plays = legalPlays(board, player, dice);
  var best = plays.first;
  var bestScore = double.negativeInfinity;
  for (final play in plays) {
    final score = raceScore(play.result, player);
    if (score > bestScore) {
      bestScore = score;
      best = play;
    }
  }
  return best;
}

/// Rates a race position for [player]; higher is better. The order of the
/// terms is strict: checkers off first, then checkers on their way home, then
/// the pip count with the Keith count's corrections for a smooth bear-off.
double raceScore(Board board, Player player) =>
    board.off(player) * 1000.0 -
    _crossovers(board, player) * 100.0 -
    _effectivePips(board, player);

/// How often the checkers still have to move into the next quadrant until all
/// of them are home.
int _crossovers(Board board, Player player) {
  var crossovers = board.bar(player) * 4;
  for (
    var distance = Board.homeSize + 1;
    distance <= Board.pointCount;
    distance++
  ) {
    final count = board.count(player, Board.pointAt(player, distance));
    crossovers += count * ((distance - 1) ~/ Board.homeSize);
  }
  return crossovers;
}

/// Pip count plus the corrections of the Keith count: checkers stacked on the
/// lowest points waste pips, and gaps on the high home points waste rolls.
int _effectivePips(Board board, Player player) {
  int at(int distance) => board.count(player, Board.pointAt(player, distance));
  var pips = board.bar(player) * (Board.pointCount + 1);
  for (var distance = 1; distance <= Board.pointCount; distance++) {
    pips += at(distance) * distance;
  }
  var waste = 0;
  if (at(1) > 1) {
    waste += 2 * (at(1) - 1);
  }
  if (at(2) > 1) {
    waste += at(2) - 1;
  }
  if (at(3) > 3) {
    waste += at(3) - 3;
  }
  for (final distance in const [4, 5, 6]) {
    if (at(distance) == 0) {
      waste++;
    }
  }
  return pips + waste;
}
