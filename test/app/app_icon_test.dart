import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Size of an Android adaptive icon layer in dp.
const layerDp = 108.0;

/// Radius of the safe zone every launcher mask keeps visible, in dp.
const safeRadiusDp = 33.0;

/// Smallest gap between logo and safe zone that still looks calm, in dp.
const marginDp = 4.0;

/// Pixels of the white logo; the light checkers are clearly greyer.
bool isLogo(int r, int g, int b) => r >= 250 && g >= 250 && b >= 250;

Future<double> logoRadiusDp(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final image = (await codec.getNextFrame()).image;
  final bytes = (await image.toByteData())!;
  final side = image.width;
  final center = side / 2;
  var radius = 0.0;
  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      final offset = 4 * (y * side + x);
      if (isLogo(
        bytes.getUint8(offset),
        bytes.getUint8(offset + 1),
        bytes.getUint8(offset + 2),
      )) {
        radius = math.max(
          radius,
          math.sqrt(
            math.pow(x + 0.5 - center, 2) + math.pow(y + 0.5 - center, 2),
          ),
        );
      }
    }
  }
  return radius * layerDp / side;
}

void main() {
  test('A-326: Logo im adaptiven Symbol – erwartet: '
      'Das ganze Logo liegt mit Abstand innerhalb der Schutzzone, die jede '
      'Maskenform von Android zeigt', () async {
    for (final density in const ['mdpi', 'xxxhdpi']) {
      final path =
          'android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png';
      final radius = await logoRadiusDp(path);
      // ignore: avoid_print
      print('$density: logo reaches ${radius.toStringAsFixed(1)} dp');
      expect(radius, lessThanOrEqualTo(safeRadiusDp - marginDp), reason: path);
    }
  });
}
