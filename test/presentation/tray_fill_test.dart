import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Share of the image height covered by solid pixels of the checkers.
  Future<double> coveredHeight(String name) async {
    final bytes = File('assets/board/$name.png').readAsBytesSync();
    final codec = await ui.instantiateImageCodec(bytes);
    final image = (await codec.getNextFrame()).image;
    final data = (await image.toByteData())!;
    final center = image.width ~/ 2;
    var solidRows = 0;
    for (var row = 0; row < image.height; row++) {
      final alpha = data.getUint8((row * image.width + center) * 4 + 3);
      if (alpha > 200) {
        solidRows++;
      }
    }
    return solidRows / image.height;
  }

  for (final view in ['white', 'black']) {
    for (final color in ['white', 'black']) {
      testWidgets('A-308: Sieg füllt das Fach, Ansicht $view, Farbe $color – '
          'erwartet: 15 Steine bedecken fast das ganze Fach, '
          '1 Stein nur einen kleinen Teil', (tester) async {
        final (full, single) = (await tester.runAsync(
          () async => (
            await coveredHeight('off_${view}_${color}_15'),
            await coveredHeight('off_${view}_${color}_1'),
          ),
        ))!;

        expect(full, greaterThan(0.7));
        expect(single, lessThan(0.4));
      });
    }
  }
}
