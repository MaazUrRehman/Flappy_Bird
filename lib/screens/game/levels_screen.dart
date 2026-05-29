import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/level_controller.dart';
import '../../models/level_config.dart';
import '../../widgets/sound_tap.dart';
import 'streak_screen.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _ScreenHeader(
                title: '$_difficultyTitle Mode',
                subtitle: 'Choose a level',
                icon: _getDifficultyIcon(),
                color: _difficultyColor,
                onBack: () {
                  playClickSound();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Obx(
                  () {
                    final unlockedLevel =
                        levelController.unlockedLevels[difficulty] ?? 1;
                    final completed = levelController.completedStreaks.toList();

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: LevelConfigGenerator.maxLevel,
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

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.28))),
      ),
      child: Row(
        children: [
          SoundTap(
            onTap: onBack,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            ),
          ),
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
            Center(
              child: isCompleted
                  ? const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 30)
                  : Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.grey,
                      ),
                    ),
            ),
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
