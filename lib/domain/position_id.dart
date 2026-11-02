import 'dart:convert';

import 'board.dart';

/// Writes the Position ID of GNU Backgammon for the player on roll, so that
/// positions can be compared with this reference tool.
String positionId(Board board, Player onRoll) {
  final bits = <bool>[];
  for (final player in [onRoll.opponent, onRoll]) {
    for (var distance = 1; distance <= Board.pointCount; distance++) {
      final count = board.count(player, Board.pointAt(player, distance));
      bits.addAll(List.filled(count, true));
      bits.add(false);
    }
    bits.addAll(List.filled(board.bar(player), true));
    bits.add(false);
  }

  final bytes = List.filled(10, 0);
  for (var i = 0; i < bits.length; i++) {
    if (bits[i]) {
      bytes[i ~/ 8] |= 1 << (i % 8);
    }
  }
  return base64.encode(bytes).replaceAll('=', '');
}
