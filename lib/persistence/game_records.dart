import '../domain/board.dart';
import '../engine/engine.dart';

/// One finished game against the computer.
class GameRecord {
  const GameRecord({
    required this.finishedAt,
    required this.difficulty,
    required this.color,
    required this.playTime,
    required this.points,
    required this.computerPoints,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    finishedAt: DateTime.parse(json['finishedAt'] as String),
    difficulty: Difficulty.values.byName(json['difficulty'] as String),
    color: Player.values.byName(json['color'] as String),
    playTime: Duration(seconds: json['playSeconds'] as int),
    points: json['points'] as int,
    computerPoints: json['computerPoints'] as int,
  );

  final DateTime finishedAt;
  final Difficulty difficulty;

  /// The person's color.
  final Player color;

  /// Time the app was open during the game.
  final Duration playTime;

  /// Points the person won; zero for a lost game.
  final int points;

  /// Points the computer won; zero for a won game.
  final int computerPoints;

  bool get won => points > 0;

  Map<String, Object?> toJson() => {
    'finishedAt': finishedAt.toIso8601String(),
    'difficulty': difficulty.name,
    'color': color.name,
    'playSeconds': playTime.inSeconds,
    'points': points,
    'computerPoints': computerPoints,
  };
}

/// Sums over all games of one level.
class LevelTotals {
  const LevelTotals({
    this.games = 0,
    this.wins = 0,
    this.points = 0,
    this.computerPoints = 0,
  });

  factory LevelTotals.fromJson(Map<String, dynamic> json) => LevelTotals(
    games: json['games'] as int,
    wins: json['wins'] as int,
    points: json['points'] as int,
    computerPoints: json['computerPoints'] as int,
  );

  final int games;
  final int wins;
  final int points;
  final int computerPoints;

  LevelTotals operator +(LevelTotals other) => LevelTotals(
    games: games + other.games,
    wins: wins + other.wins,
    points: points + other.points,
    computerPoints: computerPoints + other.computerPoints,
  );

  Map<String, Object?> toJson() => {
    'games': games,
    'wins': wins,
    'points': points,
    'computerPoints': computerPoints,
  };
}

/// The personal leaderboard: the latest games, newest first, and the totals
/// of all games per level. The totals keep counting when old games drop out
/// of the list.
class GameRecords {
  GameRecords({
    List<GameRecord> games = const [],
    Map<Difficulty, LevelTotals> totals = const {},
  }) : _games = List.of(games),
       _totals = Map.of(totals);

  factory GameRecords.fromJson(Map<String, dynamic> json) => GameRecords(
    games: [
      for (final game in json['games'] as List<dynamic>)
        GameRecord.fromJson(game as Map<String, dynamic>),
    ],
    totals: (json['totals'] as Map<String, dynamic>).map(
      (level, totals) => MapEntry(
        Difficulty.values.byName(level),
        LevelTotals.fromJson(totals as Map<String, dynamic>),
      ),
    ),
  );

  /// How many games the list keeps.
  static const maxGames = 100;

  final List<GameRecord> _games;
  final Map<Difficulty, LevelTotals> _totals;

  /// Newest first.
  List<GameRecord> get games => List.unmodifiable(_games);

  LevelTotals totalsOf(Difficulty difficulty) =>
      _totals[difficulty] ?? const LevelTotals();

  LevelTotals get total =>
      Difficulty.values.map(totalsOf).reduce((sum, next) => sum + next);

  void add(GameRecord record) {
    _games.insert(0, record);
    if (_games.length > maxGames) {
      _games.removeRange(maxGames, _games.length);
    }
    _totals[record.difficulty] =
        totalsOf(record.difficulty) +
        LevelTotals(
          games: 1,
          wins: record.won ? 1 : 0,
          points: record.points,
          computerPoints: record.computerPoints,
        );
  }

  Map<String, Object?> toJson() => {
    'games': [for (final game in _games) game.toJson()],
    'totals': {
      for (final entry in _totals.entries) entry.key.name: entry.value.toJson(),
    },
  };
}
