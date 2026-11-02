import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/dice_stats.dart';
import '../domain/game.dart';
import '../engine/engine.dart';

/// Everything that outlives the app: the running game and the settings.
class Session {
  Session({
    required this.totalStats,
    required this.gameStats,
    this.game,
    this.human,
    this.difficulty = Difficulty.medium,
    this.preferredHuman,
    this.preferredDifficulty,
    this.autoDelaySeconds = defaultAutoDelaySeconds,
  });

  static const defaultAutoDelaySeconds = 3;

  factory Session.fromJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>?;
    return Session(
      game: game == null ? null : _gameFromJson(game),
      human: _playerOf(json['human']),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      preferredHuman: _playerOf(json['preferredHuman']),
      preferredDifficulty: json['preferredDifficulty'] == null
          ? null
          : Difficulty.values.byName(json['preferredDifficulty'] as String),
      autoDelaySeconds:
          json['autoDelaySeconds'] as int? ?? defaultAutoDelaySeconds,
      gameStats: DiceStats.fromJson(json['gameStats'] as Map<String, dynamic>),
      totalStats: DiceStats.fromJson(
        json['totalStats'] as Map<String, dynamic>,
      ),
    );
  }

  /// Null if no game is running.
  final Game? game;
  final Player? human;
  final Difficulty difficulty;

  /// The settings for the next game.
  final Player? preferredHuman;
  final Difficulty? preferredDifficulty;

  /// Waiting time for automatic actions; 0 turns them off.
  final int autoDelaySeconds;
  final DiceStats gameStats;
  final DiceStats totalStats;

  Map<String, Object?> toJson() => {
    'game': game == null ? null : _gameToJson(game!),
    'human': human?.name,
    'difficulty': difficulty.name,
    'preferredHuman': preferredHuman?.name,
    'preferredDifficulty': preferredDifficulty?.name,
    'autoDelaySeconds': autoDelaySeconds,
    'gameStats': gameStats.toJson(),
    'totalStats': totalStats.toJson(),
  };

  static Player? _playerOf(Object? name) =>
      name == null ? null : Player.values.byName(name as String);

  static Map<String, int> _counts(Board board, Player player) => {
    for (var point = 1; point <= Board.pointCount; point++)
      if (board.count(player, point) > 0) '$point': board.count(player, point),
  };

  static Map<int, int> _pointsOf(Object? json) =>
      (json! as Map<String, dynamic>).map(
        (point, count) => MapEntry(int.parse(point), count as int),
      );

  static Map<String, Object?> _gameToJson(Game game) => {
    'white': _counts(game.board, Player.white),
    'black': _counts(game.board, Player.black),
    'whiteBar': game.board.bar(Player.white),
    'blackBar': game.board.bar(Player.black),
    'whiteOff': game.board.off(Player.white),
    'blackOff': game.board.off(Player.black),
    'turn': game.turn.name,
    'phase': game.phase.name,
    'dice': game.dice == null ? null : [game.dice!.first, game.dice!.second],
    'cubeValue': game.cube.value,
    'cubeOwner': game.cube.owner?.name,
  };

  static Game _gameFromJson(Map<String, dynamic> json) {
    final dice = json['dice'] as List<dynamic>?;
    return Game.at(
      board: Board.fromCounts(
        white: _pointsOf(json['white']),
        black: _pointsOf(json['black']),
        whiteBar: json['whiteBar'] as int,
        blackBar: json['blackBar'] as int,
        whiteOff: json['whiteOff'] as int,
        blackOff: json['blackOff'] as int,
      ),
      turn: Player.values.byName(json['turn'] as String),
      phase: GamePhase.values.byName(json['phase'] as String),
      dice: dice == null ? null : Dice(dice[0] as int, dice[1] as int),
      cube: Cube(
        value: json['cubeValue'] as int,
        owner: _playerOf(json['cubeOwner']),
      ),
    );
  }
}

abstract interface class SessionStore {
  Future<Session?> load();

  Future<void> save(Session session);
}

class SharedPreferencesSessionStore implements SessionStore {
  static const _key = 'session.v1';

  /// A missing or unreadable session counts as none, so that a damaged save
  /// never blocks the start of the app.
  @override
  Future<Session?> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final json = preferences.getString(_key);
      return json == null
          ? null
          : Session.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } on Exception {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(Session session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(session.toJson()));
  }
}
