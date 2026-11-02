import 'dart:ui';

import 'package:backgammon/presentation/board/board_layout.dart';
import 'package:backgammon/presentation/board/board_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = TrayImage(0.05, 0.04, 0.9, 0.92);
  const aspect = 16 / 9;
  const displays = {
    'Handy 20:9': Size(2400, 1080),
    'Fenster 16:9': Size(1280, 720),
    'Tablet 4:3': Size(1024, 768),
  };

  Rect boardRect(BoardFit fit) => Rect.fromLTWH(
    fit.offset.dx + bounds.left * fit.imageSize.width,
    fit.offset.dy + bounds.top * fit.imageSize.height,
    bounds.width * fit.imageSize.width,
    bounds.height * fit.imageSize.height,
  );

  for (final MapEntry(key: name, value: display) in displays.entries) {
    group('$name:', () {
      test('A-311: Brett füllt den Ausschnitt – erwartet: '
          'Das Brett berührt mindestens zwei gegenüberliegende Ränder', () {
        final board = boardRect(BoardFit.compute(bounds, aspect, display));

        final fillsWidth = (board.width - display.width).abs() < 0.01;
        final fillsHeight = (board.height - display.height).abs() < 0.01;
        expect(fillsWidth || fillsHeight, isTrue);
      });

      test('A-311: Nichts wird abgeschnitten – erwartet: '
          'Das Brett liegt vollständig und mittig in der Anzeige', () {
        final board = boardRect(BoardFit.compute(bounds, aspect, display));

        expect(board.left, greaterThanOrEqualTo(-0.01));
        expect(board.top, greaterThanOrEqualTo(-0.01));
        expect(board.right, lessThanOrEqualTo(display.width + 0.01));
        expect(board.bottom, lessThanOrEqualTo(display.height + 0.01));
        expect(board.center.dx, closeTo(display.width / 2, 0.01));
        expect(board.center.dy, closeTo(display.height / 2, 0.01));
      });

      test('A-311: Keine Verzerrung – erwartet: '
          'Das Bild behält sein Seitenverhältnis', () {
        final fit = BoardFit.compute(bounds, aspect, display);

        expect(
          fit.imageSize.width / fit.imageSize.height,
          closeTo(aspect, 1e-9),
        );
      });
    });
  }
}
