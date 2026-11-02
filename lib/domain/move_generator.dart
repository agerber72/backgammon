import 'board.dart';
import 'dice.dart';

/// A complete turn: all steps of one roll and the board they lead to.
class Play {
  const Play(this.steps, this.result);

  final List<Step> steps;
  final Board result;
}

/// All checker moves a single die allows right now.
List<Step> legalSteps(Board board, Player player, int die) {
  if (board.bar(player) > 0) {
    final target = Board.pointAt(player, Board.pointCount + 1 - die);
    return board.isOpen(player, target)
        ? [Step(from: Step.barOf(player), to: target, die: die)]
        : const [];
  }

  final steps = <Step>[];
  final canBearOff = board.allHome(player);
  for (var point = 1; point <= Board.pointCount; point++) {
    if (board.count(player, point) == 0) {
      continue;
    }
    final distance = Board.distance(player, point);
    if (distance > die) {
      final target = Board.pointAt(player, distance - die);
      if (board.isOpen(player, target)) {
        steps.add(Step(from: point, to: target, die: die));
      }
    } else if (canBearOff &&
        (distance == die || !_hasCheckerBehind(board, player, distance))) {
      steps.add(Step(from: point, to: Step.offOf(player), die: die));
    }
  }
  return steps;
}

bool _hasCheckerBehind(Board board, Player player, int distance) {
  for (var d = distance + 1; d <= Board.homeSize; d++) {
    if (board.count(player, Board.pointAt(player, d)) > 0) {
      return true;
    }
  }
  return false;
}

/// The checker moves that can follow [done] and still lead to a legal play.
List<Step> nextSteps(Board start, Player player, Dice dice, List<Step> done) {
  final finals = legalPlays(
    start,
    player,
    dice,
  ).map((play) => play.result.key).toSet();
  var current = start;
  final remaining = List.of(dice.moves);
  for (final step in done) {
    current = current.apply(player, step);
    remaining.remove(step.die);
  }

  // A board only counts as final once no die can be played any more: the same
  // board can come up early, for example when a single high die bears off.
  bool reachesFinal(Board board, List<int> rest) {
    var moved = false;
    for (final die in rest.toSet()) {
      final left = List.of(rest)..remove(die);
      for (final step in legalSteps(board, player, die)) {
        moved = true;
        if (reachesFinal(board.apply(player, step), left)) {
          return true;
        }
      }
    }
    return !moved && finals.contains(board.key);
  }

  final allowed = <String, Step>{};
  for (final die in remaining.toSet()) {
    final left = List.of(remaining)..remove(die);
    for (final step in legalSteps(current, player, die)) {
      if (reachesFinal(current.apply(player, step), left)) {
        allowed.putIfAbsent('${step.from}/${step.to}/$die', () => step);
      }
    }
  }
  return allowed.values.toList();
}

/// All places one checker can reach from [from], using one or more of the
/// remaining dice, each with the steps leading there. Only steps allowed by
/// [nextSteps] count, so a combined move never crosses a blocked point. If
/// several orders lead to the same place, the one that hits fewest checkers
/// wins, so that a combined move never hits by surprise.
Map<int, List<Step>> pathsFrom(
  Board start,
  Player player,
  Dice dice,
  List<Step> done,
  int from,
) {
  final paths = <int, List<Step>>{};
  final hits = <int, int>{};

  void walk(int position, List<Step> path, int hitCount) {
    final current = [
      ...done,
      ...path,
    ].fold(start, (board, step) => board.apply(player, step));
    for (final step in nextSteps(start, player, dice, [...done, ...path])) {
      if (step.from != position) {
        continue;
      }
      final hit =
          !step.isBearingOff(player) &&
          current.count(player.opponent, step.to) == 1;
      final next = [...path, step];
      final nextHits = hitCount + (hit ? 1 : 0);
      final known = paths[step.to];
      final isBetter =
          known == null ||
          next.length < known.length ||
          (next.length == known.length && nextHits < hits[step.to]!);
      if (isBetter) {
        paths[step.to] = next;
        hits[step.to] = nextHits;
      }
      if (!step.isBearingOff(player)) {
        walk(step.to, next, nextHits);
      }
    }
  }

  walk(from, const [], 0);
  return paths;
}

/// All complete turns the rules allow. Plays that end on the same board count
/// once. An empty list means the player has to pass.
List<Play> legalPlays(Board board, Player player, Dice dice) {
  final finished = <Play>[];
  final visited = <String>{};

  void explore(Board current, List<int> remaining, List<Step> steps) {
    var moved = false;
    for (final die in remaining.toSet()) {
      final rest = List.of(remaining)..remove(die);
      for (final step in legalSteps(current, player, die)) {
        moved = true;
        final next = current.apply(player, step);
        if (visited.add('${next.key}/${rest.join()}')) {
          explore(next, rest, [...steps, step]);
        }
      }
    }
    if (!moved) {
      finished.add(Play(steps, current));
    }
  }

  explore(board, dice.moves, const []);

  final mostSteps = finished.fold(
    0,
    (most, play) => play.steps.length > most ? play.steps.length : most,
  );
  if (mostSteps == 0) {
    return const [];
  }
  var allowed = finished.where((play) => play.steps.length == mostSteps);
  if (mostSteps == 1 && !dice.isDouble) {
    final withHigher = allowed.where(
      (play) => play.steps.single.die == dice.higher,
    );
    if (withHigher.isNotEmpty) {
      allowed = withHigher;
    }
  }

  final unique = <String, Play>{};
  for (final play in allowed) {
    unique.putIfAbsent(play.result.key, () => play);
  }
  return unique.values.toList();
}
