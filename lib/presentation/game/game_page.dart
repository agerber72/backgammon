import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../board/board_assets.dart';
import '../board/board_painter.dart';
import '../board/board_scene.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, this.preloadedAssets});

  /// Skips loading the board images, which tests use to stay independent of it.
  final Map<BoardView, BoardAssets>? preloadedAssets;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const _viewChange = Duration(milliseconds: 350);

  Map<BoardView, BoardAssets>? _assets;
  BoardView _view = BoardView.white;

  @override
  void initState() {
    super.initState();
    _assets = widget.preloadedAssets;
    if (_assets == null) {
      _loadAssets();
    }
  }

  Future<void> _loadAssets() async {
    final loaded = await Future.wait(
      BoardView.values.map((view) => BoardAssets.load(view, rootBundle)),
    );
    if (mounted) {
      setState(() => _assets = Map.fromIterables(BoardView.values, loaded));
    }
  }

  void _switchView() {
    setState(() {
      _view = _view == BoardView.white ? BoardView.black : BoardView.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    final assets = _assets?[_view];
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      body: Stack(
        children: [
          if (assets != null)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedSwitcher(
                  duration: _viewChange,
                  child: CustomPaint(
                    key: ValueKey(_view),
                    size: Size.infinite,
                    painter: BoardPainter(assets, BoardScene.sample),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: _switchView,
                tooltip: AppLocalizations.of(context).switchViewTooltip,
                icon: const Icon(Icons.sync),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
