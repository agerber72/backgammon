import 'package:flutter/material.dart';

/// A small national flag for a language code, `de` or `en`. Painted rather
/// than an emoji, because Windows shows emoji flags only as letters.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.language, {super.key, this.height = 20});

  final String language;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(2),
    child: CustomPaint(
      size: Size(height * 2, height),
      painter: language == 'de' ? _GermanFlag() : _UnionFlag(),
    ),
  );
}

class _GermanFlag extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final band = size.height / 3;
    const colors = [Color(0xFF000000), Color(0xFFDD0000), Color(0xFFFFCE00)];
    for (var index = 0; index < colors.length; index++) {
      canvas.drawRect(
        Rect.fromLTWH(0, index * band, size.width, band),
        Paint()..color = colors[index],
      );
    }
  }

  @override
  bool shouldRepaint(_GermanFlag oldDelegate) => false;
}

/// The Union Flag in the proportions 2:1, on a grid of 60 × 30.
class _UnionFlag extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 60, size.height / 30);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 60, 30),
      Paint()..color = const Color(0xFF012169),
    );
    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    const white = Color(0xFFFFFFFF);
    const red = Color(0xFFC8102E);

    canvas
      ..drawLine(Offset.zero, const Offset(60, 30), stroke(white, 6))
      ..drawLine(const Offset(60, 0), const Offset(0, 30), stroke(white, 6));
    // The red diagonals sit off the centre line, turning around the middle.
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 60, 30));
    final diagonal = stroke(red, 2);
    canvas
      ..drawLine(const Offset(0, -1), const Offset(30, 14), diagonal)
      ..drawLine(const Offset(30, 16), const Offset(60, 31), diagonal)
      ..drawLine(const Offset(60, 1), const Offset(30, 16), diagonal)
      ..drawLine(const Offset(30, 14), const Offset(0, 29), diagonal);
    canvas.restore();

    canvas
      ..drawLine(const Offset(30, 0), const Offset(30, 30), stroke(white, 10))
      ..drawLine(const Offset(0, 15), const Offset(60, 15), stroke(white, 10))
      ..drawLine(const Offset(30, 0), const Offset(30, 30), stroke(red, 6))
      ..drawLine(const Offset(0, 15), const Offset(60, 15), stroke(red, 6));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_UnionFlag oldDelegate) => false;
}
