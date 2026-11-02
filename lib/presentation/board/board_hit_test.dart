import 'dart:ui';

import '../../domain/board.dart';
import 'board_layout.dart';
import 'board_painter.dart';

/// Finds what a tap hit, using the same coordinates that draw the board.
/// Input and display therefore cannot drift apart.
class BoardHitTester {
  const BoardHitTester(this.layout, this.available);

  final BoardLayout layout;
  final Size available;

  static const _rowLength = 5;

  /// A point number, or the bar or tray of [mover] as numbered by [Step].
  int? positionAt(Offset tap, Player mover) {
    final fit = BoardFit.compute(layout.bounds, layout.aspect, available);
    final image = fit.imageSize;
    Offset onScreen(SlotPosition slot) =>
        fit.offset + Offset(slot.u * image.width, slot.v * image.height);

    for (final color in layout.off.keys) {
      final tray = layout.off[color]!.last;
      final rect = Rect.fromLTWH(
        fit.offset.dx + tray.left * image.width,
        fit.offset.dy + tray.top * image.height,
        tray.width * image.width,
        tray.height * image.height,
      );
      if (rect.contains(tap)) {
        return Step.offOf(mover);
      }
    }

    final first = layout.points[1]!;
    final reach = (onScreen(first[0]) - onScreen(first[1])).distance * 0.75;
    int? nearest;
    var shortest = reach;
    for (final MapEntry(key: point, value: slots) in layout.points.entries) {
      for (final slot in slots.take(_rowLength)) {
        final distance = (onScreen(slot) - tap).distance;
        if (distance < shortest) {
          shortest = distance;
          nearest = point;
        }
      }
    }
    for (final slots in layout.bar.values) {
      for (final slot in slots.take(3)) {
        if ((onScreen(slot) - tap).distance < shortest) {
          return Step.barOf(mover);
        }
      }
    }
    return nearest;
  }
}
