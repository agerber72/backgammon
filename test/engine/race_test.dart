import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:backgammon/engine/race.dart';
import 'package:flutter_test/flutter_test.dart';

class SeededRoller implements DiceRoller {
  SeededRoller(this.random);

  final Random random;

  @override
  int roll() => random.nextInt(6) + 1;
}

/// A race position for white: 15 checkers spread over the lowest [spread]
/// points, with black far away so that the checkers never meet.
Board randomRace(Random random, {int spread = 12, int off = 0}) {
  final white = <int, int>{};
  for (var checker = 0; checker < Board.checkersPerPlayer - off; checker++) {
    final point = random.nextInt(spread) + 1;
    white[point] = (white[point] ?? 0) + 1;
  }
  return Board.fromCounts(white: white, black: const {24: 15}, whiteOff: off);
}

int checkersOutsideHome(Board board, Player player) {
  var outside = board.bar(player);
  for (var point = 1; point <= Board.pointCount; point++) {
    if (!Board.isHome(player, point)) {
      outside += board.count(player, point);
    }
  }
  return outside;
}

/// Rolls until white has borne off all checkers, with one strategy.
Future<int> rollsToFinish(
  Board start,
  int seed,
  Future<Play> Function(Board board, Dice dice) choose,
) async {
  final roller = SeededRoller(Random(seed));
  var board = start;
  var rolls = 0;
  while (board.off(Player.white) < Board.checkersPerPlayer) {
    final dice = Dice.rolledBy(roller);
    rolls++;
    if (legalPlays(board, Player.white, dice).isEmpty) {
      continue;
    }
    board = (await choose(board, dice)).result;
  }
  return rolls;
}

void main() {
  test('A-410: Für jeden Würfel einen Stein – erwartet: '
      'Im Heimfeld würfelt jeder Zug so viele Steine aus wie möglich', () {
    final random = Random(7);
    for (var position = 0; position < 300; position++) {
      final board = randomRace(random, spread: 6, off: random.nextInt(10));
      final dice = Dice.rolledBy(SeededRoller(random));
      final plays = legalPlays(board, Player.white, dice);
      if (plays.isEmpty) {
        continue;
      }
      final most = plays
          .map((play) => play.result.off(Player.white))
          .reduce(max);
      final chosen = racePlay(board, Player.white, dice);
      expect(chosen.result.off(Player.white), most, reason: board.key);
    }
  });

  test('A-410: Schnell ins Heimfeld – erwartet: '
      'Kein anderer Zug bringt mehr Steine ins Heimfeld', () {
    final random = Random(11);
    for (var position = 0; position < 300; position++) {
      final board = randomRace(random, spread: 12);
      final dice = Dice.rolledBy(SeededRoller(random));
      final plays = legalPlays(board, Player.white, dice);
      if (plays.isEmpty || board.allHome(Player.white)) {
        continue;
      }
      final fewest = plays
          .map((play) => checkersOutsideHome(play.result, Player.white))
          .reduce(min);
      final chosen = racePlay(board, Player.white, dice);
      expect(
        checkersOutsideHome(chosen.result, Player.white),
        fewest,
        reason: board.key,
      );
    }
  });

  test('A-410: Weniger Würfe bis zum Ende – erwartet: '
      'Im Schnitt nicht mehr Würfe als die stärkste Stufe bisher', () async {
    final engine = HeuristicEngine(random: Random(1));
    final random = Random(3);
    var race = 0;
    var before = 0;
    const games = 200;
    for (var game = 0; game < games; game++) {
      final start = randomRace(random);
      final seed = random.nextInt(1 << 30);
      race += await rollsToFinish(
        start,
        seed,
        (board, dice) async => racePlay(board, Player.white, dice),
      );
      before += await rollsToFinish(
        start,
        seed,
        (board, dice) =>
            engine.choosePlay(board, Player.white, dice, Difficulty.hard),
      );
    }
    // Printed for the record in docs/roadmap-und-anforderungen.md.
    // ignore: avoid_print
    print('Rolls per race: ${race / games} now, ${before / games} before');
    expect(race, lessThanOrEqualTo(before));
  });
}
