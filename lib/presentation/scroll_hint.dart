import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'brand.dart';

/// Shows that a scrollable text goes on: the edges fade out where more text
/// is hidden, and small arrows at the right edge scroll by a page when
/// tapped, down at the bottom and back up at the top. On desktop the
/// scrollbar stays visible.
class ScrollHint extends StatefulWidget {
  const ScrollHint({super.key, required this.builder});

  /// Builds the vertical scrollable, which has to use the given controller
  /// and keep [reserve] free at the right edge of its content.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  /// Height of the fading edge.
  static const fade = 24.0;

  /// Keeps this much of the old page in view when an arrow scrolls.
  static const overlap = 40.0;

  /// Diameter of an arrow.
  static const arrowSize = 18.0;

  /// Space around an arrow: a third of its size from the top, bottom and the
  /// scrollbar.
  static const arrowGap = arrowSize / 3;

  /// Width kept free for the scrollbar at the right edge.
  static const scrollbarWidth = 8.0;

  /// Space the scrollable content keeps free at its right edge, so the
  /// arrows never cover text.
  static const reserve = scrollbarWidth + arrowGap + arrowSize + arrowGap;

  @override
  State<ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<ScrollHint> {
  final _controller = ScrollController();
  var _moreAbove = false;
  var _moreBelow = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (!position.hasContentDimensions) {
      return;
    }
    final above = position.extentBefore > 1;
    final below = position.extentAfter > 1;
    if (above != _moreAbove || below != _moreBelow) {
      setState(() {
        _moreAbove = above;
        _moreBelow = below;
      });
    }
  }

  /// Scrolls a page down, or up for a negative [direction].
  void _scrollPage(int direction) {
    final position = _controller.position;
    final page = math.max(position.viewportDimension - ScrollHint.overlap, 1);
    final target = (position.pixels + direction * page).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  static bool get _desktop => switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final scrollable = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: _desktop,
        child: widget.builder(context, _controller),
      ),
    );
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _update());
        return false;
      },
      child: Stack(
        children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) {
              final edge = bounds.height <= 0
                  ? 0.0
                  : math.min(ScrollHint.fade / bounds.height, 0.5);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _moreAbove ? Colors.transparent : Colors.black,
                  Colors.black,
                  Colors.black,
                  _moreBelow ? Colors.transparent : Colors.black,
                ],
                stops: [0, edge, 1 - edge, 1],
              ).createShader(bounds);
            },
            child: scrollable,
          ),
          if (_moreAbove)
            Positioned(
              right: ScrollHint.scrollbarWidth + ScrollHint.arrowGap,
              top: ScrollHint.arrowGap,
              child: _Arrow(down: false, onTap: () => _scrollPage(-1)),
            ),
          if (_moreBelow)
            Positioned(
              right: ScrollHint.scrollbarWidth + ScrollHint.arrowGap,
              bottom: ScrollHint.arrowGap,
              child: _Arrow(down: true, onTap: () => _scrollPage(1)),
            ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.down, required this.onTap});

  final bool down;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = down ? l10n.scrollMore : l10n.scrollBack;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: brandBlue,
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(
              down ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              size: ScrollHint.arrowSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
