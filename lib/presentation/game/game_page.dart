import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
import '../brand.dart';
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

/// Symbols in the column on the right that appear only in some situations:
/// the brand colors inverted, so that they stand out.
final situationalButtonStyle = IconButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: brandBlue,
);

/// Layout values shared by the board and the buttons on it.
abstract final class BoardPage {
  static const padding = 4.0;

  /// Room on the right for the column of symbols, so they never cover the
  /// board.
  static const toolbarWidth = 56.0;

  static const insets = EdgeInsets.fromLTRB(
    padding,
    padding,
    padding + toolbarWidth,
    padding,
  );
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  static const _viewChange = Duration(milliseconds: 350);
  static const _checkerMove = Duration(milliseconds: 260);

  /// How long the arrow for the direction of play shows at the start; it
  /// fades out in the last part.
  static const _directionHint = Duration(seconds: 4);
  static const _directionFade = 0.75;

  /// Every button row shares this design size, so all rows scale alike and
  /// the buttons keep the same height.
  static const _actionBarWidth = 480.0;
  static const _actionHeight = 40.0;

  /// Below this height buttons are hard to read and to hit.
  static const _minimumActionHeight = 48.0;
  static const _feltMargin = 0.14;
  static const _compactDiceScale = 2.0;

  late final GameController _controller;
  late final AnimationController _moveAnimation;
  late final AnimationController _directionAnimation;
  Map<BoardView, BoardAssets>? _assets;
  BoardView _view = BoardView.white;
  bool _colorChosen = false;
  bool _askColorAgain = false;
  Step? _animated;

  @override
  void initState() {
    super.initState();
    // The web version keeps nothing in the browser: a game lasts as long as
    // the page is open.
    _controller =
        widget.controller ??
        GameController(store: kIsWeb ? null : SharedPreferencesSessionStore());
    _moveAnimation = AnimationController(vsync: this, duration: _checkerMove);
    _directionAnimation = AnimationController(
      vsync: this,
      duration: _directionHint,
    );
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

  /// A new game asks for the color again; the level stays as set.
  void _restart() => setState(() => _askColorAgain = true);

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
    _directionAnimation.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAssets({bool highResolution = false}) async {
    final loaded = await Future.wait(
      BoardView.values.map(
        (view) =>
            BoardAssets.load(view, rootBundle, highResolution: highResolution),
      ),
    );
    if (mounted) {
      setState(() => _assets = Map.fromIterables(BoardView.values, loaded));
    }
  }

  /// Set once the larger images have been asked for, so they load only once,
  /// even where the platform does not contain them.
  bool _highResolutionRequested = false;

  /// Switches to the larger images once the board is drawn wider than the
  /// normal ones, as on a 4K display. The normal images stay until the larger
  /// ones are ready.
  void _checkResolution(BoardAssets assets, Size size) {
    if (_highResolutionRequested ||
        widget.preloadedAssets != null ||
        assets.isHighResolution) {
      return;
    }
    final layout = assets.layout;
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    final pixels = fit.imageSize.width * MediaQuery.devicePixelRatioOf(context);
    if (pixels > BoardAssets.normalWidth) {
      _highResolutionRequested = true;
      _loadAssets(highResolution: true);
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
    final again = _askColorAgain;
    setState(() {
      _view = view;
      _colorChosen = true;
      _askColorAgain = false;
    });
    if (again) {
      final human = view == BoardView.white ? Player.white : Player.black;
      _controller
        ..updateSettings(human: human)
        ..startGame(human: human, difficulty: _controller.difficulty);
      _directionAnimation.forward(from: 0);
    }
  }

  void _start(Difficulty difficulty) {
    _controller.startGame(
      human: _view == BoardView.white ? Player.white : Player.black,
      difficulty: difficulty,
    );
    _directionAnimation.forward(from: 0);
  }

  double get _directionOpacity {
    if (!_directionAnimation.isAnimating) {
      return 0;
    }
    final t = _directionAnimation.value;
    return t < _directionFade ? 1 : (1 - t) / (1 - _directionFade);
  }

  int? _hit(BoardAssets assets, Size size, Offset position) {
    final mover = _controller.game?.turn ?? Player.white;
    return BoardHitTester(assets.layout, size).positionAt(position, mover);
  }

  Widget _board(BoardAssets assets) {
    return Padding(
      padding: BoardPage.insets,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          _checkResolution(assets, size);
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
              _dragStart = hit;
              _dragSelected = hit != null && hit != _controller.selected;
              if (_dragSelected) {
                _controller.tap(hit!);
              }
              _dragPosition = null;
            },
            onPanUpdate: (details) => _dragPosition = details.localPosition,
            onPanEnd: (details) {
              final position = _dragPosition;
              final end = position == null
                  ? _dragStart
                  : _hit(assets, size, position);
              // A finger that slips a little while tapping makes a short
              // drag. Ending it where it started is that tap: it must not
              // deselect the checker the drag has just selected.
              if (end != null && !(end == _dragStart && _dragSelected)) {
                _controller.tap(end);
              }
              _dragStart = null;
              _dragSelected = false;
              _dragPosition = null;
            },
            child: AnimatedSwitcher(
              duration: _viewChange,
              child: AnimatedBuilder(
                key: ValueKey(_view),
                animation: Listenable.merge([
                  _moveAnimation,
                  _directionAnimation,
                ]),
                builder: (context, _) => CustomPaint(
                  size: Size.infinite,
                  painter: BoardPainter(
                    assets,
                    _scene(),
                    diceScale: _isCompact(assets, size) ? _compactDiceScale : 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset? _dragPosition;

  /// The position under the finger when a drag starts, and whether the drag
  /// selected its checker there.
  int? _dragStart;
  bool _dragSelected = false;

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
      direction: _controller.human,
      directionOpacity: _directionOpacity,
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final game = _controller.game;
    if ((game == null && !_colorChosen) || _askColorAgain) {
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
    return const [];
  }

  /// Everything a person decides during a game, as symbols at the bottom of
  /// the column on the right, so that nothing covers the board. Symbols that
  /// appear only in some situations are inverted, white with a blue symbol,
  /// so that a new decision stands out from the symbols that always show.
  List<Widget> _decisions(AppLocalizations l10n) {
    final game = _controller.game;
    if (game == null || game.result != null) {
      return const [];
    }
    final countdown = _controller.countdown;
    Widget situational(
      String tooltip,
      Widget icon,
      VoidCallback onPressed, [
      AutoAction? action,
      ButtonHint? hint,
    ]) {
      Widget button = IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: icon,
        style: situationalButtonStyle,
      );
      if (countdown != null && countdown.action == action) {
        button = CountdownRing(countdown: countdown, child: button);
      }
      return hint == null ? button : HintedButton(hint: hint, child: button);
    }

    final turn = !_controller.isHumanTurn
        ? const <Widget>[]
        : switch (game.phase) {
            GamePhase.awaitingRoll => [
              situational(
                l10n.roll,
                const Icon(Icons.casino),
                _controller.roll,
                AutoAction.roll,
              ),
            ],
            GamePhase.awaitingDoubleResponse => [
              // The bubble reminds the person that the game waits for a
              // decision on the double.
              HintedButton(
                hint: ButtonHint([
                  HintAction(
                    l10n.accept,
                    Text(
                      l10n.cubeValue(game.cube.value * 2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _controller.acceptDouble,
                  ),
                  HintAction(
                    l10n.refuse,
                    const Icon(Icons.close),
                    _controller.refuseDouble,
                  ),
                ], separator: l10n.or),
                child: Tooltip(
                  message: l10n.doubleOffered(game.cube.value * 2),
                  child: Text(
                    l10n.cubeValue(game.cube.value * 2),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              situational(
                l10n.refuse,
                const Icon(Icons.close),
                _controller.refuseDouble,
              ),
              situational(
                l10n.accept,
                const Icon(Icons.check),
                _controller.acceptDouble,
              ),
            ],
            GamePhase.awaitingPlay => [
              if (_controller.hasPendingSteps && !_controller.playingForced)
                situational(
                  l10n.undo,
                  const Icon(Icons.undo),
                  _controller.undo,
                ),
              if (_controller.mustPass)
                situational(
                  l10n.noMove,
                  const Icon(Icons.skip_next),
                  _controller.pass,
                  AutoAction.pass,
                  ButtonHint([
                    HintAction(
                      l10n.noMove,
                      const Icon(Icons.skip_next),
                      _controller.pass,
                    ),
                  ]),
                ),
              if (_controller.canConfirm)
                situational(
                  l10n.confirm,
                  const Icon(Icons.check),
                  _controller.confirm,
                  AutoAction.confirm,
                ),
            ],
            GamePhase.finished => const <Widget>[],
          };
    // The cube shows whenever the person may double, also while the computer
    // moves, so that a quick game never leaves too little time for it.
    final doubleNow = game.canDouble && _controller.isHumanTurn;
    final requested = _controller.doubleRequested;
    // Played by hand on both sides, it shows only when doubling is allowed.
    final cubeButton = !_controller.mayDouble && !doubleNow
        ? null
        : IconButton.filled(
            onPressed: _controller.requestDouble,
            tooltip: doubleNow
                ? l10n.doubleCube
                : requested
                ? l10n.doubleRequested
                : l10n.doubleLater,
            icon: Text(
              l10n.cubeValue(game.cube.value * 2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: doubleNow ? brandBlue : Colors.white,
              ),
            ),
            // White when it doubles now, blue with a white ring once wished.
            style: doubleNow
                ? situationalButtonStyle
                : IconButton.styleFrom(
                    backgroundColor: requested ? brandBlue : null,
                    side: requested
                        ? const BorderSide(color: Colors.white, width: 2)
                        : null,
                  ),
          );
    final cube = cubeButton != null && _controller.asksToDouble
        ? HintedButton(
            hint: ButtonHint([
              HintAction(
                l10n.doubleCube,
                Text(
                  l10n.cubeValue(game.cube.value * 2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _controller.offerDouble,
              ),
              HintAction(l10n.roll, const Icon(Icons.casino), _controller.roll),
            ], separator: l10n.or),
            child: cubeButton,
          )
        : cubeButton;
    // Resign shows during the whole game, so it keeps the regular colors, and
    // it stays at the very bottom, so that it never moves.
    return [
      ?cube,
      ...turn,
      if (_controller.canAutoFinish)
        situational(
          l10n.autoFinish,
          const Icon(Icons.fast_forward),
          _controller.autoFinish,
        ),
      if (_controller.canResign)
        IconButton.filledTonal(
          onPressed: () => _confirmResign(l10n),
          tooltip: l10n.resign,
          icon: const Icon(Icons.flag),
        ),
    ];
  }

  /// The free felt between the points of one half, inside the board area.
  Rect _band(BoardAssets assets, Size size, {required bool leftHalf}) {
    final layout = assets.layout;
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    final band = layout.middleBand(leftHalf: leftHalf);
    final image = fit.imageSize;
    return Rect.fromLTWH(
      fit.offset.dx + band.left * image.width,
      fit.offset.dy + band.top * image.height,
      band.width * image.width,
      band.height * image.height,
    );
  }

  /// Whether the felt is too narrow for readable buttons. The same half is
  /// measured every time, so the answer does not change between turns.
  bool _isCompact(BoardAssets assets, Size size) {
    final rect = _band(assets, size, leftHalf: true);
    final felt = rect.deflate(rect.height * _feltMargin);
    final scale = math.min(
      felt.height / _actionHeight,
      felt.width / _actionBarWidth,
    );
    return scale * _actionHeight < _minimumActionHeight;
  }

  /// Places the buttons on the free felt of the half without dice and sizes
  /// them with the board. On compact displays they appear as a popup in full
  /// size instead.
  Widget _actionBar(
    BoardAssets assets,
    BoxConstraints page,
    List<Widget> items,
  ) {
    const insets = BoardPage.insets;
    final size = insets.deflateSize(page.biggest);
    final rect = _band(
      assets,
      size,
      leftHalf: _diceOnRight(),
    ).shift(insets.topLeft);
    final felt = rect.deflate(rect.height * _feltMargin);
    if (_isCompact(assets, size)) {
      return Positioned.fromRect(
        rect: rect.inflate(page.maxHeight),
        child: Center(
          child: _ActionPopup(
            items: items,
            maxWidth: math.max(rect.width, _ActionPopup.minWidth),
          ),
        ),
      );
    }
    return Positioned.fromRect(
      rect: felt,
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
            bottom: 8,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        tooltip: _controller.keepsRecords
                            ? l10n.statistics
                            : l10n.diceStats,
                        icon: const Icon(Icons.bar_chart),
                      ),
                    ],
                  ),
                  Column(spacing: 8, children: _decisions(l10n)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-size buttons for small displays, where the felt is too narrow.
class _ActionPopup extends StatelessWidget {
  const _ActionPopup({required this.items, required this.maxWidth});

  static const _buttonHeight = 48.0;
  static const _fontSize = 16.0;

  /// Wide enough for a result and its button on one line each, even where
  /// the felt of one half is narrower.
  static const minWidth = 320.0;

  final List<Widget> items;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Based on the theme's label style, so the buttons keep the app's font.
    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, _buttonHeight)),
      textStyle: WidgetStatePropertyAll(
        theme.textTheme.labelLarge?.copyWith(fontSize: _fontSize),
      ),
    );
    return Theme(
      data: theme.copyWith(
        filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: theme.colorScheme.surfaceContainerHigh,
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                for (final prompt in items.whereType<_Prompt>())
                  Text(
                    prompt.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: _fontSize),
                  ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final item in items)
                      if (item is! _Prompt) item,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A ring around a symbol that runs down until the app acts by itself, so
/// that a coming action never surprises (`A-222`).
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.countdown,
    required this.child,
  });

  final Countdown countdown;
  final Widget child;

  /// The ring lies on the edge of the symbol, so the column keeps its width.
  @override
  Widget build(BuildContext context) {
    final total = countdown.duration.inMilliseconds;
    final elapsed = DateTime.now()
        .difference(countdown.start)
        .inMilliseconds
        .clamp(0, total);
    return TweenAnimationBuilder<double>(
      // A new countdown starts a new animation.
      key: ValueKey(countdown),
      tween: Tween(begin: total == 0 ? 0 : 1 - elapsed / total, end: 0),
      duration: Duration(milliseconds: total - elapsed),
      builder: (context, left, child) => Stack(
        alignment: Alignment.center,
        children: [
          child!,
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  value: left,
                  strokeWidth: 3,
                  color: brandBlue,
                  backgroundColor: brandBlue.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// One choice in a [ButtonHint]: a label with a small symbol, tappable.
class HintAction {
  const HintAction(this.label, this.icon, this.onPressed);

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
}

/// A note that belongs to a symbol on the right, made of one or more choices,
/// such as "No move possible" or "Double or roll".
class ButtonHint {
  const ButtonHint(this.actions, {this.separator});

  final List<HintAction> actions;

  /// Word between the choices, such as "or".
  final String? separator;
}

/// Shows a [ButtonHint] as a white bubble right next to the left of its
/// symbol, in the symbol's colors, so it is clear which symbol it means. The
/// bubble lives in the overlay and follows the symbol, so the column keeps
/// its width and the bubble can still be tapped.
class HintedButton extends StatefulWidget {
  const HintedButton({super.key, required this.hint, required this.child});

  final ButtonHint hint;
  final Widget child;

  @override
  State<HintedButton> createState() => _HintedButtonState();
}

class _HintedButtonState extends State<HintedButton> {
  final _link = LayerLink();
  final _portal = OverlayPortalController()..show();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = theme.textTheme.labelLarge?.copyWith(
      color: brandBlue,
      fontWeight: FontWeight.bold,
    );
    final hint = widget.hint;
    final children = <Widget>[];
    for (final action in hint.actions) {
      if (children.isNotEmpty && hint.separator != null) {
        children.add(
          Text(
            hint.separator!,
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.black54),
          ),
        );
      }
      children.add(
        TextButton.icon(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: brandBlue,
            iconColor: brandBlue,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: IconTheme.merge(
            data: const IconThemeData(size: 18, color: brandBlue),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: brandBlue),
              child: action.icon,
            ),
          ),
          label: Text(action.label, style: label, softWrap: false),
        ),
      );
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.centerLeft,
            followerAnchor: Alignment.centerRight,
            offset: const Offset(-8, 0),
            child: Material(
              color: Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: children,
                ),
              ),
            ),
          ),
        ),
        child: widget.child,
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
