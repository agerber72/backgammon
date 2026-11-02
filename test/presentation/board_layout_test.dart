import 'dart:convert';
import 'dart:io';

import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/board/board_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BoardLayout load(BoardView view) => BoardLayout.fromJson(
    jsonDecode(File('assets/board/layout_${view.name}.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final view in BoardView.values) {
    group('Ansicht ${view.name}:', () {
      test('A-102: 24 Zungen – erwartet: '
          'Jede der 24 Zungen hat Plätze für alle 15 Steine', () {
        final layout = load(view);

        expect(
          layout.points.keys,
          unorderedEquals(List.generate(24, (i) => i + 1)),
        );
        expect(layout.points.values.map((slots) => slots.length).toSet(), {15});
      });

      test('A-308: Fach fasst alle Steine – erwartet: '
          'Für 1 bis 15 Steine je Farbe gibt es ein Fachbild', () {
        final layout = load(view);

        for (final color in ['white', 'black']) {
          expect(layout.off[color], hasLength(15));
          for (var count = 1; count <= 15; count++) {
            final name = 'off_${view.name}_${color}_$count';
            expect(
              File('assets/board/$name.png').existsSync(),
              isTrue,
              reason: name,
            );
          }
        }
        expect(
          File('assets/board/cube_home_${view.name}.png').existsSync(),
          isTrue,
        );
      });

      test('A-303: Steine passen zum Brett – erwartet: '
          'Alle Plätze liegen innerhalb des Brettbilds', () {
        final layout = load(view);
        final slots = [
          ...layout.points.values.expand((slots) => slots),
          ...layout.bar.values.expand((slots) => slots),
          ...layout.dice.values.expand((slots) => slots),
          ...layout.cube.values,
        ];

        for (final slot in slots) {
          expect(slot.u, inInclusiveRange(0, 1));
          expect(slot.v, inInclusiveRange(0, 1));
        }
      });

      test('A-302: Vollständige Grafik – erwartet: '
          'Zu Brett, Rahmen und jedem Spielteil gibt es eine Bilddatei', () {
        final layout = load(view);

        for (final name in [
          ...layout.sprites.keys,
          'board_${view.name}',
          'rail_${view.name}',
        ]) {
          expect(
            File('assets/board/$name.png').existsSync(),
            isTrue,
            reason: name,
          );
        }
      });
    });
  }

  test('A-304: Ansichten Schwarz und Weiß – erwartet: '
      'Zunge 1 liegt bei Weiß rechts unten und bei Schwarz links oben', () {
    final white = load(BoardView.white).points[1]!.first;
    final black = load(BoardView.black).points[1]!.first;

    expect(white.u, greaterThan(0.5));
    expect(white.v, greaterThan(0.5));
    expect(black.u, lessThan(0.5));
    expect(black.v, lessThan(0.5));
  });
}
