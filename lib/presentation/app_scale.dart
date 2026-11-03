import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Scales the whole interface with the size of the window, so that buttons,
/// dialogs and symbols grow and shrink together with the board.
///
/// The app is laid out for [designSize], about a phone held sideways. Larger
/// windows enlarge everything in the same ratio as the board, so buttons and
/// dialogs keep their size relative to it. Smaller windows shrink it down to
/// [minFactor], below which text would no longer be readable.
class AppScale extends StatelessWidget {
  const AppScale({super.key, required this.child});

  static const designSize = Size(900, 420);
  static const minFactor = 0.5;

  final Widget child;

  static double factorFor(Size size) => math.max(
    minFactor,
    math.min(size.width / designSize.width, size.height / designSize.height),
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final factor = factorFor(media.size);
    if (media.size.isEmpty || factor == 1) {
      return child;
    }
    final size = media.size / factor;
    return FittedBox(
      alignment: Alignment.topLeft,
      child: SizedBox.fromSize(
        size: size,
        child: MediaQuery(
          data: media.copyWith(
            size: size,
            devicePixelRatio: media.devicePixelRatio * factor,
            padding: media.padding / factor,
            viewPadding: media.viewPadding / factor,
            viewInsets: media.viewInsets / factor,
            systemGestureInsets: media.systemGestureInsets / factor,
          ),
          child: child,
        ),
      ),
    );
  }
}
