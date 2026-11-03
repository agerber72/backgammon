import '../domain/board.dart';
import 'evaluation.dart';

/// Typical mistakes of beginners. The easy level makes them on purpose, so
/// that a person can see and punish them.
enum Mistake {
  /// The best play hits, this one does not.
  missedHit,

  /// Leaves a checker clearly easier to hit than the best play.
  leftBlot,

  /// Gives up a point that was made before the move.
  brokePoint,

  /// Piles checkers deep in the home board while the game is still open.
  earlyHome,
}

/// Rolls more likely to hit than the best play that count as a left blot.
const _blotMargin = 3 / 36;

/// The mistake a play makes compared to the best play, or null if it plays
/// as well in these respects. [start] is the board before the move.
Mistake? mistakeOf(Board start, Player player, Board best, Board play) {
  final opponent = player.opponent;
  if (play.bar(opponent) < best.bar(opponent)) {
    return Mistake.missedHit;
  }
  if (madePoints(play, player) < madePoints(start, player) &&
      madePoints(best, player) >= madePoints(start, player)) {
    return Mistake.brokePoint;
  }
  if (exposure(play, player) >= exposure(best, player) + _blotMargin) {
    return Mistake.leftBlot;
  }
  if (play.hasContact &&
      deepCheckers(play, player) > deepCheckers(best, player)) {
    return Mistake.earlyHome;
  }
  return null;
}

/// Points held with at least two checkers.
int madePoints(Board board, Player player) {
  var points = 0;
  for (var point = 1; point <= Board.pointCount; point++) {
    if (board.count(player, point) >= 2) {
      points++;
    }
  }
  return points;
}

/// Checkers on the two deepest points of the home board.
int deepCheckers(Board board, Player player) =>
    board.count(player, Board.pointAt(player, 1)) +
    board.count(player, Board.pointAt(player, 2));
