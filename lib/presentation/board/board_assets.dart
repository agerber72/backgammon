import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'board_layout.dart';

enum BoardView { white, black }

/// Images and coordinates needed to draw the board from one side.
class BoardAssets {
  const BoardAssets(
    this.view,
    this.layout,
    this.board,
    this.frontRail,
    this.sprites,
  );

  final BoardView view;

  final BoardLayout layout;
  final ui.Image board;

  /// Rail next to the viewer, drawn over the checkers to hide their near edge.
  final ui.Image frontRail;
  final Map<String, ui.Image> sprites;

  /// Whether the images come from the tier for high-resolution displays.
  bool get isHighResolution => board.width > normalWidth;

  /// Width of the normal board image; the high-resolution tier is larger.
  static const normalWidth = 2560;

  /// Loads the images of [view]. With [highResolution] they come from
  /// `assets/board/hd/`, which only some platforms contain; without it, or
  /// where it is missing, from `assets/board/`. The layout is the same for
  /// both, because it describes positions as fractions of the image.
  static Future<BoardAssets> load(
    BoardView view,
    AssetBundle bundle, {
    bool highResolution = false,
  }) async {
    if (highResolution) {
      try {
        return await _load(view, bundle, 'assets/board/hd');
      } on Object {
        // Not part of this platform's bundle: use the normal tier.
      }
    }
    return _load(view, bundle, 'assets/board');
  }

  static Future<BoardAssets> _load(
    BoardView view,
    AssetBundle bundle,
    String directory,
  ) async {
    final json = await bundle.loadString(
      'assets/board/layout_${view.name}.json',
    );
    final layout = BoardLayout.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    final names = [
      ...layout.sprites.keys,
      'cube_home_${view.name}',
      for (final MapEntry(key: color, value: stacks) in layout.off.entries)
        for (var count = 1; count <= stacks.length; count++)
          'off_${view.name}_${color}_$count',
    ];
    final images = await Future.wait(
      names.map((name) => _decode('$directory/$name.png', bundle)),
    );
    return BoardAssets(
      view,
      layout,
      await _decode('$directory/${layout.image}', bundle),
      await _decode('$directory/${layout.frontRail}', bundle),
      Map.fromIterables(names, images),
    );
  }

  static Future<ui.Image> _decode(String path, AssetBundle bundle) async {
    final data = await bundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }
}
