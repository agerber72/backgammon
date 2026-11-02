import 'board.dart';
import 'dice.dart';
import 'move_generator.dart';

enum GamePhase { awaitingRoll, awaitingPlay, awaitingDoubleResponse, finished }

enum WinType {
  single(1),
  gammon(2),
  backgammon(3);

  const WinType(this.multiplier);

  final int multiplier;
}

class GameResult {
  const GameResult(this.winner, this.type, this.points);

  final Player winner;
  final WinType type;
  final int points;
}

class Cube {
  const Cube({this.value = 1, this.owner});

  static const maxValue = 64;

  final int value;

  /// Null while the cube is in the middle and either player may double.
  final Player? owner;
}

/// State of one game. All actions return a new state.
class Game {
  const Game._({
    required this.board,
    required this.turn,
    required this.phase,
    this.dice,
    this.cube = const Cube(),
    this.result,
  });

  /// Starts with the opening roll: each player throws one die, ties repeat.
  factory Game.start(DiceRoller roller, {Board? board}) {
    while (true) {
      final white = roller.roll();
      final black = roller.roll();
      if (white != black) {
        return Game._(
          board: board ?? Board.start(),
          turn: white > black ? Player.white : Player.black,
          phase: GamePhase.awaitingPlay,
          dice: Dice(white, black),
        );
      }
    }
  }

  /// A game at any point, for tests and for loading a saved game.
  const Game.at({
    required Board board,
    required Player turn,
    required GamePhase phase,
    Dice? dice,
    Cube cube = const Cube(),
    GameResult? result,
  }) : this._(
         board: board,
         turn: turn,
         phase: phase,
         dice: dice,
         cube: cube,
         result: result,
       );

  final Board board;
  final Player turn;
  final GamePhase phase;
  final Dice? dice;
  final Cube cube;
  final GameResult? result;

  bool get canDouble =>
      phase == GamePhase.awaitingRoll &&
      cube.value < Cube.maxValue &&
      (cube.owner == null || cube.owner == turn);

  List<Play> get plays => phase == GamePhase.awaitingPlay
      ? legalPlays(board, turn, dice!)
      : const [];

  Game roll(DiceRoller roller) {
    _require(GamePhase.awaitingRoll);
    return _copy(phase: GamePhase.awaitingPlay, dice: Dice.rolledBy(roller));
  }

  Game offerDouble() {
    if (!canDouble) {
      throw StateError('Doubling is not allowed now');
    }
    return _copy(phase: GamePhase.awaitingDoubleResponse);
  }

  Game acceptDouble() {
    _require(GamePhase.awaitingDoubleResponse);
    return _copy(
      phase: GamePhase.awaitingRoll,
      cube: Cube(value: cube.value * 2, owner: turn.opponent),
    );
  }

  /// The doubled player gives up and pays the value before the double.
  Game refuseDouble() {
    _require(GamePhase.awaitingDoubleResponse);
    return _copy(
      phase: GamePhase.finished,
      result: GameResult(turn, WinType.single, cube.value),
    );
  }

  Game play(Play play) {
    _require(GamePhase.awaitingPlay);
    final allowed = plays.any((p) => p.result.key == play.result.key);
    if (!allowed) {
      throw ArgumentError('Illegal play');
    }
    final next = play.result;
    if (next.off(turn) == Board.checkersPerPlayer) {
      final type = _winType(next, turn);
      return Game._(
        board: next,
        turn: turn,
        phase: GamePhase.finished,
        cube: cube,
        result: GameResult(turn, type, type.multiplier * cube.value),
      );
    }
    return _nextTurn(next);
  }

  /// Ends a turn without a legal move.
  Game pass() {
    _require(GamePhase.awaitingPlay);
    if (plays.isNotEmpty) {
      throw StateError('A legal play exists');
    }
    return _nextTurn(board);
  }

  Game _nextTurn(Board next) => Game._(
    board: next,
    turn: turn.opponent,
    phase: GamePhase.awaitingRoll,
    cube: cube,
  );

  void _require(GamePhase expected) {
    if (phase != expected) {
      throw StateError('Expected phase $expected, was $phase');
    }
  }

  Game _copy({
    required GamePhase phase,
    Dice? dice,
    Cube? cube,
    GameResult? result,
  }) => Game._(
    board: board,
    turn: turn,
    phase: phase,
    dice: dice,
    cube: cube ?? this.cube,
    result: result,
  );

  static WinType _winType(Board board, Player winner) {
    final loser = winner.opponent;
    if (board.off(loser) > 0) {
      return WinType.single;
    }
    var inWinnersHome = board.bar(loser) > 0;
    for (var point = 1; point <= Board.pointCount; point++) {
      if (board.count(loser, point) > 0 && Board.isHome(winner, point)) {
        inWinnersHome = true;
      }
    }
    return inWinnersHome ? WinType.backgammon : WinType.gammon;
  }
}
