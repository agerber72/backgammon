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

void main() {
  final entries = (jsonDecode(
    File('test/fixtures/gnubg_legal_plays.json').readAsStringSync(),
  ) as List<dynamic>).cast<Map<String, dynamic>>();

  test('A-702: Position-ID – erwartet: '
      'Die Startaufstellung ergibt die ID von GNU Backgammon', () {
    expect(positionId(Board.start(), Player.white), '4HPwATDgc/ABMA');
  });

  test('A-702: Erlaubte Züge – erwartet: '
      'In allen Referenzstellungen ergeben sich exakt dieselben Folgestellungen '
      'wie bei GNU Backgammon', () {
    expect(entries, isNotEmpty);
    for (final entry in entries) {
      final board = Board.fromCounts(
        white: counts(entry['white']),
        black: counts(entry['black']),
        whiteBar: entry['whiteBar'] as int,
        blackBar: entry['blackBar'] as int,
        whiteOff: entry['whiteOff'] as int,
        blackOff: entry['blackOff'] as int,
      );
      final player = entry['turn'] == 'white' ? Player.white : Player.black;
      final dice = entry['dice'] as List<dynamic>;

      final plays = legalPlays(
        board,
        player,
        Dice(dice[0] as int, dice[1] as int),
      );
      final results = plays
          .map((play) => positionId(play.result, player.opponent))
          .toSet();

      expect(
        results,
        (entry['expected'] as List<dynamic>).cast<String>().toSet(),
        reason: '${entry['id']} mit ${entry['dice']}',
      );
    }
  });
}
