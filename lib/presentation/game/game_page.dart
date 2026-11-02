import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';

import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player, Step;
import '../../domain/game.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../persistence/session_store.dart';
import '../board/board_assets.dart';
import '../board/board_hit_test.dart';
import '../board/board_painter.dart';
import '../board/board_scene.dart';
import 'settings_dialog.dart';
import 'stats_dialog.dart';

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

  /// Every button row shares this design size, so all rows scale alike and
  /// the buttons keep the same height.
  static const _actionBarWidth = 480.0;
  static const _actionHeight = 40.0;

  late final GameController _controller;
  late final AnimationController _moveAnimation;
  Map<BoardView, BoardAssets>? _assets;
  BoardView _view = BoardView.white;
  bool _colorChosen = false;
  Step? _animated;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        GameController(store: SharedPreferencesSessionStore());
    _moveAnimation = AnimationController(vsync: this, duration: _checkerMove);
    _controller.addListener(_onGameChanged);
    _assets = widget.preloadedAssets;
    if (_assets == null) {
      _loadAssets();
    }
    _restoreGame();
  }

  Future<void> _restoreGame() async {
    await _controller.restore();
    final human = _controller.human;
    if (mounted && human != null && _controller.game != null) {
      setState(() => _view = _viewOf(human));
    }
  }

  BoardView _viewOf(Player player) =>
      player == Player.white ? BoardView.white : BoardView.black;

  void _restart() {
    _controller.restart();
    final human = _controller.human;
    if (human != null) {
      setState(() => _view = _viewOf(human));
    }
  }

  Future<void> _openSettings() async {
    final view = await showDialog<BoardView>(
      context: context,
      builder: (context) =>
          SettingsDialog(controller: _controller, view: _view),
    );
    if (view != null) {
      setState(() => _view = view);
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

  Future<void> _confirmResign(AppLocalizations l10n) async {
    final points = _controller.game!.cube.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resignQuestion),
        content: Text(l10n.resignConsequence(points)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resign),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && _controller.canResign) {
      _controller.resign();
    }
  }

  void _chooseColor(BoardView view) {
    setState(() {
      _view = view;
      _colorChosen = true;
    });
  }

  void _start(Difficulty difficulty) {
    _controller.startGame(
      human: _view == BoardView.white ? Player.white : Player.black,
      difficulty: difficulty,
    );
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
    if (game == null && !_colorChosen) {
      return [
        _Prompt(l10n.chooseColor),
        FilledButton(
          onPressed: () => _chooseColor(BoardView.white),
          child: Text(l10n.playWhite),
        ),
        FilledButton(
          onPressed: () => _chooseColor(BoardView.black),
          child: Text(l10n.playBlack),
        ),
      ];
    }
    if (game == null) {
      return [
        _Prompt(l10n.chooseDifficulty),
        for (final (difficulty, label) in [
          (Difficulty.easy, l10n.difficultyEasy),
          (Difficulty.medium, l10n.difficultyMedium),
          (Difficulty.hard, l10n.difficultyHard),
        ])
          FilledButton(onPressed: () => _start(difficulty), child: Text(label)),
      ];
    }
    final result = game.result;
    if (result != null) {
      return [
        _Prompt(_resultText(l10n, result)),
        FilledButton(onPressed: _restart, child: Text(l10n.newGame)),
      ];
    }
    if (!_controller.isHumanTurn) {
      return const [];
    }
    return switch (game.phase) {
      GamePhase.awaitingRoll => [
        FilledButton(onPressed: _controller.roll, child: Text(l10n.roll)),
        if (game.canDouble)
          OutlinedButton(
            onPressed: _controller.offerDouble,
            child: Text(l10n.doubleCube),
          ),
        if (_controller.canAutoFinish)
          OutlinedButton(
            onPressed: _controller.autoFinish,
            child: Text(l10n.autoFinish),
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
        if (_controller.canAutoFinish && !_controller.mustPass)
          OutlinedButton(
            onPressed: _controller.autoFinish,
            child: Text(l10n.autoFinish),
          ),
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
          child: SizedBox(
            width: _actionBarWidth,
            height: _actionHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                for (final item in items)
                  if (item is _Prompt)
                    Flexible(
                      child: SizedBox(height: _actionHeight, child: item),
                    )
                  else
                    SizedBox(height: _actionHeight, child: item),
              ],
            ),
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
              child: Column(
                spacing: 8,
                children: [
                  IconButton.filledTonal(
                    onPressed: _switchView,
                    tooltip: l10n.switchViewTooltip,
                    icon: const Icon(Icons.sync),
                  ),
                  IconButton.filledTonal(
                    onPressed: _openSettings,
                    tooltip: l10n.settings,
                    icon: const Icon(Icons.settings),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) =>
                          StatsDialog(controller: _controller),
                    ),
                    tooltip: l10n.diceStats,
                    icon: const Icon(Icons.bar_chart),
                  ),
                  if (_controller.canResign)
                    IconButton.filledTonal(
                      onPressed: () => _confirmResign(l10n),
                      tooltip: l10n.resign,
                      icon: const Icon(Icons.flag),
                    ),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Center(
          widthFactor: 1,
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
