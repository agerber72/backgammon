import 'dart:math';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/game.dart';
import '../domain/move_generator.dart';
import 'evaluation.dart';
import 'mistakes.dart';

enum Difficulty {
  easy(noise: 0.5, mistakeRate: 0.5, doubleAt: 0.95, takeAt: 0.1),
  medium(noise: 0.18, doubleAt: 0.74, takeAt: 0.28),
  hard(noise: 0, doubleAt: 0.70, takeAt: 0.25);

  const Difficulty({
    required this.noise,
    this.mistakeRate = 0,
    required this.doubleAt,
    required this.takeAt,
  });

  /// Random error per rated play, which makes the computer misjudge moves.
  final double noise;

  /// Share of turns with a typical beginner's mistake, see [Mistake].
  final double mistakeRate;

  /// Win chance from which it doubles, and below which it gives up a double.
  final double doubleAt;
  final double takeAt;
}

/// The computer opponent. Implementations can be swapped.
abstract interface class Engine {
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  );

  Future<bool> wantsToDouble(Game game, Difficulty difficulty);

  Future<bool> acceptsDouble(Game game, Difficulty difficulty);
}

/// Rates the position after every legal play with [evaluate]. A look-ahead over
/// the opponent's replies did not improve the play in measurements, so one
/// rating per play is enough, which is also fast enough for the web.
class HeuristicEngine implements Engine {
  HeuristicEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async {
    final plays = legalPlays(board, player, dice);
    if (difficulty.mistakeRate > 0 &&
        _random.nextDouble() < difficulty.mistakeRate) {
      final mistake = _mistake(board, player, plays);
      if (mistake != null) {
        return mistake;
      }
    }
    Play? best;
    var bestValue = double.negativeInfinity;
    for (final play in plays) {
      final value = evaluate(play.result, player) + _noise(difficulty);
      if (value > bestValue) {
        bestValue = value;
        best = play;
      }
    }
    return best!;
  }

  /// A play with a typical beginner's mistake, if the roll allows one.
  Play? _mistake(Board board, Player player, List<Play> plays) {
    var best = plays.first;
    var bestValue = double.negativeInfinity;
    for (final play in plays) {
      final value = evaluate(play.result, player);
      if (value > bestValue) {
        bestValue = value;
        best = play;
      }
    }
    final mistakes = [
      for (final play in plays)
        if (mistakeOf(board, player, best.result, play.result) != null) play,
    ];
    return mistakes.isEmpty ? null : mistakes[_random.nextInt(mistakes.length)];
  }

  double _noise(Difficulty difficulty) => difficulty.noise == 0
      ? 0
      : (_random.nextDouble() * 2 - 1) * difficulty.noise;

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async =>
      game.canDouble &&
      estimateWin(game.board, game.turn) >= difficulty.doubleAt;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async =>
      estimateWin(game.board, game.turn.opponent) >= difficulty.takeAt;
}
