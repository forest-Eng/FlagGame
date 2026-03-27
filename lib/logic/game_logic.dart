import 'dart:math';

class GameLogic {
  GameLogic._();

  static const List<String> instructions = <String>[
    '赤上げて',
    '赤下げて',
    '白上げて',
    '白下げて',
  ];

  static String getNextInstruction({
    required Random random,
    required String previousInstruction,
  }) {
    String nextInstruction;

    do {
      nextInstruction = instructions[random.nextInt(instructions.length)];
    } while (
        instructions.length > 1 && nextInstruction == previousInstruction);

    return nextInstruction;
  }

  static bool isCorrectAnswer({
    required String instruction,
    required bool isRed,
    required bool isUp,
  }) {
    switch (instruction) {
      case '赤上げて':
        return isRed && isUp;
      case '赤下げて':
        return isRed && !isUp;
      case '白上げて':
        return !isRed && isUp;
      case '白下げて':
        return !isRed && !isUp;
      default:
        return false;
    }
  }
}