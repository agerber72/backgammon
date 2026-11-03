import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/dice_stats.dart';
import '../domain/game.dart';
import '../domain/move_generator.dart';
import '../engine/engine.dart';
import '../persistence/session_store.dart';

/// Connects a running game with the user interface. During a turn it collects
/// single checker moves, which only become part of the game on [confirm].
class GameController extends ChangeNotifier {
  GameController({
    DiceRoller? roller,
    Game? game,
    Engine? engine,
    SessionStore? store,
    this.computerPause = const Duration(milliseconds: 550),
    this.autoFinishPause = const Duration(milliseconds: 300),
    Duration? autoActionDelay = const Duration(seconds: 3),
  }) : _roller = roller ?? RandomDiceRoller(),
       _engine = engine ?? HeuristicEngine() {
    _store = store;
    _game = game;
    _autoActionDelay = autoActionDelay;
  }

  final DiceRoller _roller;
  final Engine _engine;
  late final SessionStore? _store;

  /// Time between the computer's actions, so that a person can follow them.
  final Duration computerPause;

  /// Time between moves while the game plays itself to the end.
  final Duration autoFinishPause;

  Duration? _autoActionDelay;

  /// Time after which a finished turn ends, or the person rolls after the
  /// computer's turn, without any input; null turns this off.
  Duration? get autoActionDelay => _autoActionDelay;

  Player? _human;
  Difficulty _difficulty = Difficulty.medium;
  Player? _preferredHuman;
  Difficulty? _preferredDifficulty;
  DiceStats _gameStats = DiceStats();
  DiceStats _totalStats = DiceStats();
  var _gameNumber = 0;
  var _computerActive = false;
  var _disposed = false;
  var _autoFinishing = false;
  Timer? _autoAction;
  Future<void> _lastSave = Future.value();
  Game? _game;
  List<Step> _steps = const [];
  int? _selected;
  Step? _lastStep;

  /// Null until the player has started a game.
  Game? get game => _game;

  int? get selected => _selected;

  /// The person's color; null while both sides are played by hand.
  Player? get human => _human;

  Difficulty get difficulty => _preferredDifficulty ?? _difficulty;

  Player? get preferredHuman => _preferredHuman ?? _human;

  DiceStats get gameStats => _gameStats;

  DiceStats get totalStats => _totalStats;

  /// Continues a saved game. Its dice stay as they were, so restarting the app
  /// cannot change a roll.
  Future<void> restore() async {
    final session = await _store?.load();
    if (session == null || _disposed) {
      return;
    }
    _game = session.game;
    _human = session.human;
    _difficulty = session.difficulty;
    _preferredHuman = session.preferredHuman;
    _preferredDifficulty = session.preferredDifficulty;
    _autoActionDelay = session.autoDelaySeconds == 0
        ? null
        : Duration(seconds: session.autoDelaySeconds);
    _gameStats = session.gameStats;
    _totalStats = session.totalStats;
    notifyListeners();
    _letComputerAct();
  }

  /// Changes the waiting time at once; a running countdown stops, and a
  /// new one starts with the next turn.
  void updateAutoDelay(Duration? delay) {
    _autoActionDelay = delay;
    _autoAction?.cancel();
    _save();
    notifyListeners();
  }

  /// Settings for the next game; a running game keeps its own.
  void updateSettings({Player? human, Difficulty? difficulty}) {
    _preferredHuman = human ?? _preferredHuman;
    _preferredDifficulty = difficulty ?? _preferredDifficulty;
    _save();
    notifyListeners();
  }

  /// Whether a person decides now. Without a chosen color, both sides are.
  bool get isHumanTurn {
    final game = _game;
    final human = _human;
    if (_autoFinishing) {
      return false;
    }
    if (game == null || human == null) {
      return true;
    }
    return game.phase == GamePhase.awaitingDoubleResponse
        ? game.turn != human
        : game.turn == human;
  }

  /// The latest checker move, which the board animates.
  Step? get lastStep => _lastStep;

  bool get hasPendingSteps => _steps.isNotEmpty;

  Board get board {
    final game = _game;
    if (game == null) {
      return Board.start();
    }
    return _steps.fold(
      game.board,
      (board, step) => board.apply(game.turn, step),
    );
  }

  List<Step> get _options {
    final game = _game;
    if (game == null || game.phase != GamePhase.awaitingPlay || !isHumanTurn) {
      return const [];
    }
    return nextSteps(game.board, game.turn, game.dice!, _steps);
  }

  /// Where a checker can start from right now.
  Set<int> get sources => _options.map((step) => step.from).toSet();

  /// Where the selected checker can go, with one or several dice.
  Set<int> get targets => _paths.keys.toSet();

  Map<int, List<Step>> get _paths {
    final game = _game;
    final selected = _selected;
    if (selected == null ||
        game == null ||
        game.phase != GamePhase.awaitingPlay ||
        !isHumanTurn) {
      return const {};
    }
    return pathsFrom(game.board, game.turn, game.dice!, _steps, selected);
  }

  bool get mustPass {
    final game = _game;
    return game != null &&
        game.phase == GamePhase.awaitingPlay &&
        isHumanTurn &&
        game.plays.isEmpty;
  }

  bool get canConfirm {
    final game = _game;
    return game != null &&
        game.phase == GamePhase.awaitingPlay &&
        isHumanTurn &&
        !mustPass &&
        _options.isEmpty;
  }

  /// Starts a game, against the computer if [human] names the person's color.
  void startGame({Player? human, Difficulty difficulty = Difficulty.medium}) {
    _human = human;
    _difficulty = difficulty;
    _gameNumber++;
    _autoFinishing = false;
    final game = Game.start(_roller);
    _game = game;
    _gameStats = DiceStats()..addOpening(game.dice!);
    _totalStats.addOpening(game.dice!);
    _resetTurn();
    _save();
    notifyListeners();
    _letComputerAct();
  }

  /// Starts another game with the chosen settings.
  void restart() => startGame(
    human: _preferredHuman ?? _human,
    difficulty: _preferredDifficulty ?? _difficulty,
  );

  @override
  void dispose() {
    _disposed = true;
    _autoAction?.cancel();
    super.dispose();
  }

  void roll() => _update(_rolled(_game!));

  Game _rolled(Game game) {
    final next = game.roll(_roller);
    _gameStats.addRoll(game.turn, next.dice!);
    _totalStats.addRoll(game.turn, next.dice!);
    return next;
  }

  void offerDouble() => _update(_game!.offerDouble());

  void acceptDouble() => _update(_game!.acceptDouble());

  void refuseDouble() => _update(_game!.refuseDouble());

  void pass() => _update(_game!.pass());

  /// Offered once the checkers can no longer meet, so only the race is left.
  /// It stays available during the computer's turn as well.
  bool get canAutoFinish {
    final game = _game;
    return game != null &&
        !_autoFinishing &&
        !game.board.hasContact &&
        (game.phase == GamePhase.awaitingRoll ||
            game.phase == GamePhase.awaitingPlay);
  }

  /// Plays both sides to the end of the game. Moves the person has set but
  /// not confirmed are dropped.
  void autoFinish() {
    if (isHumanTurn) {
      _resetTurn();
    }
    _autoAction?.cancel();
    _autoFinishing = true;
    notifyListeners();
    _letComputerAct();
  }

  bool get canResign {
    final game = _game;
    return game != null && game.phase != GamePhase.finished;
  }

  /// The person gives up, also during the computer's turn.
  void resign() {
    _gameNumber++;
    _autoFinishing = false;
    final game = _game!;
    _update(game.resign(_human ?? game.turn));
  }

  void confirm() => _update(_game!.play(Play(_steps, board)));

  /// Takes back the latest single move, also within a combined move.
  void undo() {
    _autoAction?.cancel();
    _steps = _steps.sublist(0, _steps.length - 1);
    _lastStep = null;
    _selectOnlySource();
    notifyListeners();
  }

  /// Handles a tap on a point, the bar or the tray.
  void tap(int position) {
    if (_selected != null && targets.contains(position)) {
      _move(position);
    } else if (sources.contains(position)) {
      _selected = position == _selected ? null : position;
      notifyListeners();
    } else if (_selected != null) {
      _selected = null;
      notifyListeners();
    }
  }

  void _move(int target) {
    final path = _paths[target]!;
    _steps = [..._steps, ...path];
    _lastStep = Step(
      from: path.first.from,
      to: path.last.to,
      die: path.last.die,
    );
    _selectOnlySource();
    notifyListeners();
    final delay = autoActionDelay;
    if (delay != null && canConfirm) {
      _autoAction = Timer(delay, confirm);
    }
  }

  void _selectOnlySource() {
    _selected = null;
    final remaining = sources;
    if (remaining.length == 1) {
      _selected = remaining.single;
    }
  }

  void _update(Game next) {
    _game = next;
    _resetTurn();
    _save();
    notifyListeners();
    _letComputerAct();
  }

  void _save() {
    final game = _game;
    final store = _store;
    if (store == null) {
      return;
    }
    final session = Session(
      game: game?.phase == GamePhase.finished ? null : game,
      human: _human,
      difficulty: _difficulty,
      preferredHuman: _preferredHuman,
      preferredDifficulty: _preferredDifficulty,
      autoDelaySeconds: _autoActionDelay?.inSeconds ?? 0,
      gameStats: _gameStats,
      totalStats: _totalStats,
    );
    // One after the other, so that an older state cannot overwrite a newer one.
    _lastSave = _lastSave.then((_) => store.save(session));
  }

  /// Runs the computer's actions until a person has to decide again.
  Future<void> _letComputerAct() async {
    if (_computerActive) {
      return;
    }
    _computerActive = true;
    final number = _gameNumber;
    bool stopped() => _disposed || number != _gameNumber;
    Duration pause() => _autoFinishing ? autoFinishPause : computerPause;

    while (!stopped() && !isHumanTurn) {
      final game = _game!;
      await Future<void>.delayed(pause());
      if (stopped()) {
        break;
      }
      switch (game.phase) {
        case GamePhase.awaitingDoubleResponse:
          final accepts = await _engine.acceptsDouble(game, _difficulty);
          _set(accepts ? game.acceptDouble() : game.refuseDouble());
        case GamePhase.awaitingRoll:
          final doubles =
              !_autoFinishing && await _engine.wantsToDouble(game, _difficulty);
          _set(doubles ? game.offerDouble() : _rolled(game));
        case GamePhase.awaitingPlay:
          await _playComputerTurn(game, stopped, pause);
        case GamePhase.finished:
          break;
      }
      if (_game?.phase == GamePhase.finished) {
        break;
      }
    }
    _computerActive = false;
    if (!stopped()) {
      _autoFinishing = false;
      _scheduleAutoRoll();
      notifyListeners();
    }
  }

  /// After the computer's turn the dice roll by themselves unless the person
  /// rolls or doubles first.
  void _scheduleAutoRoll() {
    final delay = autoActionDelay;
    if (delay != null &&
        _human != null &&
        _game?.phase == GamePhase.awaitingRoll &&
        isHumanTurn) {
      _autoAction?.cancel();
      _autoAction = Timer(delay, roll);
    }
  }

  Future<void> _playComputerTurn(
    Game game,
    bool Function() stopped,
    Duration Function() pause,
  ) async {
    if (game.plays.isEmpty) {
      _set(game.pass());
      return;
    }
    final play = await _engine.choosePlay(
      game.board,
      game.turn,
      game.dice!,
      _autoFinishing ? Difficulty.hard : _difficulty,
    );
    for (final step in play.steps) {
      if (stopped()) {
        return;
      }
      _steps = [..._steps, step];
      _lastStep = step;
      notifyListeners();
      await Future<void>.delayed(pause());
    }
    if (!stopped()) {
      _set(game.play(play));
    }
  }

  void _set(Game next) {
    _game = next;
    _resetTurn();
    _save();
    notifyListeners();
  }

  void _resetTurn() {
    _autoAction?.cancel();
    _steps = const [];
    _selected = null;
    _lastStep = null;
  }
}
