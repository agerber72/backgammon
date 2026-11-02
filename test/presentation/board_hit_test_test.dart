import 'dart:convert';
import 'dart:io';

import 'package:backgammon/domain/board.dart';
import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/board/board_hit_test.dart';
import 'package:backgammon/presentation/board/board_layout.dart';
import 'package:backgammon/presentation/board/board_painter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const displays = {
    'Handy': Size(2400, 1080),
    'Fenster': Size(1280, 720),
    'Tablet': Size(1024, 768),
  };

  BoardLayout load(BoardView view) => BoardLayout.fromJson(
    jsonDecode(File('assets/board/layout_${view.name}.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Offset onScreen(BoardLayout layout, Size size, SlotPosition slot) {
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    return fit.offset +
        Offset(slot.u * fit.imageSize.width, slot.v * fit.imageSize.height);
  }

  for (final view in BoardView.values) {
    for (final MapEntry(key: name, value: size) in displays.entries) {
      final layout = load(view);
      final tester = BoardHitTester(layout, size);

      group('Ansicht ${view.name}, $name:', () {
        test('A-203: Treffer auf der Zunge – erwartet: '
            'Jeder der fünf Plätze jeder Zunge trifft genau diese Zunge', () {
          for (final MapEntry(key: point, value: slots)
              in layout.points.entries) {
            for (final slot in slots.take(5)) {
              final hit = tester.positionAt(
                onScreen(layout, size, slot),
                Player.white,
              );
              expect(hit, point, reason: 'Zunge $point');
            }
          }
        });

        test('A-203: Bar – erwartet: '
            'Ein Tipp auf die Bar trifft die Bar des Spielers am Zug', () {
          final slot = layout.bar['white']!.first;
          final position = onScreen(layout, size, slot);

          expect(
            tester.positionAt(position, Player.white),
            Step.barOf(Player.white),
          );
          expect(
            tester.positionAt(position, Player.black),
            Step.barOf(Player.black),
          );
        });

        test('A-203: Ablagefach – erwartet: '
            'Ein Tipp ins Fach trifft das Ziel Auswürfeln', () {
          final tray = layout.off['white']!.last;
          final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
          final position =
              fit.offset +
              Offset(
                (tray.left + tray.width / 2) * fit.imageSize.width,
                (tray.top + tray.height / 2) * fit.imageSize.height,
              );

          expect(
            tester.positionAt(position, Player.white),
            Step.offOf(Player.white),
          );
        });

        test('A-203: Daneben – erwartet: '
            'Ein Tipp außerhalb des Bretts trifft nichts', () {
          expect(tester.positionAt(const Offset(1, 1), Player.white), isNull);
        });
      });
    }
  }
}
