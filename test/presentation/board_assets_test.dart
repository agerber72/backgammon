import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A bundle like the Android one: without the high-resolution tier.
class _WithoutHighResolution extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith('assets/board/hd/')) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    return rootBundle.load(key);
  }
}

void main() {
  testWidgets('A-325: Hohe Auflösung – erwartet: '
      'Die zweite Stufe liefert dieselben Bilder 1,5-mal so groß, mit '
      'demselben Layout', (tester) async {
    await tester.runAsync(() async {
      final normal = await BoardAssets.load(BoardView.white, rootBundle);
      final high = await BoardAssets.load(
        BoardView.white,
        rootBundle,
        highResolution: true,
      );

      expect(normal.isHighResolution, isFalse);
      expect(high.isHighResolution, isTrue);
      expect(normal.board.width, BoardAssets.normalWidth);
      expect(high.board.width, 3840);
      expect(high.board.height, 2160);
      expect(high.sprites.keys, normal.sprites.keys);
      for (final name in normal.sprites.keys) {
        expect(
          high.sprites[name]!.width / normal.sprites[name]!.width,
          closeTo(1.5, 0.02),
          reason: name,
        );
      }
    });
  });

  testWidgets('A-325: Ohne zweite Stufe – erwartet: '
      'Fehlen die großen Bilder wie unter Android, nimmt die App die normalen',
      (tester) async {
    await tester.runAsync(() async {
      final assets = await BoardAssets.load(
        BoardView.black,
        _WithoutHighResolution(),
        highResolution: true,
      );

      expect(assets.isHighResolution, isFalse);
      expect(assets.board.width, BoardAssets.normalWidth);
    });
  });
}
