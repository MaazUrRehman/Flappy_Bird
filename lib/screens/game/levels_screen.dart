import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/level_controller.dart';
import '../../widgets/sound_tap.dart';
import 'streak_screen.dart';

/// LevelsScreen - Shows 20 levels for a selected difficulty
class LevelsScreen extends StatelessWidget {
  final String difficulty;

  const LevelsScreen({super.key, required this.difficulty});

  String get _difficultyTitle {
    switch (difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'extreme':
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  Color get _difficultyColor {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'hard':
        return Colors.orange;
      case 'extreme':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelController = LevelController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('$_difficultyTitle Levels'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            playClickSound();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
          ),
        ),
        child: Column(
          children: [
            // Difficulty header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _difficultyColor.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getDifficultyIcon(), color: _difficultyColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '$_difficultyTitle Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _difficultyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Levels grid
            Expanded(
              child: Obx(
                () {
                  final unlockedLevel =
                      levelController.unlockedLevels[difficulty] ?? 1;
                  final completed = levelController.completedStreaks.toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final config =
                          levelController.generateLevel(difficulty, level);
                      final isUnlocked = level <= unlockedLevel;
                      final isCompleted = config.streaks.asMap().keys.every(
                            (streakIndex) => completed.contains(
                              levelController.streakKey(
                                difficulty,
                                level,
                                streakIndex + 1,
                              ),
                            ),
                          );

                      return _LevelTile(
                        level: level,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        color: _difficultyColor,
                        onTap: isUnlocked
                            ? () => _navigateToStreak(context, level)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDifficultyIcon() {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_dissatisfied;
      case 'extreme':
        return Icons.whatshot;
      default:
        return Icons.help;
    }
  }

  void _navigateToStreak(BuildContext context, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreakScreen(
          difficulty: difficulty,
          level: level,
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCompleted;
  final Color color;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      enabled: isUnlocked,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? color : Colors.grey,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Level number
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check_circle,
                        color: Colors.greenAccent, size: 30)
                  else
                    Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            // Locked overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white54, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
