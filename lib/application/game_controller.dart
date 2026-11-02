import 'package:flutter/foundation.dart';

import '../domain/board.dart';
import '../domain/dice.dart';
import '../domain/game.dart';
import '../domain/move_generator.dart';

/// Connects a running game with the user interface. During a turn it collects
/// single checker moves, which only become part of the game on [confirm].
class GameController extends ChangeNotifier {
  GameController({DiceRoller? roller, Game? game})
    : _roller = roller ?? RandomDiceRoller() {
    _game = game;
  }

  final DiceRoller _roller;
  Game? _game;
  List<Step> _steps = const [];
  int? _selected;
  Step? _lastStep;

  /// Null until the player has started a game.
  Game? get game => _game;

  int? get selected => _selected;

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
    if (game == null || game.phase != GamePhase.awaitingPlay) {
      return const [];
    }
    return nextSteps(game.board, game.turn, game.dice!, _steps);
  }

  /// Where a checker can start from right now.
  Set<int> get sources => _options.map((step) => step.from).toSet();

  /// Where the selected checker can go.
  Set<int> get targets => _options
      .where((step) => step.from == _selected)
      .map((step) => step.to)
      .toSet();

  bool get mustPass {
    final game = _game;
    return game != null &&
        game.phase == GamePhase.awaitingPlay &&
        game.plays.isEmpty;
  }

  bool get canConfirm {
    final game = _game;
    return game != null &&
        game.phase == GamePhase.awaitingPlay &&
        !mustPass &&
        _options.isEmpty;
  }

  void startGame() {
    _game = Game.start(_roller);
    _resetTurn();
    notifyListeners();
  }

  void roll() => _update(_game!.roll(_roller));

  void offerDouble() => _update(_game!.offerDouble());

  void acceptDouble() => _update(_game!.acceptDouble());

  void refuseDouble() => _update(_game!.refuseDouble());

  void pass() => _update(_game!.pass());

  void confirm() => _update(_game!.play(Play(_steps, board)));

  /// Takes back all moves of the current turn.
  void undo() {
    _resetTurn();
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
    final step = _options.firstWhere(
      (step) => step.from == _selected && step.to == target,
    );
    _steps = [..._steps, step];
    _lastStep = step;
    _selected = null;
    final remaining = sources;
    if (remaining.length == 1) {
      _selected = remaining.single;
    }
    notifyListeners();
  }

  void _update(Game next) {
    _game = next;
    _resetTurn();
    notifyListeners();
  }

  void _resetTurn() {
    _steps = const [];
    _selected = null;
    _lastStep = null;
  }
}
