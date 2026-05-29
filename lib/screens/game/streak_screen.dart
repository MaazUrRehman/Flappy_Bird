import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/game_state_controller.dart';
import '../../controllers/level_controller.dart';
import '../../game/flappy_bird_game.dart';
import '../../models/level_config.dart';
import '../../widgets/sound_tap.dart';
import '../game_over_screen.dart';
import '../pause_screen.dart';

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
                title: 'Level $level',
                subtitle: '$_difficultyTitle Mode - $streakCount Streaks',
                color: _difficultyColor,
                onBack: () {
                  playClickSound();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Obx(
                  () {
                    final completed = gameState.completedStreaks.toList();
                    final levelCompleted =
                        levelController.completedStreaks.toList();
                    final progress =
                        Map<String, int>.from(gameState.levelProgress);

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: streakCount,
                      itemBuilder: (context, index) {
                        final streak = index + 1;
                        final taskConfig = levelConfig.streaks[index];
                        final streakKey = '${difficulty}_${level}_$streak';
                        final isUnlocked = levelController.isStreakUnlocked(
                          difficulty,
                          level,
                          streak,
                        );
                        final isCompleted = completed.contains(streakKey) ||
                            levelCompleted.contains(streakKey);
                        final bestScore = progress[streakKey] ?? 0;

                        return _StreakTile(
                          streak: streak,
                          task: taskConfig.description,
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
      ),
    );
  }

  void _startGame(BuildContext context, int streak, TaskConfig taskConfig) {
    final game = FlappyBirdGame();
    final task = taskConfig.description;

    game.setGameMode(
      difficulty: difficulty,
      level: level,
      streak: streak,
      taskDescription: task,
      taskType: taskConfig.gameType,
      taskTarget: taskConfig.target,
    );

    game.prepareStartCountdown();

    game.overlays.addEntry(
      'StreakPreview',
      (context, gameRef) => _StreakPreviewOverlay(
        game: gameRef as FlappyBirdGame,
        task: task,
      ),
    );
    game.overlays.add('StreakPreview');

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

    game.overlays.addEntry(
      'GameOver',
      (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () => Navigator.of(context).pop(),
      ),
    );

    game.overlays.addEntry(
      'PauseButton',
      (context, gameRef) => PauseButtonOverlay(game: gameRef as FlappyBirdGame),
    );
    game.overlays.addEntry(
      'PauseMenu',
      (context, gameRef) => PauseMenuOverlay(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () => Navigator.of(context).pop(),
      ),
    );
    game.overlays.add('PauseButton');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GameWidget(game: game),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
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
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
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
  int _countdownValue = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    widget.game.prepareStartCountdown();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
        return;
      }

      timer.cancel();
      _finishCountdown();
    });
  }

  void _finishCountdown() {
    widget.game.completeStartCountdown();
    if (mounted) {
      widget.game.overlays.remove('StreakPreview');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _countdownValue == 1 ? 'Get Ready' : '$_countdownValue';
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag, color: Colors.amber, size: 64),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              Text(
                displayText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap will activate after countdown',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    widget.game.pauseEngine();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.game.overlays.remove('StreakComplete');
        widget.game.resumeEngine();
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
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
