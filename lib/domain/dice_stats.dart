import 'board.dart';
import 'dice.dart';

/// Counts the dice of one player.
class PlayerDiceCount {
  PlayerDiceCount({List<int>? faces, this.rolls = 0, this.doubles = 0})
    : faces = faces ?? List.filled(6, 0);

  factory PlayerDiceCount.fromJson(Map<String, dynamic> json) =>
      PlayerDiceCount(
        faces: (json['faces'] as List<dynamic>).cast<int>().toList(),
        rolls: json['rolls'] as int,
        doubles: json['doubles'] as int,
      );

  /// How often each face from 1 to 6 came up.
  final List<int> faces;
  int rolls;
  int doubles;

  int get dice => faces.fold(0, (sum, count) => sum + count);

  Map<String, Object> toJson() => {
    'faces': faces,
    'rolls': rolls,
    'doubles': doubles,
  };
}

/// Shows openly how the dice fell, for one game or for all games.
class DiceStats {
  DiceStats({PlayerDiceCount? white, PlayerDiceCount? black})
    : white = white ?? PlayerDiceCount(),
      black = black ?? PlayerDiceCount();

  factory DiceStats.fromJson(Map<String, dynamic> json) => DiceStats(
    white: PlayerDiceCount.fromJson(json['white'] as Map<String, dynamic>),
    black: PlayerDiceCount.fromJson(json['black'] as Map<String, dynamic>),
  );

  final PlayerDiceCount white;
  final PlayerDiceCount black;

  PlayerDiceCount of(Player player) => player == Player.white ? white : black;

  void addRoll(Player player, Dice dice) {
    final count = of(player);
    count.faces[dice.first - 1]++;
    count.faces[dice.second - 1]++;
    count.rolls++;
    if (dice.isDouble) {
      count.doubles++;
    }
  }

  /// In the opening each player throws one die, which is no complete roll.
  void addOpening(Dice dice) {
    white.faces[dice.first - 1]++;
    black.faces[dice.second - 1]++;
  }

  Map<String, Object> toJson() => {
    'white': white.toJson(),
    'black': black.toJson(),
  };
}
