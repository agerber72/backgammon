/// What the board shows. The prototype shows the starting position until the
/// rule engine provides the real game state.
class BoardScene {
  const BoardScene({
    required this.checkers,
    required this.off,
    required this.diceColor,
    required this.dice,
    required this.cubeValue,
    this.cubeOwner,
  });

  /// Checker count per point, grouped by color.
  final Map<String, Map<int, int>> checkers;

  /// Borne-off checkers per color, shown on edge in the tray.
  final Map<String, int> off;
  final String diceColor;
  final List<int> dice;
  final int cubeValue;

  /// Player holding the cube; it waits in the tray until the first double.
  final String? cubeOwner;

  static const sample = BoardScene(
    checkers: {
      'white': {24: 2, 13: 5, 8: 3, 6: 5},
      'black': {1: 2, 12: 5, 17: 3, 19: 5},
    },
    off: {},
    diceColor: 'white',
    dice: [],
    cubeValue: 64,
  );
}
