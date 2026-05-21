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
      [1000, 50, 100],
    );
    expect(
      levelTwo.streaks.map((task) => task.target),
      [1500, 100, 200],
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
}
