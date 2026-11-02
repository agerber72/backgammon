import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';

import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player, Step;
import '../../domain/game.dart';
import '../../l10n/app_localizations.dart';
import '../board/board_assets.dart';
import '../board/board_hit_test.dart';
import '../board/board_painter.dart';
import '../board/board_scene.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, this.preloadedAssets, this.controller});

  /// Skips loading the board images, which tests use to stay independent of it.
  final Map<BoardView, BoardAssets>? preloadedAssets;

  final GameController? controller;

  @override
  State<GamePage> createState() => _GamePageState();
}

/// Layout values shared by the board and the buttons on it.
abstract final class BoardPage {
  static const padding = 4.0;
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  static const _viewChange = Duration(milliseconds: 350);
  static const _checkerMove = Duration(milliseconds: 260);

  late final GameController _controller;
  late final AnimationController _moveAnimation;
  Map<BoardView, BoardAssets>? _assets;
  BoardView _view = BoardView.white;
  Step? _animated;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GameController();
    _moveAnimation = AnimationController(vsync: this, duration: _checkerMove);
    _controller.addListener(_onGameChanged);
    _assets = widget.preloadedAssets;
    if (_assets == null) {
      _loadAssets();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameChanged);
    _moveAnimation.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAssets() async {
    final loaded = await Future.wait(
      BoardView.values.map((view) => BoardAssets.load(view, rootBundle)),
    );
    if (mounted) {
      setState(() => _assets = Map.fromIterables(BoardView.values, loaded));
    }
  }

  void _onGameChanged() {
    final step = _controller.lastStep;
    setState(() {
      if (step != null && !identical(step, _animated)) {
        _animated = step;
        _moveAnimation.forward(from: 0);
      }
    });
  }

  void _switchView() {
    setState(() {
      _view = _view == BoardView.white ? BoardView.black : BoardView.white;
    });
  }

  void _start(BoardView view) {
    setState(() => _view = view);
    _controller.startGame();
  }

  int? _hit(BoardAssets assets, Size size, Offset position) {
    final mover = _controller.game?.turn ?? Player.white;
    return BoardHitTester(assets.layout, size).positionAt(position, mover);
  }

  Widget _board(BoardAssets assets) {
    return Padding(
      padding: const EdgeInsets.all(BoardPage.padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          void tapAt(Offset position) {
            final hit = _hit(assets, size, position);
            if (hit != null) {
              _controller.tap(hit);
            }
          }

          return GestureDetector(
            onTapUp: (details) => tapAt(details.localPosition),
            onPanStart: (details) {
              final hit = _hit(assets, size, details.localPosition);
              if (hit != null && hit != _controller.selected) {
                _controller.tap(hit);
              }
            },
            onPanUpdate: (details) => _dragPosition = details.localPosition,
            onPanEnd: (details) {
              final position = _dragPosition;
              if (position != null) {
                tapAt(position);
              }
              _dragPosition = null;
            },
            child: AnimatedSwitcher(
              duration: _viewChange,
              child: AnimatedBuilder(
                key: ValueKey(_view),
                animation: _moveAnimation,
                builder: (context, _) => CustomPaint(
                  size: Size.infinite,
                  painter: BoardPainter(assets, _scene()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset? _dragPosition;

  BoardScene _scene() {
    final game = _controller.game;
    final step = _animated;
    final moving = _moveAnimation.isAnimating && step != null && game != null
        ? MovingChecker(
            game.turn,
            step.from,
            step.to,
            Curves.easeInOut.transform(_moveAnimation.value),
          )
        : null;
    return BoardScene.of(
      _controller.board,
      game,
      selected: _controller.selected,
      targets: _controller.targets,
      moving: moving,
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final game = _controller.game;
    if (game == null) {
      return [
        _Prompt(l10n.chooseColor),
        FilledButton(
          onPressed: () => _start(BoardView.white),
          child: Text(l10n.playWhite),
        ),
        FilledButton(
          onPressed: () => _start(BoardView.black),
          child: Text(l10n.playBlack),
        ),
      ];
    }
    final result = game.result;
    if (result != null) {
      return [
        _Prompt(_resultText(l10n, result)),
        FilledButton(
          onPressed: _controller.startGame,
          child: Text(l10n.newGame),
        ),
      ];
    }
    return switch (game.phase) {
      GamePhase.awaitingRoll => [
        FilledButton(onPressed: _controller.roll, child: Text(l10n.roll)),
        if (game.canDouble)
          OutlinedButton(
            onPressed: _controller.offerDouble,
            child: Text(l10n.doubleCube),
          ),
      ],
      GamePhase.awaitingDoubleResponse => [
        _Prompt(l10n.doubleOffered(game.cube.value * 2)),
        FilledButton(
          onPressed: _controller.acceptDouble,
          child: Text(l10n.accept),
        ),
        OutlinedButton(
          onPressed: _controller.refuseDouble,
          child: Text(l10n.refuse),
        ),
      ],
      GamePhase.awaitingPlay => [
        if (_controller.mustPass) ...[
          _Prompt(l10n.noMove),
          FilledButton(onPressed: _controller.pass, child: Text(l10n.pass)),
        ],
        if (_controller.canConfirm)
          FilledButton(
            onPressed: _controller.confirm,
            child: Text(l10n.confirm),
          ),
        if (_controller.hasPendingSteps)
          OutlinedButton(onPressed: _controller.undo, child: Text(l10n.undo)),
      ],
      GamePhase.finished => const [],
    };
  }

  /// Places the buttons on the free felt of the half without dice and sizes
  /// them with the board.
  Widget _actionBar(
    BoardAssets assets,
    BoxConstraints page,
    List<Widget> items,
  ) {
    const padding = BoardPage.padding;
    final size = Size(
      page.maxWidth - 2 * padding,
      page.maxHeight - 2 * padding,
    );
    final layout = assets.layout;
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    final band = layout.middleBand(leftHalf: _diceOnRight());
    final image = fit.imageSize;
    return Positioned.fromRect(
      rect: Rect.fromLTWH(
        padding + fit.offset.dx + band.left * image.width,
        padding + fit.offset.dy + band.top * image.height,
        band.width * image.width,
        band.height * image.height,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: band.height * image.height * 0.14,
        ),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: items,
          ),
        ),
      ),
    );
  }

  bool _diceOnRight() {
    final game = _controller.game;
    if (game == null) {
      return true;
    }
    return (game.turn == Player.white) == (_view == BoardView.white);
  }

  String _resultText(AppLocalizations l10n, GameResult result) {
    final winner = result.winner == Player.white ? l10n.white : l10n.black;
    return switch (result.type) {
      WinType.single => l10n.resultSingle(winner, result.points),
      WinType.gammon => l10n.resultGammon(winner, result.points),
      WinType.backgammon => l10n.resultBackgammon(winner, result.points),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assets = _assets?[_view];
    final actions = _actions(l10n);
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      body: Stack(
        children: [
          if (assets != null) Positioned.fill(child: _board(assets)),
          if (assets != null && actions.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) =>
                  Stack(children: [_actionBar(assets, constraints, actions)]),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: _switchView,
                tooltip: l10n.switchViewTooltip,
                icon: const Icon(Icons.sync),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(text),
      ),
    );
  }
}
