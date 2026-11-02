import 'dart:math' as math;

/// Position on the board image in fractions of its size, plus the sprite scale.
class SlotPosition {
  const SlotPosition(this.u, this.v, this.scale);

  factory SlotPosition.fromJson(List<dynamic> json) => SlotPosition(
    (json[0] as num).toDouble(),
    (json[1] as num).toDouble(),
    (json[2] as num).toDouble(),
  );

  final double u;
  final double v;
  final double scale;
}

/// Sprite rectangle relative to its anchor, in fractions of the board image.
class SpriteBox {
  const SpriteBox(this.left, this.top, this.width, this.height);

  factory SpriteBox.fromJson(Map<String, dynamic> json) => SpriteBox(
    (json['left'] as num).toDouble(),
    (json['top'] as num).toDouble(),
    (json['width'] as num).toDouble(),
    (json['height'] as num).toDouble(),
  );

  final double left;
  final double top;
  final double width;
  final double height;
}

/// Rectangle of a pre-rendered tray image, in fractions of the board image.
class TrayImage {
  const TrayImage(this.left, this.top, this.width, this.height);

  factory TrayImage.fromJson(List<dynamic> json) => TrayImage(
    (json[0] as num).toDouble(),
    (json[1] as num).toDouble(),
    (json[2] as num).toDouble(),
    (json[3] as num).toDouble(),
  );

  final double left;
  final double top;
  final double width;
  final double height;
}

/// Coordinates exported by tools/blender/render_board.py for one view.
class BoardLayout {
  const BoardLayout({
    required this.image,
    required this.frontRail,
    required this.aspect,
    required this.sprites,
    required this.points,
    required this.bar,
    required this.off,
    required this.cubeHome,
    required this.bounds,
    required this.dice,
    required this.cube,
  });

  factory BoardLayout.fromJson(Map<String, dynamic> json) {
    List<SlotPosition> slots(dynamic list) => (list as List<dynamic>)
        .map((slot) => SlotPosition.fromJson(slot as List<dynamic>))
        .toList();
    Map<String, List<SlotPosition>> slotsByColor(dynamic map) =>
        (map as Map<String, dynamic>).map(
          (color, list) => MapEntry(color, slots(list)),
        );

    return BoardLayout(
      image: json['image'] as String,
      frontRail: json['frontRail'] as String,
      aspect: (json['aspect'] as num).toDouble(),
      sprites: (json['sprites'] as Map<String, dynamic>).map(
        (name, box) =>
            MapEntry(name, SpriteBox.fromJson(box as Map<String, dynamic>)),
      ),
      points: (json['points'] as Map<String, dynamic>).map(
        (point, list) => MapEntry(int.parse(point), slots(list)),
      ),
      bar: slotsByColor(json['bar']),
      off: (json['off'] as Map<String, dynamic>).map(
        (color, list) => MapEntry(
          color,
          (list as List<dynamic>)
              .map((image) => TrayImage.fromJson(image as List<dynamic>))
              .toList(),
        ),
      ),
      cubeHome: TrayImage.fromJson(json['cubeHome'] as List<dynamic>),
      bounds: TrayImage.fromJson(json['bounds'] as List<dynamic>),
      dice: slotsByColor(json['dice']),
      cube: (json['cube'] as Map<String, dynamic>).map(
        (place, slot) =>
            MapEntry(place, SlotPosition.fromJson(slot as List<dynamic>)),
      ),
    );
  }

  /// Free felt between the point tips on one half of the image, in fractions
  /// of its size. Buttons sit here without covering the points.
  TrayImage middleBand({required bool leftHalf}) {
    final centerU =
        points.values.map((slots) => slots.first.u).reduce((a, b) => a + b) /
        points.length;
    final half = points.values
        .where((slots) => slots.first.u < centerU == leftHalf)
        .toList();
    final topRow = half.where((slots) => slots.first.v < 0.5);
    final bottomRow = half.where((slots) => slots.first.v >= 0.5);

    double tip(List<SlotPosition> slots) =>
        slots[_rowLength - 1].v +
        (slots[_rowLength - 1].v - slots[_rowLength - 2].v) / 2;

    final top = topRow.map(tip).reduce(math.max);
    final bottom = bottomRow.map(tip).reduce(math.min);
    final us = half.map((slots) => slots.first.u).toList()..sort();
    final left = us.first;
    final right = us.last;
    return TrayImage(left, top, right - left, bottom - top);
  }

  static const _rowLength = 5;

  final String image;
  final String frontRail;
  final double aspect;
  final Map<String, SpriteBox> sprites;
  final Map<int, List<SlotPosition>> points;
  final Map<String, List<SlotPosition>> bar;

  /// Tray stacks per color; the entry at index n shows n + 1 checkers.
  final Map<String, List<TrayImage>> off;
  final TrayImage cubeHome;

  /// Outer edge of the board inside the image; this part fills the display.
  final TrayImage bounds;
  final Map<String, List<SlotPosition>> dice;
  final Map<String, SlotPosition> cube;
}
