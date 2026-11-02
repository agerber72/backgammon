import 'dart:math';

/// Source of die results, so that tests can use fixed sequences.
abstract interface class DiceRoller {
  int roll();
}

/// Fair dice. Neither game state nor playing strength influence the result.
class RandomDiceRoller implements DiceRoller {
  RandomDiceRoller() : _random = Random.secure();

  final Random _random;

  @override
  int roll() => _random.nextInt(6) + 1;
}

class Dice {
  const Dice(this.first, this.second);

  factory Dice.rolledBy(DiceRoller roller) =>
      Dice(roller.roll(), roller.roll());

  final int first;
  final int second;

  bool get isDouble => first == second;

  int get higher => first > second ? first : second;

  /// The die value of every move this roll allows.
  List<int> get moves => isDouble ? List.filled(4, first) : [first, second];
}
