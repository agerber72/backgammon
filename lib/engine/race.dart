import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/move_generator.dart';

/// Average number of pips a roll moves, doubles counted four times.
const averagePipsPerRoll = 49 / 6;

/// The play for a pure race, used when the game plays itself to the end.
///
/// A side that can still win the race, or has already borne off a checker,
/// races home and bears off as fast as possible ([raceScore]). A side that has
/// lost the race and has not borne off a checker yet limits the damage
/// instead: it first saves the backgammon, then the gammon ([savingScore]).
Play racePlay(Board board, Player player, Dice dice) {
  final plays = legalPlays(board, player, dice);
  if (!isRaceLost(board, player)) {
    return _best(plays, (board) => [raceScore(board, player)]);
  }
  return _best(plays, (board) => savingScore(board, player));
}

/// Whether [player], who is on roll, has no real chance left to win the race
/// and could still lose a gammon. The race counts as lost when the player
/// needs more than one roll more than the opponent; being on roll is worth
/// about half a roll.
bool isRaceLost(Board board, Player player) {
  if (board.off(player) > 0) {
    return false;
  }
  final own = _effectivePips(board, player) / averagePipsPerRoll - 0.5;
  final opponent = _effectivePips(board, player.opponent) / averagePipsPerRoll;
  return own > opponent + 1;
}

/// Rates a race position for [player]; higher is better. The order of the
/// terms is strict: checkers off first, then checkers on their way home, then
/// the pip count with the Keith count's corrections for a smooth bear-off.
double raceScore(Board board, Player player) =>
    board.off(player) * 1000.0 -
    _crossovers(board, player) * 100.0 -
    _effectivePips(board, player);

/// Rates a position for a [player] who has lost the race and plays to save
/// the gammon; compared term by term, higher is better:
///
/// 1. a checker borne off, which saves the gammon at once,
/// 2. few pips left until every checker has left the opponent's home board,
///    which saves the backgammon,
/// 3. few crossovers until every checker is home,
/// 4. few pips left until every checker is home, so no pips are spent inside
///    the home board while checkers are still outside,
/// 5. good chances to bear off the first checker soon: once all checkers are
///    home, the share of rolls that bear one off next turn, before that a
///    lowest checker as deep as possible,
/// 6. the race score as a tie-break.
List<double> savingScore(Board board, Player player) {
  final allHome = board.allHome(player);
  return [
    board.off(player).toDouble(),
    -_pipsToLeave(board, player, Board.pointCount - Board.homeSize).toDouble(),
    -_crossovers(board, player).toDouble(),
    -_pipsToLeave(board, player, Board.homeSize).toDouble(),
    allHome
        ? _rollsBearingOff(board, player).toDouble()
        : -_lowestHomeDistance(board, player).toDouble(),
    raceScore(board, player),
  ];
}

Play _best(List<Play> plays, List<double> Function(Board board) score) {
  var best = plays.first;
  var bestScore = score(best.result);
  for (final play in plays.skip(1)) {
    final candidate = score(play.result);
    if (_compare(candidate, bestScore) > 0) {
      best = play;
      bestScore = candidate;
    }
  }
  return best;
}

int _compare(List<double> a, List<double> b) {
  for (var index = 0; index < a.length; index++) {
    final order = a[index].compareTo(b[index]);
    if (order != 0) {
      return order;
    }
  }
  return 0;
}

/// Pips the checkers beyond [limit] still need until they stand on [limit]
/// or lower. A checker on the bar counts as one pip beyond point 24.
int _pipsToLeave(Board board, Player player, int limit) {
  var pips = board.bar(player) * (Board.pointCount + 1 - limit);
  for (var distance = limit + 1; distance <= Board.pointCount; distance++) {
    pips +=
        board.count(player, Board.pointAt(player, distance)) *
        (distance - limit);
  }
  return pips;
}

/// Distance of the own checker closest to the edge within the home board, or
/// one more than the home board when it is empty.
int _lowestHomeDistance(Board board, Player player) {
  for (var distance = 1; distance <= Board.homeSize; distance++) {
    if (board.count(player, Board.pointAt(player, distance)) > 0) {
      return distance;
    }
  }
  return Board.homeSize + 1;
}

/// Of the 36 rolls, how many bear off at least one checker.
int _rollsBearingOff(Board board, Player player) {
  var rolls = 0;
  for (var first = 1; first <= 6; first++) {
    for (var second = first; second <= 6; second++) {
      final plays = legalPlays(board, player, Dice(first, second));
      if (plays.any((play) => play.result.off(player) > board.off(player))) {
        rolls += first == second ? 1 : 2;
      }
    }
  }
  return rolls;
}

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
