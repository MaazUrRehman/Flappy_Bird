import 'package:flutter_test/flutter_test.dart';
import 'package:flappy_bird/models/level_config.dart';

void main() {
  test('easy levels use distance, score, survival, coins sequence', () {
    final levelOne = LevelConfigGenerator.generateLevel(Difficulty.easy, 1);
    final levelTwo = LevelConfigGenerator.generateLevel(Difficulty.easy, 2);
    final levelFive = LevelConfigGenerator.generateLevel(Difficulty.easy, 5);

    expect(levelOne.streaks.length, 3);
    expect(
      levelOne.streaks.map((task) => task.type),
      [
        TaskType.distance,
        TaskType.score,
        TaskType.survival,
      ],
    );
    expect(
      levelOne.streaks.map((task) => task.target),
      [1000, 50, 30],
    );
    expect(
      levelTwo.streaks.map((task) => task.target),
      [1500, 100, 45],
    );
    expect(levelFive.streaks.length, 4);
    expect(
      levelFive.streaks.map((task) => task.type),
      [
        TaskType.distance,
        TaskType.score,
        TaskType.survival,
        TaskType.coins,
      ],
    );
  });

  test('streak count increases through 25 levels', () {
    expect(
      {
        1: 3,
        4: 3,
        5: 4,
        8: 4,
        9: 5,
        12: 5,
        13: 6,
        16: 6,
        17: 7,
        20: 7,
        21: 8,
        25: 8,
      }.entries.map(
            (entry) => LevelConfigGenerator.generateLevel(
              Difficulty.easy,
              entry.key,
            ).streaks.length,
          ),
      [3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8],
    );
  });

  test('survival streak time scales by difficulty and level', () {
    final expectations = {
      Difficulty.easy: [30, 45, 60],
      Difficulty.medium: [60, 90, 120],
      Difficulty.hard: [90, 135, 180],
      Difficulty.extreme: [120, 180, 240],
    };

    for (final entry in expectations.entries) {
      for (var level = 1; level <= entry.value.length; level++) {
        final config = LevelConfigGenerator.generateLevel(entry.key, level);
        final survivalTask = config.streaks.firstWhere(
          (task) => task.type == TaskType.survival,
        );

        expect(survivalTask.target, entry.value[level - 1]);
      }
    }
  });
}
