import 'dart:convert';
import 'dart:io';
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

  test('A-314: Ziel auf voller Zunge – erwartet: '
      'Bis fünf Steine zeigt das Ziel den normalen Stein, '
      'ab dem sechsten den markierten, damit er sichtbar bleibt', () {
    expect(BoardPainter.targetSprite('white', 0), 'checker_white');
    expect(BoardPainter.targetSprite('white', 4), 'checker_white');
    expect(BoardPainter.targetSprite('white', 5), 'checker_white_selected');
    expect(BoardPainter.targetSprite('black', 7), 'checker_black_selected');
  });

  test('A-314: Ring um das Ziel – erwartet: '
      'Für Weiß ein dunkler Ring mit hellem Rand, für Schwarz umgekehrt', () {
    final (whiteRing, whiteEdge) = BoardPainter.ringColors('white');
    final (blackRing, blackEdge) = BoardPainter.ringColors('black');

    expect(whiteRing.computeLuminance(), lessThan(0.1));
    expect(whiteEdge.computeLuminance(), greaterThan(0.7));
    expect(blackRing, whiteEdge);
    expect(blackEdge, whiteRing);
  });

  test('A-323: Helles Holz – erwartet: '
      'Beide Holzfarben des Rahmens in board_config.json sind hell', () {
    final config = jsonDecode(
      File('tools/blender/board_config.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final colors = config['colors'] as Map<String, dynamic>;
    for (final name in ['frame_wood_light', 'frame_wood_dark']) {
      final hex = (colors[name] as String).substring(1);
      final color = Color(0xFF000000 | int.parse(hex, radix: 16));
      expect(color.computeLuminance(), greaterThan(0.25), reason: name);
    }
  });

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
