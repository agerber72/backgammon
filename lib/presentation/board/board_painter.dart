import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'board_assets.dart';
import 'board_layout.dart';
import 'board_scene.dart';

/// Where the board image goes so that the outer board fills the display.
class BoardFit {
  const BoardFit(this.imageSize, this.offset);

  factory BoardFit.compute(TrayImage bounds, double aspect, Size available) {
    final scale = math.min(
      available.width / (bounds.width * aspect),
      available.height / bounds.height,
    );
    final imageSize = Size(aspect * scale, scale);
    return BoardFit(
      imageSize,
      Offset(
        (available.width - bounds.width * imageSize.width) / 2 -
            bounds.left * imageSize.width,
        (available.height - bounds.height * imageSize.height) / 2 -
            bounds.top * imageSize.height,
      ),
    );
  }

  final Size imageSize;
  final Offset offset;
}

class BoardPainter extends CustomPainter {
  const BoardPainter(this.assets, this.scene);

  final BoardAssets assets;
  final BoardScene scene;

  @override
  void paint(Canvas canvas, Size available) {
    final fit = BoardFit.compute(
      assets.layout.bounds,
      assets.layout.aspect,
      available,
    );
    canvas.save();
    canvas.translate(fit.offset.dx, fit.offset.dy);
    _paintBoard(canvas, fit.imageSize);
    canvas.restore();
  }

  void _paintBoard(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    _drawImage(canvas, assets.board, Offset.zero & size, paint);

    final layout = assets.layout;
    final view = assets.view.name;
    for (final MapEntry(key: color, value: count) in scene.off.entries) {
      if (count > 0) {
        final image = assets.sprites['off_${view}_${color}_$count']!;
        _drawTray(canvas, size, image, layout.off[color]![count - 1], paint);
      }
    }
    if (scene.cubeOwner == null) {
      final image = assets.sprites['cube_home_$view']!;
      _drawTray(canvas, size, image, layout.cubeHome, paint);
    }
    for (final item in _checkerItems(layout)) {
      _drawSprite(canvas, size, item.sprite, item.position, paint);
    }
    _drawImage(canvas, assets.frontRail, Offset.zero & size, paint);

    final diceSlots = layout.dice[scene.diceColor]!;
    for (var i = 0; i < scene.dice.length; i++) {
      final sprite = 'die_${scene.diceColor}_${scene.dice[i]}';
      _drawSprite(canvas, size, sprite, diceSlots[i], paint);
    }
    final cubeOwner = scene.cubeOwner;
    if (cubeOwner != null) {
      _drawSprite(
        canvas,
        size,
        'cube_${scene.cubeValue}',
        layout.cube[cubeOwner]!,
        paint,
      );
    }
  }

  /// Sorted so that checkers nearer to the viewer overlap the ones behind.
  List<_CheckerItem> _checkerItems(BoardLayout layout) {
    final items = <_CheckerItem>[
      for (final MapEntry(key: color, value: points) in scene.checkers.entries)
        for (final MapEntry(key: point, value: count) in points.entries)
          for (var slot = 0; slot < count; slot++)
            _CheckerItem('checker_$color', layout.points[point]![slot]),
    ];
    items.sort((a, b) => a.position.v.compareTo(b.position.v));
    return items;
  }

  void _drawSprite(
    Canvas canvas,
    Size size,
    String name,
    SlotPosition position,
    Paint paint,
  ) {
    final box = assets.layout.sprites[name]!;
    final rect = Rect.fromLTWH(
      (position.u + box.left * position.scale) * size.width,
      (position.v + box.top * position.scale) * size.height,
      box.width * position.scale * size.width,
      box.height * position.scale * size.height,
    );
    _drawImage(canvas, assets.sprites[name]!, rect, paint);
  }

  void _drawTray(
    Canvas canvas,
    Size size,
    ui.Image image,
    TrayImage tray,
    Paint paint,
  ) {
    final rect = Rect.fromLTWH(
      tray.left * size.width,
      tray.top * size.height,
      tray.width * size.width,
      tray.height * size.height,
    );
    _drawImage(canvas, image, rect, paint);
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect target, Paint paint) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(image, source, target, paint);
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      oldDelegate.assets != assets || oldDelegate.scene != scene;
}

class _CheckerItem {
  const _CheckerItem(this.sprite, this.position);

  final String sprite;
  final SlotPosition position;
}
