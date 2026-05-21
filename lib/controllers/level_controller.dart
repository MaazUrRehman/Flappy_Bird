import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/level_config.dart';

class LevelController extends GetxController {
  static LevelController get instance => Get.find<LevelController>();

  static const String _boxName = 'levelProgress';
  static const String _legacyGameStateBox = 'gameState';
  static const String _completedStreaksKey = 'completedStreaks';
  static const String _unlockedLevelsKey = 'unlockedLevels';

  final RxList<String> completedStreaks = <String>[].obs;
  final RxMap<String, int> unlockedLevels = <String, int>{
    'easy': 1,
    'medium': 1,
    'hard': 1,
    'extreme': 1,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);

    final completed = box.get(_completedStreaksKey);
    if (completed != null) {
      completedStreaks.value = List<String>.from(completed);
    }

    // Keep progress created by the older GameStateController path.
    final legacyBox = await Hive.openBox(_legacyGameStateBox);
    final legacyCompleted = legacyBox.get(_completedStreaksKey);
    if (legacyCompleted != null) {
      for (final key in List<String>.from(legacyCompleted)) {
        if (!completedStreaks.contains(key)) {
          completedStreaks.add(key);
        }
      }
    }

    final savedLevels = box.get(_unlockedLevelsKey);
    if (savedLevels != null) {
      unlockedLevels.value = Map<String, int>.from(savedLevels);
    }

    _recalculateUnlockedLevels();
    await _save();
  }

  LevelConfig generateLevel(String difficulty, int level) {
    return LevelConfigGenerator.generateLevel(
      LevelConfigGenerator.difficultyFromString(difficulty),
      level,
    );
  }

  bool isLevelUnlocked(String difficulty, int level) {
    return level <= LevelConfigGenerator.maxLevel &&
        level <= (unlockedLevels[difficulty] ?? 1);
  }

  bool isLevelCompleted(String difficulty, int level) {
    final config = generateLevel(difficulty, level);
    return config.streaks.asMap().keys.every(
          (index) => isStreakCompleted(difficulty, level, index + 1),
        );
  }

  bool isStreakUnlocked(String difficulty, int level, int streak) {
    if (!isLevelUnlocked(difficulty, level)) {
      return false;
    }

    if (streak == 1) {
      return true;
    }

    return isStreakCompleted(difficulty, level, streak - 1);
  }

  bool isStreakCompleted(String difficulty, int level, int streak) {
    return completedStreaks.contains(streakKey(difficulty, level, streak));
  }

  Future<void> completeStreak(String difficulty, int level, int streak) async {
    final key = streakKey(difficulty, level, streak);
    if (!completedStreaks.contains(key)) {
      completedStreaks.add(key);
    }

    _recalculateUnlockedLevels();

    await _save();
  }

  Future<void> resetLevelStreaks(String difficulty, int level) async {
    final prefix = '${difficulty}_${level}_';
    completedStreaks.removeWhere((key) => key.startsWith(prefix));
    await _save();
  }

  String streakKey(String difficulty, int level, int streak) {
    return '${difficulty}_${level}_$streak';
  }

  Future<void> resetProgress() async {
    completedStreaks.clear();
    unlockedLevels.value = {
      'easy': 1,
      'medium': 1,
      'hard': 1,
      'extreme': 1,
    };
    await _save();
  }

  Future<void> _save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_completedStreaksKey, completedStreaks.toList());
    await box.put(_unlockedLevelsKey, Map<String, int>.from(unlockedLevels));
  }

  void _recalculateUnlockedLevels() {
    for (final difficulty in const ['easy', 'medium', 'hard', 'extreme']) {
      var level = 1;
      while (level <= LevelConfigGenerator.maxLevel &&
          isLevelCompleted(difficulty, level)) {
        level++;
      }
      final savedUnlocked = unlockedLevels[difficulty] ?? 1;
      final nextUnlocked = level.clamp(1, LevelConfigGenerator.maxLevel);
      if (nextUnlocked > savedUnlocked) {
        unlockedLevels[difficulty] = nextUnlocked;
      }
    }
  }
}
