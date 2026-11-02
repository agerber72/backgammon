import 'dart:math' as math;

enum Player {
  white,
  black;

  Player get opponent => this == white ? black : white;
}

/// Checkers on the board. Points are numbered 1 to 24 from white's side:
/// white moves down towards point 1, black moves up towards point 24.
class Board {
  Board._(this._points, this._bar, this._off);

  factory Board.fromCounts({
    Map<int, int> white = const {},
    Map<int, int> black = const {},
    int whiteBar = 0,
    int blackBar = 0,
    int whiteOff = 0,
    int blackOff = 0,
  }) {
    final points = List.filled(pointCount + 1, 0);
    white.forEach((point, count) => points[point] = count);
    black.forEach((point, count) => points[point] = -count);
    return Board._(
      List.unmodifiable(points),
      List.unmodifiable([whiteBar, blackBar]),
      List.unmodifiable([whiteOff, blackOff]),
    );
  }

  factory Board.start() => Board.fromCounts(
    white: const {24: 2, 13: 5, 8: 3, 6: 5},
    black: const {1: 2, 12: 5, 17: 3, 19: 5},
  );

  static const pointCount = 24;
  static const checkersPerPlayer = 15;
  static const homeSize = 6;

  /// Positive counts are white checkers, negative counts black ones.
  final List<int> _points;
  final List<int> _bar;
  final List<int> _off;

  int count(Player player, int point) {
    final value = _points[point];
    return player == Player.white ? math.max(value, 0) : math.max(-value, 0);
  }

  int bar(Player player) => _bar[player.index];

  int off(Player player) => _off[player.index];

  /// Distance of a point from the player's bearing-off edge, from 1 to 24.
  static int distance(Player player, int point) =>
      player == Player.white ? point : pointCount + 1 - point;

  /// The point at the given distance from the player's bearing-off edge.
  static int pointAt(Player player, int distance) =>
      Board.distance(player, distance);

  static bool isHome(Player player, int point) =>
      distance(player, point) <= homeSize;

  bool allHome(Player player) {
    if (bar(player) > 0) {
      return false;
    }
    for (var point = 1; point <= pointCount; point++) {
      if (count(player, point) > 0 && !isHome(player, point)) {
        return false;
      }
    }
    return true;
  }

  bool isOpen(Player player, int point) => count(player.opponent, point) < 2;

  /// Moves one checker; `from` and `to` use the numbering of [Step].
  Board apply(Player player, Step step) {
    final points = List.of(_points);
    final bars = List.of(_bar);
    final offs = List.of(_off);
    final sign = player == Player.white ? 1 : -1;

    if (step.isEntering(player)) {
      bars[player.index]--;
    } else {
      points[step.from] -= sign;
    }
    if (step.isBearingOff(player)) {
      offs[player.index]++;
    } else {
      if (count(player.opponent, step.to) == 1) {
        points[step.to] = 0;
        bars[player.opponent.index]++;
      }
      points[step.to] += sign;
    }
    return Board._(
      List.unmodifiable(points),
      List.unmodifiable(bars),
      List.unmodifiable(offs),
    );
  }

  /// Identifies the position; two boards with the same key are equal.
  String get key => '${_points.join(',')}|${_bar.join(',')}|${_off.join(',')}';
}

/// One checker moved with one die. White's bar is 25 and its off position 0,
/// black's bar is 0 and its off position 25, as both continue the point scale.
class Step {
  const Step({required this.from, required this.to, required this.die});

  final int from;
  final int to;
  final int die;

  static int barOf(Player player) => player == Player.white ? 25 : 0;

  static int offOf(Player player) => player == Player.white ? 0 : 25;

  bool isEntering(Player player) => from == barOf(player);

  bool isBearingOff(Player player) => to == offOf(player);
}
