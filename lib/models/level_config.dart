enum Difficulty { easy, medium, hard, extreme }

enum TaskType { coins, score, distance }

class TaskConfig {
  final TaskType type;
  final int target;

  const TaskConfig({
    required this.type,
    required this.target,
  });

  String get description {
    switch (type) {
      case TaskType.coins:
        return 'Collect $target coins';
      case TaskType.score:
        return 'Reach score $target';
      case TaskType.distance:
        return 'Travel ${target}m distance';
    }
  }

  String get gameType {
    switch (type) {
      case TaskType.coins:
        return 'coins';
      case TaskType.score:
        return 'score';
      case TaskType.distance:
        return 'distance';
    }
  }
}

class LevelConfig {
  final Difficulty difficulty;
  final int levelNumber;
  final List<TaskConfig> streaks;

  const LevelConfig({
    required this.difficulty,
    required this.levelNumber,
    required this.streaks,
  });
}

class LevelConfigGenerator {
  static LevelConfig generateLevel(Difficulty difficulty, int level) {
    final base = _baseTasks(difficulty);
    final multiplier = _multiplier(difficulty);
    final scale = _pow(multiplier, level - 1);

    return LevelConfig(
      difficulty: difficulty,
      levelNumber: level,
      streaks: [
        TaskConfig(type: TaskType.coins, target: (base.coins * scale).ceil()),
        TaskConfig(type: TaskType.score, target: (base.score * scale).ceil()),
        TaskConfig(
          type: TaskType.distance,
          target: (base.distance * scale).ceil(),
        ),
      ],
    );
  }

  static Difficulty difficultyFromString(String value) {
    switch (value.toLowerCase()) {
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      case 'extreme':
        return Difficulty.extreme;
      case 'easy':
      default:
        return Difficulty.easy;
    }
  }

  static _BaseTasks _baseTasks(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const _BaseTasks(coins: 10, score: 50, distance: 1000);
      case Difficulty.medium:
        return const _BaseTasks(coins: 40, score: 120, distance: 3000);
      case Difficulty.hard:
        return const _BaseTasks(coins: 60, score: 150, distance: 5000);
      case Difficulty.extreme:
        return const _BaseTasks(coins: 100, score: 300, distance: 7000);
    }
  }

  static double _multiplier(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 1.25;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 1.75;
      case Difficulty.extreme:
        return 2.0;
    }
  }

  static double _pow(double base, int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

class _BaseTasks {
  final int coins;
  final int score;
  final int distance;

  const _BaseTasks({
    required this.coins,
    required this.score,
    required this.distance,
  });
}
