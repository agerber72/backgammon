import '../../domain/board.dart';
import '../../domain/game.dart';

/// A checker on its way, which the board draws at an interim position.
class MovingChecker {
  const MovingChecker(this.player, this.from, this.to, this.progress);

  final Player player;
  final int from;
  final int to;
  final double progress;
}

/// What the board shows, independent of how the game got there.
class BoardScene {
  const BoardScene({
    required this.checkers,
    required this.bar,
    required this.off,
    required this.diceColor,
    required this.dice,
    required this.cubeValue,
    this.cubeOwner,
    this.selected,
    this.targets = const {},
    this.moving,
    this.direction,
    this.directionOpacity = 0,
  });

  factory BoardScene.of(
    Board board,
    Game? game, {
    int? selected,
    Set<int> targets = const {},
    MovingChecker? moving,
    Player? direction,
    double directionOpacity = 0,
  }) {
    Map<int, int> pointsOf(Player player) => {
      for (var point = 1; point <= Board.pointCount; point++)
        if (board.count(player, point) > 0) point: board.count(player, point),
    };
    final dice = game?.dice;
    return BoardScene(
      checkers: {for (final p in Player.values) p.name: pointsOf(p)},
      bar: {for (final p in Player.values) p.name: board.bar(p)},
      off: {for (final p in Player.values) p.name: board.off(p)},
      diceColor: (game?.turn ?? Player.white).name,
      dice: dice == null ? const [] : [dice.first, dice.second],
      cubeValue: game?.cube.value ?? 1,
      cubeOwner: game?.cube.owner?.name,
      selected: selected,
      targets: targets,
      moving: moving,
      direction: direction,
      directionOpacity: directionOpacity,
    );
  }

  /// Checker count per point, grouped by color.
  final Map<String, Map<int, int>> checkers;
  final Map<String, int> bar;

  /// Borne-off checkers per color, shown on edge in the tray.
  final Map<String, int> off;
  final String diceColor;
  final List<int> dice;
  final int cubeValue;

  /// Player holding the cube; it waits in the tray until the first double.
  final String? cubeOwner;

  final int? selected;
  final Set<int> targets;
  final MovingChecker? moving;

  /// Player whose direction of play the board shows as an arrow, at the
  /// start of a game.
  final Player? direction;
  final double directionOpacity;
}
