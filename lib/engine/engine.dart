import 'dart:math';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/game.dart';
import '../domain/move_generator.dart';
import 'evaluation.dart';

enum Difficulty {
  easy(noise: 0.5, doubleAt: 0.82, takeAt: 0.35),
  medium(noise: 0.18, doubleAt: 0.74, takeAt: 0.28),
  hard(noise: 0, doubleAt: 0.70, takeAt: 0.25);

  const Difficulty({
    required this.noise,
    required this.doubleAt,
    required this.takeAt,
  });

  /// Random error per rated play, which makes the computer misjudge moves.
  final double noise;

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
    Play? best;
    var bestValue = double.negativeInfinity;
    for (final play in legalPlays(board, player, dice)) {
      final value = evaluate(play.result, player) + _noise(difficulty);
      if (value > bestValue) {
        bestValue = value;
        best = play;
      }
    }
    return best!;
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
