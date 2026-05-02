import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/streak_data.dart';

class StreakController extends GetxController {
  static const String _completedStreaksKey = 'completed_streaks';
  static const String _currentStreakKey = 'current_streak';

  final RxList<int> completedStreaks = <int>[].obs;
  final RxInt currentStreakId = 0.obs;

  // Current game streak tracking
  final Rx<Streak?> activeStreak = Rx<Streak?>(null);
  final RxInt currentProgress = 0.obs;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgress();
  }

  void _loadProgress() {
    final completedList = _prefs.getStringList(_completedStreaksKey) ?? [];
    completedStreaks.value = completedList.map((e) => int.parse(e)).toList();
    currentStreakId.value = _prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Get streaks for a specific difficulty and level
  List<Streak> getStreaks(String difficulty, int level) {
    return StreakData.getStreaksForLevel(difficulty, level);
  }

  /// Check if a streak is unlocked
  bool isStreakUnlocked(int streakId) {
    if (streakId == 1) return true;
    return completedStreaks.contains(streakId - 1);
  }

  /// Check if a streak is completed
  bool isStreakCompleted(int streakId) {
    return completedStreaks.contains(streakId);
  }

  /// Start a new streak in the game
  void startStreak(Streak streak) {
    activeStreak.value = streak;
    currentProgress.value = 0;
  }

  /// Update progress during gameplay
  void updateProgress(int value) {
    if (activeStreak.value != null) {
      currentProgress.value = value;

      // Check if target reached
      if (currentProgress.value >= activeStreak.value!.target) {
        completeStreak();
      }
    }
  }

  /// Complete the current streak
  void completeStreak() {
    if (activeStreak.value != null) {
      final streakId = activeStreak.value!.id;
      if (!completedStreaks.contains(streakId)) {
        completedStreaks.add(streakId);
        // Unlock next streak automatically
        _unlockNextStreak(streakId);
        _saveProgress();
      }
      activeStreak.value = null;
    }
  }

  /// Unlock the next streak after completing current one
  void _unlockNextStreak(int completedStreakId) {
    final nextStreakId = completedStreakId + 1;
    // The unlock logic is handled in isStreakUnlocked method
    // No need to store unlocked streaks separately, we derive from completed
  }

  /// Get progress percentage
  double getProgressPercentage() {
    if (activeStreak.value == null) return 0;
    return (currentProgress.value / activeStreak.value!.target).clamp(0.0, 1.0);
  }

  /// Reset streak progress (for testing)
  void resetProgress() {
    completedStreaks.clear();
    currentStreakId.value = 0;
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    await _prefs.setStringList(
      _completedStreaksKey,
      completedStreaks.map((e) => e.toString()).toList(),
    );
    await _prefs.setInt(_currentStreakKey, currentStreakId.value);
  }
}
