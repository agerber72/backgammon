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
/// points. Black waits on the bar, so white leads the race and the checkers
/// never meet.
Board randomRace(Random random, {int spread = 12, int off = 0}) {
  final white = <int, int>{};
  for (var checker = 0; checker < Board.checkersPerPlayer - off; checker++) {
    final point = random.nextInt(spread) + 1;
    white[point] = (white[point] ?? 0) + 1;
  }
  return Board.fromCounts(white: white, blackBar: 15, whiteOff: off);
}

/// A race that white has lost: black has borne off some checkers and keeps
/// the rest on its three lowest points, white is spread over the board up to
/// black's home board, without contact.
Board lostRace(Random random) {
  final black = <int, int>{};
  final blackOff = random.nextInt(10);
  for (
    var checker = 0;
    checker < Board.checkersPerPlayer - blackOff;
    checker++
  ) {
    final point = Board.pointAt(Player.black, random.nextInt(3) + 1);
    black[point] = (black[point] ?? 0) + 1;
  }
  final white = <int, int>{};
  final reach = random.nextInt(21) + 1;
  for (var checker = 0; checker < Board.checkersPerPlayer; checker++) {
    final point = random.nextInt(reach) + 1;
    white[point] = (white[point] ?? 0) + 1;
  }
  return Board.fromCounts(white: white, black: black, blackOff: blackOff);
}

/// Points white wins with both sides playing to the end, black with
/// [racePlay] and white with [choose]: 1 for a win, -1, -2 or -3 for a loss.
int playOut(
  Board start,
  int seed,
  Player first,
  Play Function(Board board, Dice dice) choose,
) {
  final roller = SeededRoller(Random(seed));
  var board = start;
  var turn = first;
  while (true) {
    final dice = Dice.rolledBy(roller);
    if (legalPlays(board, turn, dice).isNotEmpty) {
      board = turn == Player.white
          ? choose(board, dice).result
          : racePlay(board, turn, dice).result;
    }
    if (board.off(Player.white) == Board.checkersPerPlayer) {
      return 1;
    }
    if (board.off(Player.black) == Board.checkersPerPlayer) {
      if (board.off(Player.white) > 0) {
        return -1;
      }
      final inBlackHome =
          board.bar(Player.white) > 0 ||
          [
            for (var distance = 1; distance <= Board.homeSize; distance++)
              board.count(Player.white, Board.pointAt(Player.black, distance)),
          ].any((count) => count > 0);
      return inBlackHome ? -3 : -2;
    }
    turn = turn.opponent;
  }
}

/// The play rule before A-411: always race as fast as possible.
Play fastestPlay(Board board, Dice dice) {
  final plays = legalPlays(board, Player.white, dice);
  return plays.reduce(
    (best, play) =>
        raceScore(play.result, Player.white) >
            raceScore(best.result, Player.white)
        ? play
        : best,
  );
}

/// Pips white still needs until no checker stands in black's home board.
int pipsInBlackHome(Board board) {
  var pips = board.bar(Player.white) * 7;
  for (var point = 19; point <= Board.pointCount; point++) {
    pips += board.count(Player.white, point) * (point - 18);
  }
  return pips;
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

  test('A-411: Backgammon abwenden – erwartet: '
      'Der Nachzügler verlässt das Heimfeld des Gegners, statt ein freies '
      'Feld 6 zu besetzen', () {
    final board = Board.fromCounts(
      white: const {19: 1, 7: 1, 5: 7, 4: 6},
      black: const {24: 2, 23: 1},
      blackOff: 12,
    );
    final play = racePlay(board, Player.white, const Dice(1, 1));
    expect(pipsInBlackHome(play.result), 0);
  });

  test('A-411: Gammon retten – erwartet: '
      'Der letzte Stein kommt so heim, dass 35 von 36 Würfen sofort einen '
      'Stein abtragen, statt 31 beim schnellsten Rennen', () {
    final board = Board.fromCounts(
      white: const {10: 1, 6: 7, 5: 7},
      black: const {24: 2},
      blackOff: 13,
    );
    final play = racePlay(board, Player.white, const Dice(4, 3));
    expect(play.result.count(Player.white, 3), 1);
    expect(play.result.count(Player.white, 6), 7);
  });

  test('A-411: Gammon retten – erwartet: '
      'Mit einem Stein vom Brett trägt die verlorene Seite sofort ab', () {
    final board = Board.fromCounts(
      white: const {6: 10, 5: 5},
      black: const {24: 1},
      blackOff: 14,
    );
    final play = racePlay(board, Player.white, const Dice(6, 1));
    expect(play.result.off(Player.white), greaterThan(0));
  });

  test('A-411: Backgammon zuerst – erwartet: '
      'In jeder verlorenen Stellung bleibt so wenig wie möglich im Heimfeld '
      'des Gegners', () {
    final random = Random(5);
    var checked = 0;
    for (var position = 0; position < 400; position++) {
      final board = lostRace(random);
      if (board.hasContact || !isRaceLost(board, Player.white)) {
        continue;
      }
      final dice = Dice.rolledBy(SeededRoller(random));
      final plays = legalPlays(board, Player.white, dice);
      if (plays.isEmpty) {
        continue;
      }
      checked++;
      final chosen = racePlay(board, Player.white, dice);
      final leastBackgammon = plays
          .map((play) => pipsInBlackHome(play.result))
          .reduce(min);
      expect(
        pipsInBlackHome(chosen.result),
        leastBackgammon,
        reason: board.key,
      );
    }
    expect(checked, greaterThan(100));
  });

  test('A-411: Schaden begrenzen – erwartet: '
      'Die verlorene Seite verliert im Schnitt weniger Punkte als mit dem '
      'schnellsten Rennen', () {
    final random = Random(13);
    var saving = 0;
    var fastest = 0;
    var games = 0;
    final losses = {
      'now': <int>[0, 0, 0],
      'before': <int>[0, 0, 0],
    };
    void count(String rule, int points) {
      if (points < 0) {
        losses[rule]![-points - 1]++;
      }
    }

    while (games < 1000) {
      final start = lostRace(random);
      if (start.hasContact || !isRaceLost(start, Player.white)) {
        continue;
      }
      games++;
      final seed = random.nextInt(1 << 30);
      final first = random.nextBool() ? Player.white : Player.black;
      final now = playOut(
        start,
        seed,
        first,
        (board, dice) => racePlay(board, Player.white, dice),
      );
      final before = playOut(start, seed, first, fastestPlay);
      saving += now;
      fastest += before;
      count('now', now);
      count('before', before);
    }
    // Printed for the record in docs/roadmap-und-anforderungen.md.
    // ignore: avoid_print
    print(
      'Points per lost race: ${saving / games} now, ${fastest / games} '
      'before; single, gammon, backgammon: ${losses['now']} now, '
      '${losses['before']} before',
    );
    expect(saving, greaterThan(fastest));
  });
}
