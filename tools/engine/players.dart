// Simple opponents for measuring the levels; they are not part of the app.
import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/engine/engine.dart';

/// Plays any legal play.
class RandomPlayer implements Engine {
  RandomPlayer(this.random);

  final Random random;

  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async {
    final plays = legalPlays(board, player, dice);
    return plays[random.nextInt(plays.length)];
  }

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async => false;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async => true;
}

/// A beginner: brings the rearmost checkers forward as far as possible and
/// pays no attention to blots, hits or points.
class BeginnerPlayer implements Engine {
  BeginnerPlayer(this.random);

  final Random random;

  static int _spread(Board board, Player player) {
    var total = board.bar(player) * 25 * 25;
    for (var point = 1; point <= Board.pointCount; point++) {
      final distance = Board.distance(player, point);
      total += board.count(player, point) * distance * distance;
    }
    return total;
  }

  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async {
    final plays = legalPlays(board, player, dice)..shuffle(random);
    var best = plays.first;
    for (final play in plays) {
      if (_spread(play.result, player) < _spread(best.result, player)) {
        best = play;
      }
    }
    return best;
  }

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async => false;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async => true;
}

class SeededRoller implements DiceRoller {
  SeededRoller(this.random);

  final Random random;

  @override
  int roll() => random.nextInt(6) + 1;
}

/// Lets [first] at [firstLevel] play [second] at [secondLevel], with the
/// doubling cube, and returns the points [first] won and lost.
Future<({int won, int lost, int games})> playMatch(
  Engine first,
  Difficulty firstLevel,
  Engine second,
  Difficulty secondLevel,
  int games, {
  int seed = 11,
}) async {
  final roller = SeededRoller(Random(seed));
  var won = 0;
  var lost = 0;
  var gamesWon = 0;
  for (var i = 0; i < games; i++) {
    // The sides swap so that color has no influence.
    final firstPlays = i.isEven ? Player.white : Player.black;
    Engine engineOf(Player player) => player == firstPlays ? first : second;
    Difficulty levelOf(Player player) =>
        player == firstPlays ? firstLevel : secondLevel;
    var game = Game.start(roller);
    while (game.phase != GamePhase.finished) {
      final turn = game.turn;
      switch (game.phase) {
        case GamePhase.awaitingRoll:
          game = await engineOf(turn).wantsToDouble(game, levelOf(turn))
              ? game.offerDouble()
              : game.roll(roller);
        case GamePhase.awaitingDoubleResponse:
          final responder = turn.opponent;
          game =
              await engineOf(responder).acceptsDouble(game, levelOf(responder))
              ? game.acceptDouble()
              : game.refuseDouble();
        case GamePhase.awaitingPlay:
          game = game.plays.isEmpty
              ? game.pass()
              : game.play(
                  await engineOf(turn)
                      .choosePlay(game.board, turn, game.dice!, levelOf(turn)),
                );
        case GamePhase.finished:
          break;
      }
    }
    final result = game.result!;
    if (result.winner == firstPlays) {
      won += result.points;
      gamesWon++;
    } else {
      lost += result.points;
    }
  }
  return (won: won, lost: lost, games: gamesWon);
}
