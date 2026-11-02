import 'dart:convert';
import 'dart:io';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/domain/position_id.dart';
import 'package:flutter_test/flutter_test.dart';

Map<int, int> counts(dynamic json) => (json as Map<String, dynamic>).map(
  (point, count) => MapEntry(int.parse(point), count as int),
);

/// All boards a player can reach by taking one offered step after the other.
Set<String> reachable(Board start, Player player, Dice dice) {
  final finals = <String>{};
  final visited = <String>{};

  void walk(List<Step> done) {
    final reached = done.fold(start, (b, s) => b.apply(player, s));
    if (!visited.add('${reached.key}/${done.length}')) {
      return;
    }
    final steps = nextSteps(start, player, dice, done);
    if (steps.isEmpty) {
      if (done.isNotEmpty) {
        final board = done.fold(start, (b, s) => b.apply(player, s));
        finals.add(positionId(board, player.opponent));
      }
      return;
    }
    for (final step in steps) {
      walk([...done, step]);
    }
  }

  walk(const []);
  return finals;
}

void main() {
  test('A-202: Zug Stein für Stein – erwartet: '
      'Einzelne Schritte führen in allen Referenzstellungen genau zu den '
      'Zügen, die GNU Backgammon erlaubt, ohne Sackgasse', () {
    final entries = (jsonDecode(
      File('test/fixtures/gnubg_legal_plays.json').readAsStringSync(),
    ) as List<dynamic>).cast<Map<String, dynamic>>();

    for (final entry in entries) {
      final diceValues = entry['dice'] as List<dynamic>;
      final dice = Dice(diceValues[0] as int, diceValues[1] as int);
      final board = Board.fromCounts(
        white: counts(entry['white']),
        black: counts(entry['black']),
        whiteBar: entry['whiteBar'] as int,
        blackBar: entry['blackBar'] as int,
        whiteOff: entry['whiteOff'] as int,
        blackOff: entry['blackOff'] as int,
      );
      final player = entry['turn'] == 'white' ? Player.white : Player.black;

      expect(
        reachable(board, player, dice),
        (entry['expected'] as List<dynamic>).cast<String>().toSet(),
        reason: '${entry['id']} mit $diceValues',
      );
    }
  });

  test('A-107: Pasch Stein für Stein – erwartet: '
      'Mit einem Pasch lassen sich vier Schritte nacheinander setzen', () {
    final board = Board.start();
    final steps = <Step>[];
    for (var i = 0; i < 4; i++) {
      steps.add(nextSteps(board, Player.white, const Dice(3, 3), steps).first);
    }

    expect(steps, hasLength(4));
    expect(nextSteps(board, Player.white, const Dice(3, 3), steps), isEmpty);
  });
}
