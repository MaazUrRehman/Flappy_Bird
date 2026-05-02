enum StreakType { coins, distance, score, survival }

class Streak {
  final int id;
  final StreakType type;
  final int target;
  final String description;

  const Streak({
    required this.id,
    required this.type,
    required this.target,
    required this.description,
  });
}

class StreakConfig {
  final String difficulty;
  final int level;
  final List<Streak> streaks;

  const StreakConfig({
    required this.difficulty,
    required this.level,
    required this.streaks,
  });
}

class StreakData {
  static const List<StreakConfig> easyStreaks = [
    StreakConfig(
      difficulty: 'easy',
      level: 1,
      streaks: [
        Streak(
            id: 1,
            type: StreakType.coins,
            target: 10,
            description: 'Collect 10 coins'),
        Streak(
            id: 2,
            type: StreakType.distance,
            target: 500,
            description: 'Cover 500m distance'),
        Streak(
            id: 3,
            type: StreakType.score,
            target: 50,
            description: 'Score 50 points'),
      ],
    ),
    StreakConfig(
      difficulty: 'easy',
      level: 2,
      streaks: [
        Streak(
            id: 4,
            type: StreakType.coins,
            target: 25,
            description: 'Collect 25 coins'),
        Streak(
            id: 5,
            type: StreakType.distance,
            target: 1000,
            description: 'Cover 1000m distance'),
        Streak(
            id: 6,
            type: StreakType.score,
            target: 150,
            description: 'Score 150 points'),
        Streak(
            id: 7,
            type: StreakType.survival,
            target: 60,
            description: 'Survive 60 seconds'),
      ],
    ),
    StreakConfig(
      difficulty: 'easy',
      level: 3,
      streaks: [
        Streak(
            id: 8,
            type: StreakType.coins,
            target: 40,
            description: 'Collect 40 coins'),
        Streak(
            id: 9,
            type: StreakType.distance,
            target: 1500,
            description: 'Cover 1500m distance'),
        Streak(
            id: 10,
            type: StreakType.score,
            target: 250,
            description: 'Score 250 points'),
        Streak(
            id: 11,
            type: StreakType.survival,
            target: 90,
            description: 'Survive 90 seconds'),
      ],
    ),
  ];

  static const List<StreakConfig> mediumStreaks = [
    StreakConfig(
      difficulty: 'medium',
      level: 1,
      streaks: [
        Streak(
            id: 12,
            type: StreakType.coins,
            target: 15,
            description: 'Collect 15 coins'),
        Streak(
            id: 13,
            type: StreakType.distance,
            target: 750,
            description: 'Cover 750m distance'),
        Streak(
            id: 14,
            type: StreakType.score,
            target: 75,
            description: 'Score 75 points'),
      ],
    ),
    StreakConfig(
      difficulty: 'medium',
      level: 2,
      streaks: [
        Streak(
            id: 15,
            type: StreakType.coins,
            target: 35,
            description: 'Collect 35 coins'),
        Streak(
            id: 16,
            type: StreakType.distance,
            target: 1250,
            description: 'Cover 1250m distance'),
        Streak(
            id: 17,
            type: StreakType.score,
            target: 200,
            description: 'Score 200 points'),
        Streak(
            id: 18,
            type: StreakType.survival,
            target: 75,
            description: 'Survive 75 seconds'),
      ],
    ),
    StreakConfig(
      difficulty: 'medium',
      level: 3,
      streaks: [
        Streak(
            id: 19,
            type: StreakType.coins,
            target: 50,
            description: 'Collect 50 coins'),
        Streak(
            id: 20,
            type: StreakType.distance,
            target: 2000,
            description: 'Cover 2000m distance'),
        Streak(
            id: 21,
            type: StreakType.score,
            target: 350,
            description: 'Score 350 points'),
        Streak(
            id: 22,
            type: StreakType.survival,
            target: 120,
            description: 'Survive 120 seconds'),
      ],
    ),
  ];

  static const List<StreakConfig> hardStreaks = [
    StreakConfig(
      difficulty: 'hard',
      level: 1,
      streaks: [
        Streak(
            id: 23,
            type: StreakType.coins,
            target: 20,
            description: 'Collect 20 coins'),
        Streak(
            id: 24,
            type: StreakType.distance,
            target: 1000,
            description: 'Cover 1000m distance'),
        Streak(
            id: 25,
            type: StreakType.score,
            target: 100,
            description: 'Score 100 points'),
      ],
    ),
    StreakConfig(
      difficulty: 'hard',
      level: 2,
      streaks: [
        Streak(
            id: 26,
            type: StreakType.coins,
            target: 45,
            description: 'Collect 45 coins'),
        Streak(
            id: 27,
            type: StreakType.distance,
            target: 1500,
            description: 'Cover 1500m distance'),
        Streak(
            id: 28,
            type: StreakType.score,
            target: 250,
            description: 'Score 250 points'),
        Streak(
            id: 29,
            type: StreakType.survival,
            target: 90,
            description: 'Survive 90 seconds'),
      ],
    ),
    StreakConfig(
      difficulty: 'hard',
      level: 3,
      streaks: [
        Streak(
            id: 30,
            type: StreakType.coins,
            target: 60,
            description: 'Collect 60 coins'),
        Streak(
            id: 31,
            type: StreakType.distance,
            target: 2500,
            description: 'Cover 2500m distance'),
        Streak(
            id: 32,
            type: StreakType.score,
            target: 450,
            description: 'Score 450 points'),
        Streak(
            id: 33,
            type: StreakType.survival,
            target: 150,
            description: 'Survive 150 seconds'),
      ],
    ),
  ];

  static const List<StreakConfig> extremeStreaks = [
    StreakConfig(
      difficulty: 'extreme',
      level: 1,
      streaks: [
        Streak(
            id: 34,
            type: StreakType.coins,
            target: 25,
            description: 'Collect 25 coins'),
        Streak(
            id: 35,
            type: StreakType.distance,
            target: 1250,
            description: 'Cover 1250m distance'),
        Streak(
            id: 36,
            type: StreakType.score,
            target: 125,
            description: 'Score 125 points'),
      ],
    ),
    StreakConfig(
      difficulty: 'extreme',
      level: 2,
      streaks: [
        Streak(
            id: 37,
            type: StreakType.coins,
            target: 55,
            description: 'Collect 55 coins'),
        Streak(
            id: 38,
            type: StreakType.distance,
            target: 1750,
            description: 'Cover 1750m distance'),
        Streak(
            id: 39,
            type: StreakType.score,
            target: 300,
            description: 'Score 300 points'),
        Streak(
            id: 40,
            type: StreakType.survival,
            target: 105,
            description: 'Survive 105 seconds'),
      ],
    ),
    StreakConfig(
      difficulty: 'extreme',
      level: 3,
      streaks: [
        Streak(
            id: 41,
            type: StreakType.coins,
            target: 75,
            description: 'Collect 75 coins'),
        Streak(
            id: 42,
            type: StreakType.distance,
            target: 3000,
            description: 'Cover 3000m distance'),
        Streak(
            id: 43,
            type: StreakType.score,
            target: 550,
            description: 'Score 550 points'),
        Streak(
            id: 44,
            type: StreakType.survival,
            target: 180,
            description: 'Survive 180 seconds'),
      ],
    ),
  ];

  static List<Streak> getStreaksForLevel(String difficulty, int level) {
    final allConfigs = [
      ...easyStreaks,
      ...mediumStreaks,
      ...hardStreaks,
      ...extremeStreaks
    ];

    for (final config in allConfigs) {
      if (config.difficulty == difficulty && config.level == level) {
        return config.streaks;
      }
    }

    return [];
  }

  static List<Streak> getAllStreaksForDifficulty(String difficulty) {
    final allConfigs = [
      ...easyStreaks,
      ...mediumStreaks,
      ...hardStreaks,
      ...extremeStreaks
    ];

    return allConfigs
        .where((config) => config.difficulty == difficulty)
        .expand((config) => config.streaks)
        .toList();
  }
}
