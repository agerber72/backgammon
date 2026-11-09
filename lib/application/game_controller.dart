import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/dice_stats.dart';
import '../domain/game.dart';
import '../domain/move_generator.dart';
import '../engine/engine.dart';
import '../engine/race.dart';
import '../persistence/session_store.dart';
import 'game_pace.dart';

export 'game_pace.dart';

/// Connects a running game with the user interface. During a turn it collects
/// single checker moves, which only become part of the game on [confirm].
class GameController extends ChangeNotifier {
  GameController({
    DiceRoller? roller,
    Game? game,
    Engine? engine,
    SessionStore? store,
    Duration? computerPause,
    this.autoFinishPause = const Duration(milliseconds: 300),
    Duration? autoActionDelay = defaultDelay,
    DateTime Function()? clock,
  }) : _roller = roller ?? RandomDiceRoller(),
       _engine = engine ?? HeuristicEngine(),
       _clock = clock ?? DateTime.now,
       _fixedComputerPause = computerPause {
    _store = store;
    _game = game;
    _autoActionDelay = autoActionDelay;
    _pace = autoActionDelay == null ? GamePace.off : GamePace.normal;
  }

  /// The waiting time of the default pace.
  static const defaultDelay = Duration(seconds: 2);

  /// How long the dice wait after the computer's turn when the person cannot
  /// double: just long enough for the last checker to arrive.
  static const _settleDelay = Duration(milliseconds: 400);

  final DiceRoller _roller;
  final Engine _engine;
  final DateTime Function() _clock;
  late final SessionStore? _store;

  /// Set by tests; otherwise the pace decides.
  final Duration? _fixedComputerPause;

  /// Time between the computer's actions, so that a person can follow them.
  Duration get computerPause => _fixedComputerPause ?? _pace.computerPause;

  /// Time between moves while the game plays itself to the end.
  final Duration autoFinishPause;

  Duration? _autoActionDelay;
  late GamePace _pace;
  var _autoForced = false;
  var _playingForced = false;
  var _doubleRequested = false;
  Countdown? _countdown;

  /// Time to take back a move with alternatives, or to double before the
  /// dice roll by themselves; null turns everything automatic off.
  Duration? get autoActionDelay => _autoActionDelay;

  GamePace get pace => _pace;

  /// Whether the app sets a forced move by itself.
  bool get autoForced => _autoForced;

  /// True while the app sets a forced move; the person waits meanwhile.
  bool get playingForced => _playingForced;

  /// The countdown running now, if any, for the ring around its symbol.
  Countdown? get countdown => _countdown;

  Player? _human;
  Difficulty _difficulty = Difficulty.medium;
  Player? _preferredHuman;
  Difficulty? _preferredDifficulty;
  DiceStats _gameStats = DiceStats();
  DiceStats _totalStats = DiceStats();
  GameRecords _records = GameRecords();
  final _language = ValueNotifier<String?>(null);
  Duration _playedBefore = Duration.zero;
  DateTime? _playingSince;
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

  /// Language code of the interface, `de` or `en`; null follows the system
  /// language. A separate listenable, so the app only rebuilds on a change.
  ValueListenable<String?> get language => _language;

  /// Switches the language at once and keeps the choice.
  void updateLanguage(String? code) {
    _language.value = code;
    _save();
  }

  /// The personal leaderboard. Only kept where the app saves its state, so
  /// not in the web version.
  GameRecords get records => _records;

  bool get keepsRecords => _store != null;

  /// Time the app has been open during the current game.
  Duration get playTime {
    final since = _playingSince;
    return since == null
        ? _playedBefore
        : _playedBefore + _clock().difference(since);
  }

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
    _pace = session.pace;
    _autoActionDelay = _pace.decision;
    _autoForced = session.autoForced;
    _gameStats = session.gameStats;
    _totalStats = session.totalStats;
    _records = session.records;
    _language.value = session.language;
    _playedBefore = Duration(seconds: session.playSeconds);
    _playingSince = _game == null ? null : _clock();
    _selectOnlySource();
    notifyListeners();
    _letComputerAct();
  }

  /// Changes the pace at once; a running countdown stops, and a new one
  /// starts with the next decision.
  void updatePace(GamePace pace) {
    _pace = pace;
    _autoActionDelay = pace.decision;
    _cancelCountdown();
    _save();
    notifyListeners();
  }

  void updateAutoForced(bool value) {
    _autoForced = value;
    _save();
    notifyListeners();
    _scheduleAutoRoll();
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
    if (game == null ||
        game.phase != GamePhase.awaitingPlay ||
        !isHumanTurn ||
        _playingForced) {
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
        !_playingForced &&
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
    _playedBefore = Duration.zero;
    _playingSince = _clock();
    _resetTurn();
    _selectOnlySource();
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
    _cancelCountdown();
    _language.dispose();
    super.dispose();
  }

  void roll() {
    _doubleRequested = false;
    _update(_rolled(_game!));
  }

  /// Whether the person holds the right to double in this game, whatever
  /// the phase: the cube is in the middle or theirs and can still grow.
  bool get mayDouble {
    final game = _game;
    final human = _human;
    return game != null &&
        human != null &&
        !_autoFinishing &&
        game.phase != GamePhase.finished &&
        game.cube.value < Cube.maxValue &&
        (game.cube.owner == null || game.cube.owner == human);
  }

  /// True while the person wants to double at the next chance.
  bool get doubleRequested => _doubleRequested && mayDouble;

  /// Doubles now if the rules allow it; otherwise marks the wish, and at the
  /// next chance the dice wait for the person instead of rolling by
  /// themselves. A second tap takes the wish back.
  void requestDouble() {
    final game = _game!;
    if (game.canDouble && isHumanTurn) {
      offerDouble();
      return;
    }
    _doubleRequested = !_doubleRequested;
    notifyListeners();
  }

  /// The person rolls with the wish to double still open: the app asks.
  bool get asksToDouble {
    final game = _game;
    return game != null &&
        doubleRequested &&
        isHumanTurn &&
        game.phase == GamePhase.awaitingRoll &&
        game.canDouble;
  }

  Game _rolled(Game game) {
    final next = game.roll(_roller);
    _gameStats.addRoll(game.turn, next.dice!);
    _totalStats.addRoll(game.turn, next.dice!);
    return next;
  }

  void offerDouble() {
    _doubleRequested = false;
    _update(_game!.offerDouble());
  }

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
    _cancelCountdown();
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
    _cancelCountdown();
    _steps = _steps.sublist(0, _steps.length - 1);
    _lastStep = null;
    _selectOnlySource();
    notifyListeners();
  }

  /// Handles a tap on a point, the bar or the tray. A tap while a finished
  /// move waits for its end starts the waiting time anew.
  void tap(int position) {
    final countdown = _countdown;
    if (countdown?.action == AutoAction.confirm) {
      _startCountdown(AutoAction.confirm, countdown!.duration, confirm);
    }
    if (_selected != null && targets.contains(position)) {
      _move(position);
    } else if (sources.contains(position)) {
      // The only checker that can move stays selected; deselecting it would
      // only add a tap.
      final only = sources.length == 1;
      _selected = position == _selected && !only ? null : position;
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
    if (delay == null || !canConfirm) {
      return;
    }
    // Without any alternative there is nothing to take back.
    if (_game!.plays.length == 1) {
      confirm();
    } else {
      _startCountdown(AutoAction.confirm, delay, confirm);
    }
  }

  void _startCountdown(AutoAction action, Duration delay, VoidCallback run) {
    _autoAction?.cancel();
    _countdown = Countdown(action, _clock(), delay);
    _autoAction = Timer(delay, () {
      _countdown = null;
      run();
    });
    notifyListeners();
  }

  void _cancelCountdown() {
    _autoAction?.cancel();
    _countdown = null;
  }

  /// Selects the checker when only one can move, as with a checker on the
  /// bar that must enter first, at the start of a turn and after each move.
  void _selectOnlySource() {
    _selected = null;
    final remaining = sources;
    if (remaining.length == 1) {
      _selected = remaining.single;
    }
  }

  void _update(Game next) {
    _recordIfFinished(next);
    _game = next;
    _resetTurn();
    _selectOnlySource();
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
      pace: _pace,
      autoForced: _autoForced,
      gameStats: _gameStats,
      totalStats: _totalStats,
      playSeconds: playTime.inSeconds,
      language: _language.value,
      records: _records,
    );
    // One after the other, so that an older state cannot overwrite a newer one.
    _lastSave = _lastSave.then((_) => store.save(session));
  }

  /// Adds a game against the computer to the leaderboard when it ends.
  void _recordIfFinished(Game next) {
    final human = _human;
    final result = next.result;
    if (human == null ||
        result == null ||
        _game?.phase == GamePhase.finished ||
        !keepsRecords) {
      return;
    }
    _records.add(
      GameRecord(
        finishedAt: _clock(),
        difficulty: _difficulty,
        color: human,
        playTime: playTime,
        points: result.winner == human ? result.points : 0,
        computerPoints: result.winner == human ? 0 : result.points,
      ),
    );
    _playedBefore = playTime;
    _playingSince = null;
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
  /// rolls or doubles first; without the right to double they roll at once.
  /// A roll without any move goes on by itself as well, and a forced move
  /// plays itself if the person wants that.
  void _scheduleAutoRoll() {
    final game = _game;
    if (game == null || !isHumanTurn || _countdown != null) {
      return;
    }
    if (_autoForced &&
        _human != null &&
        game.phase == GamePhase.awaitingPlay &&
        _steps.isEmpty &&
        game.plays.length == 1) {
      _playForced(game);
      return;
    }
    final delay = autoActionDelay;
    if (delay == null) {
      return;
    }
    if (_human != null && game.phase == GamePhase.awaitingRoll) {
      // The person asked to double: no roll by itself, the app asks.
      if (asksToDouble) {
        return;
      }
      final wait = game.canDouble
          ? delay
          : (delay < _settleDelay ? delay : _settleDelay);
      _startCountdown(AutoAction.roll, wait, roll);
    } else if (mustPass) {
      _startCountdown(AutoAction.pass, delay * 0.6, pass);
    }
  }

  /// Sets the only possible move checker by checker, like the computer does,
  /// and ends the turn.
  Future<void> _playForced(Game game) async {
    final number = _gameNumber;
    final play = game.plays.single;
    bool stopped() =>
        _disposed || number != _gameNumber || !identical(_game, game);
    _playingForced = true;
    _selected = null;
    notifyListeners();
    for (final step in play.steps) {
      await Future<void>.delayed(computerPause);
      if (stopped()) {
        _playingForced = false;
        return;
      }
      _steps = [..._steps, step];
      _lastStep = step;
      _selected = null;
      notifyListeners();
    }
    await Future<void>.delayed(computerPause);
    _playingForced = false;
    if (!stopped()) {
      _update(game.play(play));
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
    // While the game plays itself to the end, both sides race home and bear
    // off as fast as they can, whatever the chosen level.
    final play = _autoFinishing
        ? racePlay(game.board, game.turn, game.dice!)
        : await _engine.choosePlay(
            game.board,
            game.turn,
            game.dice!,
            _difficulty,
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
    _recordIfFinished(next);
    _game = next;
    _resetTurn();
    _selectOnlySource();
    _save();
    notifyListeners();
  }

  void _resetTurn() {
    _cancelCountdown();
    _steps = const [];
    _selected = null;
    _lastStep = null;
  }
}
