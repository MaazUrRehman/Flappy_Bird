enum Difficulty { easy, medium, hard, extreme }

enum TaskType {
  coins,
  score,
  distance,
  survival,
  pipes,
  flaps,
  coinScore,
  pipeScore,
  marathonScore,
}

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
      case TaskType.survival:
        return 'Survive for $target seconds';
      case TaskType.pipes:
        return 'Pass $target pipes';
      case TaskType.flaps:
        return 'Make $target clean flaps';
      case TaskType.coinScore:
        return 'Earn $target points from coins';
      case TaskType.pipeScore:
        return 'Earn $target points from passing pipes';
      case TaskType.marathonScore:
        return 'Reach marathon score $target';
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
      case TaskType.survival:
        return 'time';
      case TaskType.pipes:
        return 'pipes';
      case TaskType.flaps:
        return 'flaps';
      case TaskType.coinScore:
        return 'coinScore';
      case TaskType.pipeScore:
        return 'pipeScore';
      case TaskType.marathonScore:
        return 'score';
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
  static const int maxLevel = 25;

  static LevelConfig generateLevel(Difficulty difficulty, int level) {
    final base = _baseTasks(difficulty);
    final growth = _growth(difficulty);
    final streakCount = _streakCountForLevel(level);
    final tasks = <TaskConfig>[
      TaskConfig(
        type: TaskType.distance,
        target: _targetForLevel(base.distance, growth.distance, level),
      ),
      TaskConfig(
        type: TaskType.score,
        target: _targetForLevel(base.score, growth.score, level),
      ),
      TaskConfig(
        type: TaskType.survival,
        target: _survivalTargetForLevel(base.survival, growth.survival, level),
      ),
      TaskConfig(
        type: TaskType.coins,
        target: _targetForLevel(base.coins, growth.coins, level),
      ),
      TaskConfig(
        type: TaskType.pipes,
        target: _targetForLevel(base.pipes, growth.pipes, level),
      ),
      TaskConfig(
        type: TaskType.flaps,
        target: _targetForLevel(base.flaps, growth.flaps, level),
      ),
      TaskConfig(
        type: TaskType.coinScore,
        target: _targetForLevel(base.coinScore, growth.coinScore, level),
      ),
      TaskConfig(
        type: TaskType.pipeScore,
        target: _targetForLevel(base.pipeScore, growth.pipeScore, level),
      ),
      TaskConfig(
        type: TaskType.marathonScore,
        target:
            _targetForLevel(base.marathonScore, growth.marathonScore, level),
      ),
    ];

    return LevelConfig(
      difficulty: difficulty,
      levelNumber: level,
      streaks: tasks.take(streakCount).toList(),
    );
  }

  static int _streakCountForLevel(int level) {
    if (level <= 4) return 3;
    if (level <= 8) return 4;
    if (level <= 12) return 5;
    if (level <= 16) return 6;
    if (level <= 20) return 7;
    return 8;
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
        return const _BaseTasks(
          coins: 40,
          score: 50,
          distance: 1000,
          survival: 30,
          pipes: 12,
          flaps: 35,
          coinScore: 18,
          pipeScore: 70,
          marathonScore: 110,
        );
      case Difficulty.medium:
        return const _BaseTasks(
          coins: 60,
          score: 100,
          distance: 1500,
          survival: 60,
          pipes: 18,
          flaps: 50,
          coinScore: 55,
          pipeScore: 115,
          marathonScore: 220,
        );
      case Difficulty.hard:
        return const _BaseTasks(
          coins: 80,
          score: 150,
          distance: 2000,
          survival: 90,
          pipes: 24,
          flaps: 65,
          coinScore: 85,
          pipeScore: 160,
          marathonScore: 320,
        );
      case Difficulty.extreme:
        return const _BaseTasks(
          coins: 100,
          score: 200,
          distance: 2500,
          survival: 120,
          pipes: 30,
          flaps: 80,
          coinScore: 135,
          pipeScore: 220,
          marathonScore: 520,
        );
    }
  }

  static _TaskGrowth _growth(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const _TaskGrowth(
          coins: 40,
          score: 50,
          distance: 500,
          survival: 15,
          pipes: 8,
          flaps: 20,
          coinScore: 20,
          pipeScore: 50,
          marathonScore: 100,
        );
      case Difficulty.medium:
        return const _TaskGrowth(
          coins: 60,
          score: 100,
          distance: 1000,
          survival: 30,
          pipes: 10,
          flaps: 25,
          coinScore: 35,
          pipeScore: 75,
          marathonScore: 150,
        );
      case Difficulty.hard:
        return const _TaskGrowth(
          coins: 80,
          score: 150,
          distance: 1500,
          survival: 45,
          pipes: 12,
          flaps: 30,
          coinScore: 50,
          pipeScore: 100,
          marathonScore: 200,
        );
      case Difficulty.extreme:
        return const _TaskGrowth(
          coins: 100,
          score: 200,
          distance: 2000,
          survival: 60,
          pipes: 15,
          flaps: 35,
          coinScore: 75,
          pipeScore: 150,
          marathonScore: 300,
        );
    }
  }

  static int _targetForLevel(int base, int growth, int level) {
    return _roundUp(base + (growth * (level - 1)), _roundingStep(growth));
  }

  static int _survivalTargetForLevel(int base, int growth, int level) {
    return base + (growth * (level - 1));
  }

  static int _roundingStep(int growth) {
    if (growth >= 100) return 100;
    if (growth >= 50) return 50;
    if (growth >= 10) return 10;
    return 5;
  }

  static int _roundUp(int value, int step) {
    return ((value + step - 1) ~/ step) * step;
  }
}

class _BaseTasks {
  final int coins;
  final int score;
  final int distance;
  final int survival;
  final int pipes;
  final int flaps;
  final int coinScore;
  final int pipeScore;
  final int marathonScore;

  const _BaseTasks({
    required this.coins,
    required this.score,
    required this.distance,
    required this.survival,
    required this.pipes,
    required this.flaps,
    required this.coinScore,
    required this.pipeScore,
    required this.marathonScore,
  });
}

class _TaskGrowth {
  final int coins;
  final int score;
  final int distance;
  final int survival;
  final int pipes;
  final int flaps;
  final int coinScore;
  final int pipeScore;
  final int marathonScore;

  const _TaskGrowth({
    required this.coins,
    required this.score,
    required this.distance,
    required this.survival,
    required this.pipes,
    required this.flaps,
    required this.coinScore,
    required this.pipeScore,
    required this.marathonScore,
  });
}
