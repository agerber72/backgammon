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
