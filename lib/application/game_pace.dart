/// How quickly the game goes on by itself. Each level sets the waiting times
/// for all situations at once.
enum GamePace {
  /// Nothing happens by itself; the computer still plays its own turns.
  off(null, Duration(milliseconds: 550)),
  relaxed(Duration(seconds: 4), Duration(milliseconds: 800)),
  normal(Duration(seconds: 2), Duration(milliseconds: 550)),
  fast(Duration(seconds: 1), Duration(milliseconds: 300));

  const GamePace(this.decision, this.computerPause);

  /// Time to take back a move with alternatives, or to double before the
  /// dice roll by themselves; null waits for the person.
  final Duration? decision;

  /// Time between the computer's single moves.
  final Duration computerPause;

  /// A setting from before version 1.1, which stored seconds.
  static GamePace fromSeconds(int seconds) => switch (seconds) {
    0 => off,
    <= 3 => normal,
    _ => relaxed,
  };
}

/// What the app does by itself when a countdown ends.
enum AutoAction { confirm, roll, pass }

/// A running countdown, for the ring around its symbol.
class Countdown {
  const Countdown(this.action, this.start, this.duration);

  final AutoAction action;
  final DateTime start;
  final Duration duration;
}
