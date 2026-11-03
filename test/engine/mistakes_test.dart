import 'package:backgammon/domain/board.dart';
import 'package:backgammon/engine/mistakes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('A-408: Typische Fehler', () {
    test('A-408: Treffer ausgelassen – erwartet: '
        'Schlägt der beste Zug und dieser nicht, gilt das als Fehler', () {
      final start = Board.fromCounts(
        white: const {13: 2},
        black: const {10: 1, 24: 2},
      );
      final best = Board.fromCounts(
        white: const {13: 1, 10: 1},
        black: const {24: 2},
        blackBar: 1,
      );
      final play = Board.fromCounts(
        white: const {13: 1, 9: 1},
        black: const {10: 1, 24: 2},
      );

      expect(mistakeOf(start, Player.white, best, play), Mistake.missedHit);
    });

    test('A-408: Punkt aufgebrochen – erwartet: '
        'Gibt der Zug einen fertigen Punkt auf, den der beste Zug hält, '
        'gilt das als Fehler', () {
      final start = Board.fromCounts(
        white: const {13: 1, 8: 2, 6: 2},
        black: const {24: 2},
      );
      final best = Board.fromCounts(
        white: const {10: 1, 8: 2, 6: 2},
        black: const {24: 2},
      );
      final play = Board.fromCounts(
        white: const {13: 1, 8: 1, 6: 2, 4: 1},
        black: const {24: 2},
      );

      expect(mistakeOf(start, Player.white, best, play), Mistake.brokePoint);
    });

    test('A-408: Stein ungeschützt – erwartet: '
        'Lässt der Zug Steine offen, die der beste Zug deckt, gilt das als '
        'Fehler', () {
      final start = Board.fromCounts(
        white: const {14: 1, 10: 1, 6: 2},
        black: const {1: 2},
      );
      final best = Board.fromCounts(
        white: const {7: 2, 6: 2},
        black: const {1: 2},
      );
      final play = Board.fromCounts(
        white: const {9: 1, 7: 1, 6: 2},
        black: const {1: 2},
      );

      expect(mistakeOf(start, Player.white, best, play), Mistake.leftBlot);
    });

    test('A-408: Zu früh in die Heimat – erwartet: '
        'Stapelt der Zug Steine tief in der Heimat, solange noch Kontakt '
        'besteht, gilt das als Fehler', () {
      final start = Board.fromCounts(
        white: const {8: 2, 6: 2},
        black: const {1: 2},
      );
      final play = Board.fromCounts(
        white: const {8: 2, 2: 2},
        black: const {1: 2},
      );

      expect(mistakeOf(start, Player.white, start, play), Mistake.earlyHome);
    });

    test('A-408: Bester Zug – erwartet: '
        'Der beste Zug selbst ist nie ein Fehler', () {
      final start = Board.start();

      expect(mistakeOf(start, Player.white, start, start), isNull);
    });
  });
}
