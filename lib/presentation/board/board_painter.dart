import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../domain/board.dart' show Board, Player, Step;
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

  static const _rowLength = 5;

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
    _drawCounts(canvas, size, layout);
    _drawTargets(canvas, size, layout);
    _drawImage(canvas, assets.frontRail, Offset.zero & size, paint);
    final moving = _movingItem(layout);
    if (moving != null) {
      _drawSprite(canvas, size, moving.sprite, moving.position, paint);
    }

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
    final moving = scene.moving;
    final items = <_CheckerItem>[
      for (final MapEntry(key: color, value: points) in scene.checkers.entries)
        for (final MapEntry(key: point, value: count) in points.entries)
          for (var slot = 0; slot < count; slot++)
            if (!(moving != null &&
                moving.to == point &&
                slot == count - 1 &&
                moving.player.name == color))
              _CheckerItem(
                _spriteOf(color, point, slot, count),
                layout.points[point]![slot],
                slot ~/ _rowLength,
              ),
      for (final MapEntry(key: color, value: count) in scene.bar.entries)
        for (var slot = 0; slot < count; slot++)
          _CheckerItem(
            _spriteOf(color, _barOf(color), slot, count),
            layout.bar[color]![slot],
            slot ~/ 3,
          ),
    ];
    items.sort((a, b) {
      final byLayer = a.layer.compareTo(b.layer);
      return byLayer != 0 ? byLayer : a.position.v.compareTo(b.position.v);
    });
    return items;
  }

  /// The top checker of the selected position carries the marker.
  String _spriteOf(String color, int position, int slot, int count) {
    final isSelected =
        position == scene.selected &&
        color == scene.diceColor &&
        slot == count - 1;
    return isSelected ? 'checker_${color}_selected' : 'checker_$color';
  }

  int _barOf(String color) => Step.barOf(Player.values.byName(color));

  /// Stacks of more than five checkers show their size on top.
  void _drawCounts(Canvas canvas, Size size, BoardLayout layout) {
    for (final points in scene.checkers.values) {
      for (final MapEntry(key: point, value: count) in points.entries) {
        if (count <= _rowLength) {
          continue;
        }
        final slot = layout.points[point]![count - 1];
        final label = TextPainter(
          text: TextSpan(
            text: '$count',
            style: TextStyle(
              color: const Color(0xFFE53935),
              fontSize: size.height * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(
          canvas,
          Offset(slot.u * size.width, slot.v * size.height) -
              Offset(label.width / 2, label.height / 2),
        );
      }
    }
  }

  /// See-through checkers show where the selected checker can go.
  void _drawTargets(Canvas canvas, Size size, BoardLayout layout) {
    final color = scene.diceColor;
    final ghost = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = const Color.fromRGBO(255, 255, 255, 0.5);
    for (final target in scene.targets) {
      if (target < 1 || target > Board.pointCount) {
        final count = (scene.off[color] ?? 0) + 1;
        final image =
            assets.sprites['off_${assets.view.name}_${color}_$count']!;
        _drawTray(canvas, size, image, layout.off[color]![count - 1], ghost);
        continue;
      }
      final own = scene.checkers[color]?[target] ?? 0;
      final slot = layout.points[target]![own % _rowLength];
      _drawSprite(canvas, size, 'checker_$color', slot, ghost);
    }
  }

  SlotPosition? _occupiedSlot(BoardLayout layout, String color, int position) {
    if (position < 1 || position > Board.pointCount) {
      final bar = scene.bar[color] ?? 0;
      return bar > 0 ? layout.bar[color]![bar - 1] : null;
    }
    final count = scene.checkers[color]?[position] ?? 0;
    return count > 0 ? layout.points[position]![count - 1] : null;
  }

  /// The checker on its way, between its old and its new place.
  _CheckerItem? _movingItem(BoardLayout layout) {
    final moving = scene.moving;
    if (moving == null || moving.to < 1 || moving.to > Board.pointCount) {
      return null;
    }
    final color = moving.player.name;
    final target = _occupiedSlot(layout, color, moving.to);
    if (target == null) {
      return null;
    }
    final isBar = moving.from == Step.barOf(moving.player);
    final leftBehind = isBar
        ? scene.bar[color] ?? 0
        : scene.checkers[color]?[moving.from] ?? 0;
    final source = isBar
        ? layout.bar[color]![leftBehind]
        : layout.points[moving.from]![leftBehind];
    final t = moving.progress;
    return _CheckerItem(
      'checker_$color',
      SlotPosition(
        ui.lerpDouble(source.u, target.u, t)!,
        ui.lerpDouble(source.v, target.v, t)!,
        ui.lerpDouble(source.scale, target.scale, t)!,
      ),
      0,
    );
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
  const _CheckerItem(this.sprite, this.position, this.layer);

  final String sprite;
  final SlotPosition position;
  final int layer;
}
