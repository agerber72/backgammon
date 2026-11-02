// Plays random games and writes positions for legal_plays.py. Besides a general
// sample it collects rare situations, which plain sampling would hardly reach.
// Run: dart run tools/gnubg/export_positions.dart <output.json>
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/domain/position_id.dart';

const games = 400;
const generalLimit = 1000;
const bearingOffLimit = 400;
const higherDieLimit = 80;
const lastOffCount = 12;

class SeededRoller implements DiceRoller {
  SeededRoller(this.random);

  final Random random;

  @override
  int roll() => random.nextInt(6) + 1;
}

Map<String, int> countsOf(Board board, Player player) => {
  for (var point = 1; point <= Board.pointCount; point++)
    if (board.count(player, point) > 0) '$point': board.count(player, point),
};

/// True if each die alone is playable but not both, so the higher one must go.
bool forcesHigherDie(Board board, Player player, Dice dice) {
  final plays = legalPlays(board, player, dice);
  return plays.isNotEmpty &&
      plays.every((play) => play.steps.length == 1) &&
      legalSteps(board, player, dice.first).isNotEmpty &&
      legalSteps(board, player, dice.second).isNotEmpty;
}

void main(List<String> arguments) {
  final random = Random(20261102);
  final roller = SeededRoller(random);
  final seen = <String>{};
  final entries = <Map<String, Object>>[];
  var general = 0;
  var bearingOff = 0;
  var higherDie = 0;

  bool add(Board board, Player turn, Dice dice) {
    final id = positionId(board, turn);
    if (!seen.add('$id/${dice.first}${dice.second}')) {
      return false;
    }
    entries.add({
      'id': id,
      'turn': turn.name,
      'dice': [dice.first, dice.second],
      'white': countsOf(board, Player.white),
      'black': countsOf(board, Player.black),
      'whiteBar': board.bar(Player.white),
      'blackBar': board.bar(Player.black),
      'whiteOff': board.off(Player.white),
      'blackOff': board.off(Player.black),
    });
    return true;
  }

  for (var i = 0; i < games; i++) {
    var game = Game.start(roller);
    while (game.phase != GamePhase.finished) {
      if (game.phase == GamePhase.awaitingRoll) {
        game = game.roll(roller);
        continue;
      }
      final board = game.board;
      final turn = game.turn;
      final offs = board.off(Player.white) + board.off(Player.black);
      final open =
          board.off(Player.white) < lastOffCount &&
          board.off(Player.black) < lastOffCount;
      if (open) {
        if (general < generalLimit &&
            random.nextInt(4) == 0 &&
            add(board, turn, game.dice!)) {
          general++;
        }
        if (offs > 0 &&
            bearingOff < bearingOffLimit &&
            random.nextBool() &&
            add(board, turn, game.dice!)) {
          bearingOff++;
        }
        for (var high = 2; high <= 6; high++) {
          for (var low = 1; low < high; low++) {
            final dice = Dice(high, low);
            if (higherDie < higherDieLimit &&
                forcesHigherDie(board, turn, dice) &&
                add(board, turn, dice)) {
              higherDie++;
            }
          }
        }
      }
      final plays = game.plays;
      game = plays.isEmpty
          ? game.pass()
          : game.play(plays[random.nextInt(plays.length)]);
    }
  }
  File(arguments.single).writeAsStringSync(jsonEncode(entries));
  stdout.writeln(
    '${entries.length} positions: general $general, '
    'bearing off $bearingOff, higher die $higherDie',
  );
}
