import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Number of checkers a player has on the board, on the bar and off.
int total(Board board, Player player) {
  var sum = board.bar(player) + board.off(player);
  for (var point = 1; point <= Board.pointCount; point++) {
    sum += board.count(player, point);
  }
  return sum;
}

void main() {
  group('Aufstellung:', () {
    test('A-102: Startaufstellung – erwartet: '
        'Beide Spieler haben 15 Steine auf den richtigen Zungen', () {
      final board = Board.start();

      expect(total(board, Player.white), 15);
      expect(total(board, Player.black), 15);
      for (final MapEntry(key: point, value: count) in {
        24: 2,
        13: 5,
        8: 3,
        6: 5,
      }.entries) {
        expect(board.count(Player.white, point), count);
        expect(board.count(Player.black, 25 - point), count);
      }
    });
  });

  group('Ziehen:', () {
    test('A-104: Zugrichtung – erwartet: '
        'Weiß zieht zu niedrigeren, Schwarz zu höheren Zungen', () {
      final white = legalSteps(Board.start(), Player.white, 3);
      final black = legalSteps(Board.start(), Player.black, 3);

      expect(white.every((step) => step.to < step.from), isTrue);
      expect(black.every((step) => step.to > step.from), isTrue);
    });

    test('A-104: Besetzte Zunge – erwartet: '
        'Auf eine Zunge mit zwei gegnerischen Steinen darf niemand ziehen', () {
      final board = Board.fromCounts(white: const {10: 2}, black: const {7: 2});

      final steps = legalSteps(board, Player.white, 3);

      expect(steps, isEmpty);
    });

    test('A-105: Schlagen – erwartet: '
        'Ein einzelner gegnerischer Stein kommt auf die Bar', () {
      final board = Board.fromCounts(white: const {10: 1}, black: const {7: 1});

      final step = legalSteps(board, Player.white, 3).single;
      final result = board.apply(Player.white, step);

      expect(result.count(Player.white, 7), 1);
      expect(result.count(Player.black, 7), 0);
      expect(result.bar(Player.black), 1);
    });

    test('A-106: Bar zuerst – erwartet: '
        'Mit einem Stein auf der Bar ist nur das Einsetzen erlaubt', () {
      final board = Board.fromCounts(
        white: const {13: 5},
        black: const {1: 2},
        whiteBar: 1,
      );

      final steps = legalSteps(board, Player.white, 3);

      expect(steps.single.isEntering(Player.white), isTrue);
      expect(steps.single.to, 22);
    });

    test('A-106: Einsetzen blockiert – erwartet: '
        'Ist die Zunge besetzt, verfällt der Zug', () {
      final board = Board.fromCounts(
        white: const {13: 5},
        black: const {22: 2, 19: 2},
        whiteBar: 1,
      );

      expect(legalPlays(board, Player.white, const Dice(3, 6)), isEmpty);
    });
  });

  group('Zugpflicht:', () {
    test('A-107: Pasch – erwartet: Ein Pasch ergibt vier Züge', () {
      final play = legalPlays(
        Board.start(),
        Player.white,
        const Dice(3, 3),
      ).first;

      expect(play.steps, hasLength(4));
    });

    test('A-107: Beide Würfel – erwartet: '
        'Geht es nur in einer Reihenfolge, muss sie gespielt werden', () {
      // The 6 is blocked at first and only works after the 2.
      final board = Board.fromCounts(
        white: const {20: 1},
        black: const {14: 2},
      );

      final play = legalPlays(board, Player.white, const Dice(6, 2)).single;

      expect(play.steps, hasLength(2));
      expect(play.result.count(Player.white, 12), 1);
    });

    test('A-107: Höherer Würfel – erwartet: '
        'Geht nur einer der beiden, muss der höhere gespielt werden', () {
      final board = Board.fromCounts(
        white: const {7: 1},
        black: const {1: 2, 2: 2, 3: 2, 5: 2},
      );

      final plays = legalPlays(board, Player.white, const Dice(3, 1));

      expect(plays.single.steps.single.die, 3);
    });

    test('A-107: Pasch teilweise – erwartet: '
        'Es werden so viele Züge gespielt wie möglich', () {
      final board = Board.fromCounts(white: const {18: 1}, black: const {3: 2});

      final plays = legalPlays(board, Player.white, const Dice(5, 5));

      expect(plays.single.steps, hasLength(2));
    });
  });

  group('Auswürfeln:', () {
    test('A-108: Nur aus dem Heimfeld – erwartet: '
        'Mit einem Stein außerhalb darf niemand auswürfeln', () {
      final board = Board.fromCounts(white: const {7: 1, 6: 2});

      final steps = legalSteps(board, Player.white, 6);

      expect(steps.any((step) => step.isBearingOff(Player.white)), isFalse);
    });

    test('A-108: Passender Würfel – erwartet: '
        'Eine 6 nimmt den Stein von Zunge 6', () {
      final board = Board.fromCounts(white: const {6: 1, 3: 2});

      final steps = legalSteps(board, Player.white, 6);

      expect(steps.single.from, 6);
      expect(steps.single.isBearingOff(Player.white), isTrue);
    });

    test('A-108: Zu hoher Würfel – erwartet: '
        'Ohne Stein auf höheren Zungen geht der höchste Stein heraus', () {
      final board = Board.fromCounts(white: const {4: 1, 2: 2});

      final steps = legalSteps(board, Player.white, 6);

      expect(steps.single.from, 4);
      expect(steps.single.isBearingOff(Player.white), isTrue);
    });

    test('A-108: Stein dahinter – erwartet: '
        'Liegt ein Stein weiter hinten, muss dieser ziehen', () {
      final board = Board.fromCounts(white: const {6: 1, 3: 1});

      final steps = legalSteps(board, Player.white, 4);

      expect(steps.single.from, 6);
      expect(steps.single.to, 2);
    });

    test('A-108: Geschlagener Stein – erwartet: '
        'Steht ein Stein auf der Bar, darf niemand auswürfeln', () {
      final board = Board.fromCounts(white: const {6: 2}, whiteBar: 1);

      final steps = legalSteps(board, Player.white, 6);

      expect(steps.every((step) => step.isEntering(Player.white)), isTrue);
    });

    test('A-108: Auswürfeln ist freiwillig – erwartet: '
        'Neben dem Auswürfeln ist auch ein normaler Zug erlaubt', () {
      final board = Board.fromCounts(white: const {6: 1, 5: 1});

      final steps = legalSteps(board, Player.white, 5);

      expect(steps.map((step) => step.from), containsAll([6, 5]));
    });

    test('A-108: Schwarz spiegelt Weiß – erwartet: '
        'Schwarz würfelt von den Zungen 19 bis 24 aus', () {
      final board = Board.fromCounts(black: const {19: 1, 22: 2});

      final steps = legalSteps(board, Player.black, 6);

      expect(steps.single.from, 19);
      expect(steps.single.isBearingOff(Player.black), isTrue);
    });
  });
}
