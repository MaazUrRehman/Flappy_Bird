/// DifficultyConfig - Defines difficulty settings for each level
class DifficultyConfig {
  final String difficulty;
  final double pipeSpeed;
  final double gapSize;
  final int targetScore;
  final int coinTarget;
  final int distanceTarget;
  final int survivalTime;
  final bool hasMovingPipes;
  final bool hasRandomPatterns;

  const DifficultyConfig({
    required this.difficulty,
    required this.pipeSpeed,
    required this.gapSize,
    required this.targetScore,
    required this.coinTarget,
    required this.distanceTarget,
    required this.survivalTime,
    this.hasMovingPipes = false,
    this.hasRandomPatterns = false,
  });

  // Factory constructors for each difficulty
  factory DifficultyConfig.easy() => const DifficultyConfig(
        difficulty: 'easy',
        pipeSpeed: 140,
        gapSize: 220,
        targetScore: 5,
        coinTarget: 3,
        distanceTarget: 200,
        survivalTime: 30,
      );

  factory DifficultyConfig.medium() => const DifficultyConfig(
        difficulty: 'medium',
        pipeSpeed: 190,
        gapSize: 185,
        targetScore: 15,
        coinTarget: 8,
        distanceTarget: 400,
        survivalTime: 60,
      );

  factory DifficultyConfig.hard() => const DifficultyConfig(
        difficulty: 'hard',
        pipeSpeed: 245,
        gapSize: 155,
        targetScore: 25,
        coinTarget: 12,
        distanceTarget: 600,
        survivalTime: 90,
        hasMovingPipes: true,
      );

  factory DifficultyConfig.extreme() => const DifficultyConfig(
        difficulty: 'extreme',
        pipeSpeed: 310,
        gapSize: 130,
        targetScore: 50,
        coinTarget: 20,
        distanceTarget: 800,
        survivalTime: 120,
        hasMovingPipes: true,
        hasRandomPatterns: true,
      );

  // Get config by difficulty string
  static DifficultyConfig fromString(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return DifficultyConfig.easy();
      case 'medium':
        return DifficultyConfig.medium();
      case 'hard':
        return DifficultyConfig.hard();
      case 'extreme':
        return DifficultyConfig.extreme();
      default:
        return DifficultyConfig.easy();
    }
  }
}
