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

  group('Kombinierter Zug:', () {
    test('A-215: Freier Weg – erwartet: '
        'Bei 5-1 sind die Einzelziele und das Summenziel erreichbar', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1, 3: 1}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths.keys, unorderedEquals([15, 19, 14]));
      expect(paths[14], hasLength(2));
    });

    test('A-215: Erst 5 gesperrt – erwartet: '
        'Der Zug geht über die 1 zuerst', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {15: 2}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), [1, 5]);
    });

    test('A-215: Erst 1 gesperrt – erwartet: '
        'Der Zug geht über die 5 zuerst', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {19: 2}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), [5, 1]);
    });

    test('A-215: Beide Wege gesperrt – erwartet: '
        'Das Summenziel wird nicht angeboten', () {
      final paths = pathsFrom(
        Board.fromCounts(
          white: const {20: 1, 10: 1},
          black: const {19: 2, 15: 2},
        ),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths, isNot(contains(14)));
    });

    test('A-215: Pasch – erwartet: '
        'Ein Pasch bietet ein- bis vierfach an, soweit der Weg frei ist', () {
      final free = pathsFrom(
        Board.fromCounts(white: const {20: 1}),
        Player.white,
        const Dice(3, 3),
        const [],
        20,
      );
      final blocked = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {11: 2}),
        Player.white,
        const Dice(3, 3),
        const [],
        20,
      );

      expect(free.keys, unorderedEquals([17, 14, 11, 8]));
      expect(free[8], hasLength(4));
      expect(blocked.keys, unorderedEquals([17, 14]));
    });

    test('A-215: Pasch teilweise gezogen – erwartet: '
        'Nur die noch offenen Züge werden angeboten', () {
      const dice = Dice(3, 3);
      final board = Board.fromCounts(white: const {20: 1, 19: 1});
      final done = nextSteps(
        board,
        Player.white,
        dice,
        const [],
      ).where((step) => step.from == 19).take(1).toList();

      final paths = pathsFrom(board, Player.white, dice, done, 20);

      expect(paths.keys, unorderedEquals([17, 14, 11]));
    });

    test('A-215: Schlag unterwegs, erst 1 – erwartet: '
        'Gibt es zwei Wege, nimmt der Zug den, der den Blot schlägt', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {19: 1}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), [1, 5]);
    });

    test('A-215: Schlag unterwegs, erst 5 – erwartet: '
        'Gibt es zwei Wege, nimmt der Zug den, der den Blot schlägt', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {15: 1}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), [5, 1]);
    });

    test('A-215: Kein Blot unterwegs – erwartet: '
        'Beide Reihenfolgen bleiben möglich, und der Zug kommt am Ziel an', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {1: 2}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), unorderedEquals([5, 1]));
    });

    test('A-215: Geschlagen wird, wenn es nur so geht – erwartet: '
        'Ist der andere Weg gesperrt, führt der Zug über den Blot', () {
      final paths = pathsFrom(
        Board.fromCounts(white: const {20: 1}, black: const {19: 1, 15: 2}),
        Player.white,
        const Dice(5, 1),
        const [],
        20,
      );

      expect(paths[14]!.map((step) => step.die), [1, 5]);
    });
  });
}
