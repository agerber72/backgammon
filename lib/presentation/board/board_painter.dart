import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../domain/board.dart' show Board, Player, Step;
import '../brand.dart';
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
  const BoardPainter(this.assets, this.scene, {this.diceScale = 1});

  static const _rowLength = 5;

  /// Colors of the checkers, from tools/blender/board_config.json.
  static const _light = Color(0xFFEFE6D2);
  static const _dark = Color(0xFF141414);

  /// Size of a checker's top face within its sprite box.
  static const _faceWidth = 0.64;
  static const _faceHeight = 0.6;

  /// A target ring in the color opposite to the moving checker stands out on
  /// light and dark points and on checkers of either color.
  static (Color ring, Color edge) ringColors(String color) =>
      color == Player.white.name ? (_dark, _light) : (_light, _dark);

  /// A plain see-through checker cannot be seen on top of a full row of the
  /// same color, so there the target shows the marked checker.
  static String targetSprite(String color, int checkersOnTarget) =>
      checkersOnTarget < _rowLength
      ? 'checker_$color'
      : 'checker_${color}_selected';

  final BoardAssets assets;
  final BoardScene scene;

  /// Enlarges the dice around their place, so small displays stay readable.
  final double diceScale;

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
    for (final MapEntry(key: color, value: total) in scene.off.entries) {
      final count = _isBearingOff(color) ? total - 1 : total;
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
    _drawDirection(canvas, size, layout);

    final diceSlots = layout.dice[scene.diceColor]!;
    for (var i = 0; i < scene.dice.length; i++) {
      final sprite = 'die_${scene.diceColor}_${scene.dice[i]}';
      final slot = diceSlots[i];
      final position = SlotPosition(slot.u, slot.v, slot.scale * diceScale);
      _drawSprite(canvas, size, sprite, position, paint);
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

  /// See-through checkers with a ring show where the selected checker can go.
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
        final tray = layout.off[color]![count - 1];
        _drawTray(canvas, size, image, tray, ghost);
        _drawTrayRing(canvas, size, tray, color);
        continue;
      }
      final own = scene.checkers[color]?[target] ?? 0;
      final slot = layout.points[target]![own];
      _drawSprite(canvas, size, targetSprite(color, own), slot, ghost);
      _drawRing(canvas, size, slot, color);
    }
  }

  void _drawRing(Canvas canvas, Size size, SlotPosition slot, String color) {
    final box = assets.layout.sprites['checker_$color']!;
    final oval = Rect.fromCenter(
      center: Offset(slot.u * size.width, slot.v * size.height),
      width: box.width * _faceWidth * slot.scale * size.width,
      height: box.height * _faceHeight * slot.scale * size.height,
    );
    final (ring, edge) = ringColors(color);
    final width = oval.height * 0.1;
    canvas
      ..drawOval(oval, _stroke(edge, width * 1.8))
      ..drawOval(oval, _stroke(ring, width));
  }

  void _drawTrayRing(Canvas canvas, Size size, TrayImage tray, String color) {
    final rect = Rect.fromLTWH(
      tray.left * size.width,
      tray.top * size.height,
      tray.width * size.width,
      tray.height * size.height,
    );
    final width = rect.width * 0.08;
    final frame = RRect.fromRectAndRadius(
      rect.deflate(width),
      Radius.circular(rect.width * 0.25),
    );
    final (ring, edge) = ringColors(color);
    canvas
      ..drawRRect(frame, _stroke(edge, width * 1.8))
      ..drawRRect(frame, _stroke(ring, width));
  }

  Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = color;

  /// A U on the free felt between the point tips: from above the player's
  /// farthest point, turning over the outer point and running past the home
  /// board into the player's tray. Its width and corners follow the width of
  /// a point, so it fits the board at every size and covers no checkers of the
  /// start position.
  void _drawDirection(Canvas canvas, Size size, BoardLayout layout) {
    final player = scene.direction;
    final opacity = scene.directionOpacity;
    if (player == null || opacity <= 0) {
      return;
    }
    // Points in the order the player passes them: start, turn and home.
    final (startPoint, turnPoint, homePoint, nextPoint) = player == Player.white
        ? (24, 13, 1, 2)
        : (1, 12, 24, 23);
    double u(int point) => layout.points[point]!.first.u * size.width;
    final point = (u(nextPoint) - u(homePoint)).abs();

    // Two lanes near the edges of the free felt between the point tips, so
    // the arrow keeps clear of the checkers.
    final band = layout.middleBand(leftHalf: true);
    final top = (band.top + band.height * 0.15) * size.height;
    final bottom = (band.top + band.height * 0.85) * size.height;
    final startsAtTop = layout.points[startPoint]!.first.v < 0.5;
    final (from, to) = startsAtTop ? (top, bottom) : (bottom, top);

    final startX = u(startPoint);
    final turnX = u(turnPoint);
    final ahead = (turnX - startX).sign;
    final down = (to - from).sign;
    final radius = (to - from).abs() / 2;

    // At the end the arrow bends into the player's own tray compartment.
    final tray = layout.off[player.name]!.last;
    final trayX = (tray.left + tray.width / 2) * size.width;
    final trayDown = ((tray.top + tray.height / 2) * size.height - to).sign;
    final tipY =
        (tray.top + tray.height * (trayDown > 0 ? 0.35 : 0.65)) * size.height;
    final head = point * 0.4;
    final neckY = tipY - trayDown * head;
    final corner = math.min(radius, (tipY - to).abs() / 2);

    final line = Path()
      ..moveTo(startX, from)
      ..lineTo(turnX - ahead * radius, from)
      ..arcToPoint(
        Offset(turnX - ahead * radius, to),
        radius: Radius.circular(radius),
        clockwise: (ahead > 0) == (down > 0),
      )
      ..lineTo(trayX + ahead * corner, to)
      ..quadraticBezierTo(trayX, to, trayX, to + trayDown * corner)
      ..lineTo(trayX, neckY);
    final arrowhead = Path()
      ..moveTo(trayX, tipY)
      ..lineTo(trayX - head * 0.6, neckY)
      ..lineTo(trayX + head * 0.6, neckY)
      ..close();

    final width = point * 0.16;
    final edge = _dark.withValues(alpha: 0.6 * opacity);
    final color = brandBlue.withValues(alpha: opacity);
    canvas
      ..drawPath(line, _stroke(edge, width * 1.8))
      ..drawPath(arrowhead, _stroke(edge, width * 0.8))
      ..drawPath(line, _stroke(color, width))
      ..drawPath(arrowhead, Paint()..color = color);
  }

  SlotPosition? _occupiedSlot(BoardLayout layout, String color, int position) {
    if (position < 1 || position > Board.pointCount) {
      final bar = scene.bar[color] ?? 0;
      return bar > 0 ? layout.bar[color]![bar - 1] : null;
    }
    final count = scene.checkers[color]?[position] ?? 0;
    return count > 0 ? layout.points[position]![count - 1] : null;
  }

  bool _isBearingOff(String color) {
    final moving = scene.moving;
    return moving != null &&
        moving.player.name == color &&
        moving.to == Step.offOf(moving.player);
  }

  SlotPosition _trayCenter(BoardLayout layout, String color) {
    final tray = layout.off[color]!.last;
    return SlotPosition(
      tray.left + tray.width / 2,
      tray.top + tray.height / 2,
      1,
    );
  }

  /// The checker on its way, between its old and its new place.
  _CheckerItem? _movingItem(BoardLayout layout) {
    final moving = scene.moving;
    if (moving == null) {
      return null;
    }
    final color = moving.player.name;
    final target = _isBearingOff(color)
        ? _trayCenter(layout, color)
        : _occupiedSlot(layout, color, moving.to);
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
      oldDelegate.assets != assets ||
      oldDelegate.scene != scene ||
      oldDelegate.scene.directionOpacity != scene.directionOpacity ||
      oldDelegate.diceScale != diceScale;
}

class _CheckerItem {
  const _CheckerItem(this.sprite, this.position, this.layer);

  final String sprite;
  final SlotPosition position;
  final int layer;
}
