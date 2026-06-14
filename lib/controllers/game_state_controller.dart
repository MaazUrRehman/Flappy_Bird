// ignore_for_file: avoid_print, duplicate_ignore

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_controller.dart';
import '../services/audio_manager.dart';

/// GameStateController - Manages persistent game state including coins
/// Uses Hive for local storage
class GameStateController extends GetxController {
  // Singleton instance
  static GameStateController get instance => Get.find<GameStateController>();

  // Hive box names
  static const String _gameStateBox = 'gameState';
  static const String _settingsBox = 'settings';

  // Keys
  static const String _coinsKey = 'totalCoins';
  static const String _highScoreKey = 'highScore';
  static const String _totalDistanceKey = 'totalDistance';
  static const String _gamesPlayedKey = 'gamesPlayed';
  static const String _bestStreakKey = 'bestStreak';
  static const String _musicEnabledKey = 'musicEnabled';
  static const String _sfxEnabledKey = 'sfxEnabled';
  static const String _musicVolumeKey = 'musicVolume';
  static const String _sfxVolumeKey = 'sfxVolume';
  static const String _screenRotationEnabledKey = 'screenRotationEnabled';
  static const String _reducedMotionEnabledKey = 'reducedMotionEnabled';
  static const String _legacyMusicVolumeKey = 'settings_music_volume';
  static const String _legacySfxVolumeKey = 'settings_sfx_volume';
  static const String _legacyRotationKey = 'settings_rotation_enabled';
  static const String _legacyReducedMotionKey = 'settings_reduced_motion';
  static const String _selectedBirdKey = 'selectedBird';
  static const String _selectedEnvironmentKey = 'selectedEnvironment';
  static const String _unlockedBirdsKey = 'unlockedBirds';
  static const String _unlockedEnvironmentsKey = 'unlockedEnvironments';
  static const String _completedStreaksKey = 'completedStreaks';
  static const String _currentUnlockedStreakKey = 'currentUnlockedStreak';

  // Reactive state
  final RxInt totalCoins = 0.obs;
  final RxInt highScore = 0.obs;
  final RxInt totalDistance = 0.obs;
  final RxInt gamesPlayed = 0.obs;
  final RxInt bestStreak = 0.obs;
  final RxBool musicEnabled = true.obs;
  final RxBool sfxEnabled = true.obs;
  final RxDouble musicVolume = 0.7.obs;
  final RxDouble sfxVolume = 0.85.obs;
  final RxBool screenRotationEnabled = true.obs;
  final RxBool reducedMotionEnabled = false.obs;
  final RxString selectedBird = 'default'.obs;
  final RxString selectedEnvironment = 'default'.obs;
  final RxList<String> unlockedBirds = <String>['default'].obs;
  final RxList<String> unlockedEnvironments = <String>['default'].obs;
  final RxList<String> completedStreaks = <String>[].obs;
  final RxString currentUnlockedStreak = 'easy_1_1'.obs;

  // Level progress storage
  // Format: "difficulty_level_streak" -> bestScore
  final RxMap<String, int> levelProgress = <String, int>{}.obs;
  Future<void>? _initializationFuture;

  @override
  void onInit() {
    super.onInit();
    initializeStorage();
  }

  Future<void> initializeStorage() async {
    if (_initializationFuture != null) {
      return _initializationFuture;
    }

    _initializationFuture = _initializeStorage();
    return _initializationFuture;
  }

  Future<void> _initializeStorage() async {
    try {
      await Hive.initFlutter();
      final prefs = await SharedPreferences.getInstance();

      // Open boxes
      final gameStateBox = await Hive.openBox(_gameStateBox);
      final settingsBox = await Hive.openBox(_settingsBox);

      // Load saved values
      totalCoins.value = gameStateBox.get(_coinsKey, defaultValue: 0) as int;
      highScore.value = gameStateBox.get(_highScoreKey, defaultValue: 0) as int;
      totalDistance.value =
          gameStateBox.get(_totalDistanceKey, defaultValue: 0) as int;
      gamesPlayed.value =
          gameStateBox.get(_gamesPlayedKey, defaultValue: 0) as int;
      bestStreak.value =
          gameStateBox.get(_bestStreakKey, defaultValue: 0) as int;

      // Load settings from SharedPreferences, with old Hive/settings-screen
      // keys as fallbacks for existing installs.
      musicEnabled.value = prefs.getBool(_musicEnabledKey) ??
          (settingsBox.get(_musicEnabledKey, defaultValue: true) as bool);
      sfxEnabled.value = prefs.getBool(_sfxEnabledKey) ??
          (settingsBox.get(_sfxEnabledKey, defaultValue: true) as bool);
      musicVolume.value = prefs.getDouble(_musicVolumeKey) ??
          prefs.getDouble(_legacyMusicVolumeKey) ??
          0.7;
      sfxVolume.value = prefs.getDouble(_sfxVolumeKey) ??
          prefs.getDouble(_legacySfxVolumeKey) ??
          0.85;
      screenRotationEnabled.value = prefs.getBool(_screenRotationEnabledKey) ??
          prefs.getBool(_legacyRotationKey) ??
          true;
      reducedMotionEnabled.value = prefs.getBool(_reducedMotionEnabledKey) ??
          prefs.getBool(_legacyReducedMotionKey) ??
          false;
      selectedBird.value =
          settingsBox.get(_selectedBirdKey, defaultValue: 'default') as String;
      selectedEnvironment.value = settingsBox.get(_selectedEnvironmentKey,
          defaultValue: 'default') as String;

      // Load unlocked items
      final birds = gameStateBox.get(_unlockedBirdsKey);
      if (birds != null) {
        unlockedBirds.value = List<String>.from(birds);
      }
      final envs = gameStateBox.get(_unlockedEnvironmentsKey);
      if (envs != null) {
        unlockedEnvironments.value = List<String>.from(envs);
      }

      final completed = gameStateBox.get(_completedStreaksKey);
      if (completed != null) {
        completedStreaks.value = List<String>.from(completed);
      }
      currentUnlockedStreak.value = gameStateBox.get(
        _currentUnlockedStreakKey,
        defaultValue: 'easy_1_1',
      ) as String;

      // Load level progress
      final progress = gameStateBox.get('levelProgress');
      if (progress != null) {
        levelProgress.value = Map<String, int>.from(progress);
      }

      await _ensureFreeShopItems();
      await applyAllSettings();
    } catch (e) {
      // ignore: avoid_print
      print('GameStateController: Error initializing storage: $e');
    }
  }

  // ================= COIN MANAGEMENT =================

  /// Add coins to total
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    totalCoins.value += amount;
    await _saveCoins();
  }

  /// Spend coins (returns true if successful)
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (totalCoins.value < amount) return false;

    totalCoins.value -= amount;
    await _saveCoins();
    return true;
  }

  /// Add collected coins from a game session
  Future<void> addGameCoins(int coins) async {
    await addCoins(coins);
  }

  Future<void> _saveCoins() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_coinsKey, totalCoins.value);
      // ignore: duplicate_ignore
    } catch (e) {
      // ignore: avoid_print
      print('GameStateController: Error saving coins: $e');
    }
  }

  // ================= SCORE MANAGEMENT =================

  /// Update high score if current score is higher
  Future<void> updateHighScore(int score) async {
    if (score > highScore.value) {
      highScore.value = score;
      await _saveHighScore();
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_highScoreKey, highScore.value);
    } catch (e) {
      // ignore: avoid_print
      print('GameStateController: Error saving high score: $e');
    }
  }

  // ================= DISTANCE MANAGEMENT =================

  /// Add distance traveled
  Future<void> addDistance(int distance) async {
    totalDistance.value += distance;
    await _saveTotalDistance();
  }

  Future<void> _saveTotalDistance() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_totalDistanceKey, totalDistance.value);
    } catch (e) {
      print('GameStateController: Error saving distance: $e');
    }
  }

  // ================= GAMES PLAYED =================

  /// Increment games played counter
  Future<void> incrementGamesPlayed() async {
    gamesPlayed.value++;
    await _saveGamesPlayed();
  }

  Future<void> _saveGamesPlayed() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_gamesPlayedKey, gamesPlayed.value);
      // ignore: empty_catches
    } catch (e) {}
  }

  // ================= STREAK MANAGEMENT =================

  /// Update best streak
  Future<void> updateBestStreak(int streak) async {
    if (streak > bestStreak.value) {
      bestStreak.value = streak;
      await _saveBestStreak();
    }
  }

  Future<void> _saveBestStreak() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_bestStreakKey, bestStreak.value);
    } catch (e) {
      print('GameStateController: Error saving best streak: $e');
    }
  }

  // ================= SETTINGS =================

  /// Toggle music
  Future<void> toggleMusic([bool? enabled]) async {
    musicEnabled.value = enabled ?? !musicEnabled.value;
    await applyMusicSettings();
    await _saveSettings();
  }

  /// Toggle SFX
  Future<void> toggleSfx([bool? enabled]) async {
    sfxEnabled.value = enabled ?? !sfxEnabled.value;
    await applySfxSettings();
    await _saveSettings();
  }

  Future<void> setMusicVolume(double volume) async {
    musicVolume.value = volume.clamp(0.0, 1.0);
    if (Get.isRegistered<AudioManager>()) {
      AudioManager.instance.setMusicVolume(musicVolume.value);
    }
    await _saveSettings();
  }

  Future<void> setSfxVolume(double volume) async {
    sfxVolume.value = volume.clamp(0.0, 1.0);
    if (Get.isRegistered<AudioManager>()) {
      AudioManager.instance.setSfxVolume(sfxVolume.value);
    }
    await _saveSettings();
  }

  Future<void> toggleScreenRotation([bool? enabled]) async {
    screenRotationEnabled.value = enabled ?? !screenRotationEnabled.value;
    await applyOrientationSettings();
    await _saveSettings();
  }

  Future<void> toggleReducedMotion([bool? enabled]) async {
    reducedMotionEnabled.value = enabled ?? !reducedMotionEnabled.value;
    applyReducedMotionSettings();
    await _saveSettings();
  }

  double get motionFactor => reducedMotionEnabled.value ? 0.55 : 1.0;
  double get animationFactor => reducedMotionEnabled.value ? 0.55 : 1.0;
  double get distanceFactor => reducedMotionEnabled.value ? 0.45 : 1.0;

  Future<void> applyAllSettings() async {
    await applyMusicSettings();
    await applySfxSettings();
    await applyOrientationSettings();
    applyReducedMotionSettings();
  }

  Future<void> applyMusicSettings() async {
    if (!Get.isRegistered<AudioManager>()) return;
    final audio = AudioManager.instance;
    await audio.setMusicEnabled(musicEnabled.value);
    if (musicEnabled.value) {
      audio.setMusicVolume(musicVolume.value);
      await audio.playBackgroundMusic();
    }
  }

  Future<void> applySfxSettings() async {
    if (!Get.isRegistered<AudioManager>()) return;
    final audio = AudioManager.instance;
    await audio.setSfxEnabled(sfxEnabled.value);
    if (sfxEnabled.value) {
      audio.setSfxVolume(sfxVolume.value);
    }
  }

  Future<void> applyOrientationSettings() {
    if (screenRotationEnabled.value) {
      return SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  void applyReducedMotionSettings() {
    update();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final box = await Hive.openBox(_settingsBox);
      await prefs.setBool(_musicEnabledKey, musicEnabled.value);
      await prefs.setBool(_sfxEnabledKey, sfxEnabled.value);
      await prefs.setDouble(_musicVolumeKey, musicVolume.value);
      await prefs.setDouble(_sfxVolumeKey, sfxVolume.value);
      await prefs.setBool(
          _screenRotationEnabledKey, screenRotationEnabled.value);
      await prefs.setBool(_reducedMotionEnabledKey, reducedMotionEnabled.value);
      await box.put(_musicEnabledKey, musicEnabled.value);
      await box.put(_sfxEnabledKey, sfxEnabled.value);
    } catch (e) {
      print('GameStateController: Error saving settings: $e');
    }
  }

  // ================= BIRD SELECTION =================

  /// Select a bird skin
  Future<void> selectBird(String birdId) async {
    if (!unlockedBirds.contains(birdId)) return;

    selectedBird.value = birdId;
    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put(_selectedBirdKey, birdId);
    } catch (e) {
      print('GameStateController: Error saving bird selection: $e');
    }
  }

  /// Unlock a bird
  Future<void> unlockBird(String birdId, {int cost = 0}) async {
    if (unlockedBirds.contains(birdId)) return;

    if (cost > 0) {
      final success = await spendCoins(cost);
      if (!success) return;
    }

    unlockedBirds.add(birdId);
    await _saveUnlockedBirds();
  }

  Future<void> _saveUnlockedBirds() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_unlockedBirdsKey, unlockedBirds.toList());
    } catch (e) {
      print('GameStateController: Error saving birds: $e');
    }
  }

  // ================= ENVIRONMENT SELECTION =================

  /// Select an environment
  Future<void> selectEnvironment(String envId) async {
    if (!unlockedEnvironments.contains(envId)) return;

    selectedEnvironment.value = envId;
    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put(_selectedEnvironmentKey, envId);
    } catch (e) {
      print('GameStateController: Error saving environment selection: $e');
    }
  }

  /// Unlock an environment
  Future<void> unlockEnvironment(String envId, {int cost = 0}) async {
    if (unlockedEnvironments.contains(envId)) return;

    if (cost > 0) {
      final success = await spendCoins(cost);
      if (!success) return;
    }

    unlockedEnvironments.add(envId);
    await _saveUnlockedEnvironments();
  }

  Future<void> _saveUnlockedEnvironments() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_unlockedEnvironmentsKey, unlockedEnvironments.toList());
    } catch (e) {
      print('GameStateController: Error saving environments: $e');
    }
  }

  // ================= LEVEL PROGRESS =================

  /// Get the best score for a specific level
  int getLevelBestScore(String difficulty, int level, int streak) {
    final key = _streakKey(difficulty, level, streak);
    return levelProgress[key] ?? 0;
  }

  Future<void> _ensureFreeShopItems() async {
    const freeBirds = [
      'default',
      'blue',
      'red',
      'green',
      'purple',
      'orange',
      'pink',
      'gold',
      'ember',
      'frost',
      'forest_bird',
      'cyber_bird',
      'shadow',
      'candy_bird',
      'royal',
      'ninja',
      'crystal',
      'samurai',
      'angel',
      'demon',
      'aqua',
      'desert_bird',
      'thunder',
      'ghost',
      'magma',
    ];
    const freeEnvironments = [
      'default',
      'forest',
      'sunset',
      'cyber',
      'arctic',
      'desert',
      'ocean',
      'graveyard',
      'candy',
      'jungle',
      'space',
      'volcano',
      'sakura',
      'steampunk',
      'heaven',
      'nightmare',
    ];

    var birdsChanged = false;
    for (final bird in freeBirds) {
      if (!unlockedBirds.contains(bird)) {
        unlockedBirds.add(bird);
        birdsChanged = true;
      }
    }

    var envsChanged = false;
    for (final env in freeEnvironments) {
      if (!unlockedEnvironments.contains(env)) {
        unlockedEnvironments.add(env);
        envsChanged = true;
      }
    }

    if (birdsChanged) await _saveUnlockedBirds();
    if (envsChanged) await _saveUnlockedEnvironments();
  }

  /// Update level progress if score is better
  Future<void> updateLevelProgress(
      String difficulty, int level, int streak, int score) async {
    final key = _streakKey(difficulty, level, streak);
    final currentBest = levelProgress[key] ?? 0;

    if (score > currentBest) {
      levelProgress[key] = score;
      await _saveLevelProgress();
    }
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(String difficulty, int level) {
    if (Get.isRegistered<LevelController>()) {
      return LevelController.instance.isLevelUnlocked(difficulty, level);
    }
    return level == 1;
  }

  /// Check if a streak is unlocked
  bool isStreakUnlocked(String difficulty, int level, int streak) {
    if (Get.isRegistered<LevelController>()) {
      return LevelController.instance.isStreakUnlocked(
        difficulty,
        level,
        streak,
      );
    }
    return isLevelUnlocked(difficulty, level);
  }

  bool isStreakCompleted(String difficulty, int level, int streak) {
    if (Get.isRegistered<LevelController>()) {
      return LevelController.instance.isStreakCompleted(
        difficulty,
        level,
        streak,
      );
    }
    return completedStreaks.contains(_streakKey(difficulty, level, streak));
  }

  Future<void> completeStreak(
    String difficulty,
    int level,
    int streak,
    int score,
  ) async {
    final key = _streakKey(difficulty, level, streak);
    if (!completedStreaks.contains(key)) {
      completedStreaks.add(key);
    }
    if (Get.isRegistered<LevelController>()) {
      await LevelController.instance.completeStreak(difficulty, level, streak);
    }
    currentUnlockedStreak.value = _streakKey(difficulty, level, streak + 1);
    await updateLevelProgress(difficulty, level, streak, score);
    await _saveStreakProgress();
  }

  Future<void> resetLevelStreakRun(String difficulty, int level) async {
    final prefix = '${difficulty}_${level}_';
    completedStreaks.removeWhere((key) => key.startsWith(prefix));
    currentUnlockedStreak.value = _streakKey(difficulty, level, 1);

    if (Get.isRegistered<LevelController>()) {
      await LevelController.instance.resetLevelStreaks(difficulty, level);
    }

    await _saveStreakProgress();
  }

  String _streakKey(String difficulty, int level, int streak) {
    return '${difficulty}_${level}_$streak';
  }

  Future<void> _saveStreakProgress() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      await box.put(_completedStreaksKey, completedStreaks.toList());
      await box.put(_currentUnlockedStreakKey, currentUnlockedStreak.value);
    } catch (e) {
      print('GameStateController: Error saving streak progress: $e');
    }
  }

  Future<void> _saveLevelProgress() async {
    try {
      final box = await Hive.openBox(_gameStateBox);
      // Convert RxMap to regular Map for Hive storage
      final Map<String, int> progressMap = {};
      levelProgress.forEach((key, value) {
        progressMap[key] = value;
      });
      await box.put('levelProgress', progressMap);
    } catch (e) {
      print('GameStateController: Error saving level progress: $e');
    }
  }

  // ================= RESET =================

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    totalCoins.value = 0;
    highScore.value = 0;
    totalDistance.value = 0;
    gamesPlayed.value = 0;
    bestStreak.value = 0;
    levelProgress.clear();
    completedStreaks.clear();
    currentUnlockedStreak.value = 'easy_1_1';
    if (Get.isRegistered<LevelController>()) {
      await LevelController.instance.resetProgress();
    }

    try {
      final gameBox = await Hive.openBox(_gameStateBox);
      await gameBox.clear();
    } catch (e) {
      print('GameStateController: Error resetting: $e');
    }
  }
}
