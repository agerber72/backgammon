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

  static Future<BoardAssets> load(BoardView view, AssetBundle bundle) async {
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
      names.map((name) => _decode('assets/board/$name.png', bundle)),
    );
    return BoardAssets(
      view,
      layout,
      await _decode('assets/board/${layout.image}', bundle),
      await _decode('assets/board/${layout.frontRail}', bundle),
      Map.fromIterables(names, images),
    );
  }

  static Future<ui.Image> _decode(String path, AssetBundle bundle) async {
    final data = await bundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }
}
