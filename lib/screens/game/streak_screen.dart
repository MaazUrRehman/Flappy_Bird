import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/game_state_controller.dart';
import '../../controllers/level_controller.dart';
import '../../game/flappy_bird_game.dart';
import '../../models/level_config.dart';
import '../../widgets/sound_tap.dart';
import '../game_over_screen.dart';
import 'package:flame/game.dart';

/// StreakScreen - Shows streaks for a specific level
class StreakScreen extends StatelessWidget {
  final String difficulty;
  final int level;

  const StreakScreen({
    super.key,
    required this.difficulty,
    required this.level,
  });

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
    final gameState = GameStateController.instance;
    final levelController = LevelController.instance;
    final levelConfig = levelController.generateLevel(difficulty, level);
    final streakCount = levelConfig.streaks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level - Streaks'),
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
            // Level header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _difficultyColor.withOpacity(0.2),
              child: Column(
                children: [
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _difficultyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_difficultyTitle Mode • $streakCount Streaks',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Streaks list
            Expanded(
              child: Obx(
                () {
                  // Read Rx values here so Obx tracks this widget correctly.
                  final completed = gameState.completedStreaks.toList();
                  final levelCompleted =
                      levelController.completedStreaks.toList();
                  final unlockedLevel =
                      levelController.unlockedLevels[difficulty] ?? 1;
                  final progress = Map<String, int>.from(gameState.levelProgress);

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: streakCount,
                    itemBuilder: (context, index) {
                      final streak = index + 1;
                      final taskConfig = levelConfig.streaks[index];
                      final streakKey = '${difficulty}_${level}_$streak';
                      final isUnlocked = level <= unlockedLevel;
                      final isCompleted = completed.contains(streakKey) ||
                          levelCompleted.contains(streakKey);
                      final bestScore = progress[streakKey] ?? 0;
                      final task = taskConfig.description;

                      return _StreakTile(
                        streak: streak,
                        task: task,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        bestScore: bestScore,
                        color: _difficultyColor,
                        onTap: isUnlocked && !isCompleted
                            ? () => _startGame(context, streak, taskConfig)
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

  void _startGame(BuildContext context, int streak, TaskConfig taskConfig) {
    // Create game with difficulty and level settings
    final game = FlappyBirdGame();

    // Get the task for this streak
    final task = taskConfig.description;

    // Set game mode for streak with task info
    game.setGameMode(
      difficulty: difficulty,
      level: level,
      streak: streak,
      taskDescription: task,
      taskType: taskConfig.gameType,
      taskTarget: taskConfig.target,
    );

    // Pause the engine before showing the preview overlay
    game.pauseEngine();

    // Register Streak Preview overlay (shown before game starts)
    game.overlays.addEntry(
      'StreakPreview',
      (context, gameRef) => _StreakPreviewOverlay(
        game: gameRef as FlappyBirdGame,
        task: task,
      ),
    );
    game.overlays.add('StreakPreview');

    // Register Streak Complete overlay (shown when task is completed)
    game.overlays.addEntry(
      'StreakComplete',
      (context, gameRef) => _StreakCompleteOverlay(
        game: gameRef as FlappyBirdGame,
        task: task,
        onComplete: () {
          GameStateController.instance.completeStreak(
            difficulty,
            level,
            streak,
            game.score,
          );
          Navigator.of(context).pop();
        },
      ),
    );

    // Register GameOver overlay
    game.overlays.addEntry(
      'GameOver',
      (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () {
          Navigator.of(context).pop();
        },
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GameWidget(
            game: game,
          ),
        ),
      ),
    );
  }
}

// ==================== STREAK PREVIEW OVERLAY ====================

class _StreakPreviewOverlay extends StatefulWidget {
  final FlappyBirdGame game;
  final String task;

  const _StreakPreviewOverlay({
    required this.game,
    required this.task,
  });

  @override
  State<_StreakPreviewOverlay> createState() => _StreakPreviewOverlayState();
}

class _StreakPreviewOverlayState extends State<_StreakPreviewOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 3 seconds and start game
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Remove the overlay
        widget.game.overlays.remove('StreakPreview');
        // ✅ Resume game engine after modal is dismissed
        widget.game.resumeEngine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flag,
              color: Colors.amber,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'STREAK TASK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Text(
                widget.task,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Starting in 3...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STREAK COMPLETE OVERLAY ====================

class _StreakCompleteOverlay extends StatefulWidget {
  final FlappyBirdGame game;
  final String task;
  final VoidCallback onComplete;

  const _StreakCompleteOverlay({
    required this.game,
    required this.task,
    required this.onComplete,
  });

  @override
  State<_StreakCompleteOverlay> createState() => _StreakCompleteOverlayState();
}

class _StreakCompleteOverlayState extends State<_StreakCompleteOverlay> {
  @override
  void initState() {
    super.initState();
    // ✅ FIX 2: Pause game engine when achievement success modal appears
    widget.game.pauseEngine();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Remove the overlay
        widget.game.overlays.remove('StreakComplete');
        // ✅ Resume game engine after modal is dismissed
        widget.game.resumeEngine();
        // Navigate back to streak screen
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'STREAK COMPLETE!',
              style: TextStyle(
                color: Colors.green,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Text(
                widget.task,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Great job!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  final int streak;
  final String task;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestScore;
  final Color color;
  final VoidCallback? onTap;

  const _StreakTile({
    required this.streak,
    required this.task,
    required this.isUnlocked,
    required this.isCompleted,
    required this.bestScore,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      enabled: isUnlocked && !isCompleted,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? color : Colors.grey.shade700,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Streak number
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUnlocked ? color : Colors.grey,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white)
                    : isUnlocked
                        ? Text(
                            '$streak',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 16),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak $streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.green
                          : isUnlocked
                              ? Colors.white
                              : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  if (isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  if (isUnlocked && bestScore > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Best Score: $bestScore',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Play icon
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.greenAccent)
            else if (isUnlocked)
              Icon(Icons.play_arrow, color: color),
          ],
        ),
      ),
    );
  }
}
