import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/background.dart';
import '../components/coin.dart';
import '../components/ground.dart';
import '../components/bird.dart';
import '../components/pipe.dart';
import '../systems/spawn_manager.dart';
import '../systems/score_manager.dart';
import '../screens/hud.dart';
import '../controllers/game_state_controller.dart';
import '../controllers/streak_controller.dart';
import '../models/difficulty_config.dart';
import '../services/audio_manager.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late ScoreManager scoreManager;
  late SpawnManager spawnManager;

  // UI Components
  late HUD _hud;
  // late PauseMenu _pauseMenu;

  bool isGameOver = false;
  bool isPaused = false;

  // Countdown / start sequence
  bool _isGameReady = false;
  bool _isCountdownActive = false;
  bool _isUserControlEnabled = true;
  bool _countdownPending = false;

  int _collectedCoins = 0;

  // Direct distance tracking
  double _distance = 0;

  // ==================== GAME MODE (Difficulty/Level/Streak) ====================
  String _difficulty = 'easy';
  int _level = 1;
  int _streak = 1;
  bool _isStreakMode = false;
  DifficultyConfig _difficultyConfig = DifficultyConfig.easy();

  // Streak task tracking
  String _currentTask = '';
  String _currentTaskType = 'score';
  String? _configuredTaskDescription;
  String? _configuredTaskType;
  int? _configuredTaskTarget;
  int _taskProgress = 0;
  int _taskTarget = 0;
  bool _taskCompleted = false;

  // Streak preview/completion overlay state
  bool _showStreakPreview = false;
  bool _showStreakComplete = false;
  String _streakPreviewText = '';
  String _streakCompleteText = '';

  // Getters for game mode
  String get difficulty => _difficulty;
  int get level => _level;
  int get streak => _streak;
  bool get isStreakMode => _isStreakMode;
  String get currentTask => _currentTask;
  int get taskProgress => _taskProgress;
  int get taskTarget => _taskTarget;
  bool get taskCompleted => _taskCompleted;

  /// Set game mode for streak-based gameplay
  void setGameMode({
    required String difficulty,
    required int level,
    required int streak,
    String? taskDescription,
    String? taskType,
    int? taskTarget,
  }) {
    _difficulty = difficulty;
    _level = level;
    _streak = streak;
    _isStreakMode = true;
    _difficultyConfig = DifficultyConfig.fromString(difficulty);

    // Set task description if provided
    if (taskDescription != null) {
      _currentTask = taskDescription;
      _configuredTaskDescription = taskDescription;
    }
    if (taskType != null) {
      _currentTaskType = taskType;
      _configuredTaskType = taskType;
    }
    _configuredTaskTarget = taskTarget;

    // Set difficulty parameters
    _applyDifficultySettings();

    // Set streak task
    _setStreakTask(streak);

    // Show streak preview overlay
    if (taskDescription != null) {
      _showStreakPreview = true;
      _streakPreviewText = taskDescription;
    }
  }

  bool get isCountdownActive => _isCountdownActive;
  bool get isUserControlEnabled => _isUserControlEnabled;

  /// Prepare the game for the pre-start countdown sequence.
  void prepareStartCountdown() {
    _isCountdownActive = true;
    _isUserControlEnabled = false;
    _countdownPending = true;
    if (_isGameReady) {
      bird.gravity = 0;
      bird.velocity = 0;
    }
  }

  /// Complete the countdown and enable normal gameplay.
  void completeStartCountdown() {
    if (!_isCountdownActive) return;
    _isCountdownActive = false;
    _isUserControlEnabled = true;
    _countdownPending = false;
    _applyDifficultySettings();
  }

  /// Apply difficulty-specific settings
  void _applyDifficultySettings() {
    // Check if bird is initialized before applying settings
    if (!_isGameReady) return;

    switch (_difficulty) {
      case 'easy':
        bird.gravity = 800;
        bird.jumpForce = -300;
        break;
      case 'medium':
        bird.gravity = 900;
        bird.jumpForce = -320;
        break;
      case 'hard':
        bird.gravity = 1000;
        bird.jumpForce = -340;
        break;
      case 'extreme':
        bird.gravity = 1100;
        bird.jumpForce = -360;
        break;
    }
  }

  /// Set the task for current streak
  void _setStreakTask(int streak) {
    final tasks = [
      {
        'task': 'Collect ${_difficultyConfig.coinTarget} coins',
        'target': _difficultyConfig.coinTarget,
        'type': 'coins',
      },
      {
        'task': 'Reach score ${_difficultyConfig.targetScore}',
        'target': _difficultyConfig.targetScore,
        'type': 'score',
      },
      {
        'task': 'Travel ${_difficultyConfig.distanceTarget}m distance',
        'target': _difficultyConfig.distanceTarget,
        'type': 'distance',
      },
      {
        'task': 'Pass ${(_difficultyConfig.targetScore / 5).ceil()} pipes',
        'target': (_difficultyConfig.targetScore / 5).ceil(),
        'type': 'pipes',
      },
      {
        'task': 'Survive ${_difficultyConfig.survivalTime} seconds',
        'target': _difficultyConfig.survivalTime,
        'type': 'time',
      },
      {
        'task': 'Collect ${_difficultyConfig.coinTarget + 3} coins',
        'target': _difficultyConfig.coinTarget + 3,
        'type': 'coins',
      },
      {
        'task': 'Reach score ${_difficultyConfig.targetScore + 10}',
        'target': _difficultyConfig.targetScore + 10,
        'type': 'score',
      },
    ];

    final taskIndex = (streak - 1) % tasks.length;
    final taskData = tasks[taskIndex];

    _currentTask = _configuredTaskDescription ?? (taskData['task'] as String);
    _currentTaskType = _configuredTaskType ?? (taskData['type'] as String);
    _taskTarget = _configuredTaskTarget ?? (taskData['target'] as int);
    _taskProgress = 0;
    _taskCompleted = false;
  }

// Track pipes passed for streak tasks
  int _pipesPassed = 0;

  /// Update task progress based on game events
  void updateTaskProgress(String type, int amount) {
    if (!_isStreakMode || _taskCompleted) return;
    if (type != _currentTaskType) return;

    if (type == 'coins') {
      _taskProgress = _collectedCoins;
    } else if (type == 'score') {
      _taskProgress = scoreManager.score;
    } else if (type == 'distance') {
      _taskProgress = _distance.toInt();
    } else if (type == 'pipes') {
      _taskProgress = _pipesPassed;
    } else if (type == 'time') {
      _taskProgress = (_distance / 100).toInt(); // Approximate time
    }

    if (_taskProgress >= _taskTarget && !_taskCompleted) {
      _taskCompleted = true;
      _persistStreakCompletion();
      _showStreakCompleteOverlay();
      try {
        AudioManager.instance.playStreakCompleteSound();
      } catch (e) {
        // AudioManager may not be initialized yet.
      }
    }
  }

  Future<void> _persistStreakCompletion() async {
    try {
      await GameStateController.instance.completeStreak(
        _difficulty,
        _level,
        _streak,
        scoreManager.score,
      );
      Get.find<StreakController>().completeStreak();
    } catch (e) {
      // Controllers may not be available in tests.
    }
  }

  /// Show the streak complete overlay
  void _showStreakCompleteOverlay() {
    _streakCompleteText = _currentTask;
    _showStreakComplete = true;
    overlays.add('StreakComplete');
  }

  /// Show the streak preview overlay
  void showStreakPreviewOverlay() {
    if (_currentTask.isNotEmpty) {
      _streakPreviewText = _currentTask;
      _showStreakPreview = true;
      overlays.add('StreakPreview');
    }
  }

  /// Increment pipes passed count
  void incrementPipesPassed() {
    _pipesPassed++;
    updateTaskProgress('pipes', _pipesPassed);
  }

  /// Check if streak is completed
  bool isStreakCompleted() {
    return _taskCompleted;
  }

  /// Reset game mode
  void resetGameMode() {
    _difficulty = 'easy';
    _level = 1;
    _streak = 1;
    _isStreakMode = false;
    _currentTask = '';
    _currentTaskType = 'score';
    _configuredTaskDescription = null;
    _configuredTaskType = null;
    _configuredTaskTarget = null;
    _taskProgress = 0;
    _taskTarget = 0;
    _taskCompleted = false;
  }

  // Visual effects
  double _screenShakeIntensity = 0;
  double _hitStopTimer = 0;
  bool _isTransitioning = false;

  // Game statistics
  int _bestScore = 0;
  int _bestDistance = 0;
  int _totalCoinsCollected = 0;

  // Color scheme for UI
  final ColorScheme _colorScheme = const ColorScheme(
    primary: Color(0xFFFFD700),
    secondary: Color(0xFFFF6B6B),
    surface: Color(0xFF1A1A2E),
    background: Color(0xFF0F3460),
    error: Color(0xFFE94560),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
    primaryContainer: Color(0xFFFFE066),
    secondaryContainer: Color(0xFFFF8E8E),
  );

  // Getters for UI
  int get score => scoreManager.score;
  int get collectedCoins => _collectedCoins;
  double get distance => _distance;
  int getBestScore() => _bestScore;
  int getBestDistance() => _bestDistance;
  int getTotalCoins() => _totalCoinsCollected;
  bool get isGameOverState => isGameOver;
  bool get isPausedState => isPaused;
  ColorScheme get colorScheme => _colorScheme;
  ScoreManager? get scoreManagerInstance => scoreManager;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadBestScores();
    try {
      AudioManager.instance.playBackgroundMusic();
    } catch (e) {
      // AudioManager may not be initialized yet.
    }

    camera.viewport = MaxViewport();

    // Add background first
    add(Background());
    add(Ground());

    // Create bird
    bird = Bird();
    add(bird);

    scoreManager = ScoreManager();
    add(scoreManager);

    spawnManager = SpawnManager();
    add(spawnManager);
    spawnManager.configure(_difficultyConfig);

    // Add UI Components
    _hud = HUD();
    add(_hud);

    // _pauseMenu = PauseMenu();
    // add(_pauseMenu);

    await Future.delayed(const Duration(milliseconds: 500));

    // ✅ Mark game as ready after everything is initialized
    _isGameReady = true;

    // ✅ Apply difficulty settings if in streak mode
    if (_isStreakMode) {
      updateTaskProgress(_currentTaskType, 0);
      _applyDifficultySettings();
    }

    if (_isCountdownActive && _countdownPending) {
      bird.gravity = 0;
      bird.velocity = 0;
      _countdownPending = false;
    }
  }

  Future<void> _loadBestScores() async {
    _bestScore = 0;
    _bestDistance = 0;
    _totalCoinsCollected = 0;
  }

  Future<void> _saveBestScores() async {
    // Save to SharedPreferences in production
  }

  @override
  void onTap() {
    // ✅ Check if game is ready before handling tap
    if (!_isGameReady || _isCountdownActive) return;
    _handleGameTap();
  }

  Future<void> _handleGameTap() async {
    if (_isTransitioning) return;

    if (isGameOver) {
      await reset();
      return;
    }

    if (isPaused) {
      return;
    }

    // ✅ Check if bird is initialized before accessing
    if (bird.isAlive) {
      bird.jump();
      try {
        AudioManager.instance.playJumpSound();
      } catch (e) {
        // AudioManager may not be initialized yet.
      }
      _addScreenShake(2);
    }
  }

  // ==================== COIN SPAWNING SYSTEM ====================

  /// Get safe Y range from existing pipes (the gap between top and bottom pipe)
  (double min, double max)? _getSafeYRangeFromPipes(List<Pipe> pipes) {
    double? topPipeBottom;
    double? bottomPipeTop;

    for (final pipe in pipes) {
      if (pipe.pipeType == PipeType.top) {
        topPipeBottom = pipe.position.y + pipe.size.y;
      } else if (pipe.pipeType == PipeType.bottom) {
        bottomPipeTop = pipe.position.y;
      }
    }

    if (topPipeBottom != null && bottomPipeTop != null) {
      return (
        topPipeBottom + 20,
        bottomPipeTop - 20,
      );
    }
    return null;
  }

  /// Spawns random coins ONLY in safe pipe gaps
  void spawnRandomCoins() {
    final random = Random();

    int coinCount;
    if (score > 50) {
      coinCount = 3 + random.nextInt(4);
    } else if (score > 20) {
      coinCount = 2 + random.nextInt(3);
    } else {
      coinCount = 1 + random.nextInt(3);
    }

    final currentPipes = _getCurrentPipes();
    final safeYRange = _getSafeYRangeFromPipes(currentPipes);

    if (safeYRange == null) {
      return;
    }

    int coinsSpawned = 0;
    double pipeX = size.x + 50;

    for (int i = 0; i < coinCount; i++) {
      double coinY =
          safeYRange.$1 + random.nextDouble() * (safeYRange.$2 - safeYRange.$1);
      double coinX = pipeX + (i * 35);

      if (coinY < 60 || coinY > size.y - 90) {
        continue;
      }

      Coin coin = Coin(
        position: Vector2(coinX, coinY),
        coinType: CoinType.gold,
        coinValue: 1,
        radius: 7,
      );

      add(coin);
      coinsSpawned++;
    }

    if (coinsSpawned > 0) {
      print("💰 Spawned $coinsSpawned coins");
    }
  }

  /// Spawn curved pattern coins for special waves
  void spawnCurvedCoins() {
    final currentPipes = _getCurrentPipes();
    final safeYRange = _getSafeYRangeFromPipes(currentPipes);

    if (safeYRange == null) {
      return;
    }

    int coinCount = 5;
    double startX = size.x + 50;
    double centerY = (safeYRange.$1 + safeYRange.$2) / 2;
    double availableHeight = safeYRange.$2 - safeYRange.$1;

    for (int i = 0; i < coinCount; i++) {
      double progress = i / (coinCount - 1);
      double x = startX + progress * 180;
      double y = centerY + sin(progress * pi * 2) * (availableHeight * 0.3);
      y = y.clamp(safeYRange.$1 + 5, safeYRange.$2 - 5);

      Coin coin = Coin(
        position: Vector2(x, y),
        coinType: CoinType.gold,
        coinValue: 2,
        radius: 8,
      );

      add(coin);
    }

    print("✨ Special wave!");
  }

  /// Get all current pipes in the game
  List<Pipe> _getCurrentPipes() {
    final pipes = <Pipe>[];
    for (final child in children) {
      if (child is Pipe) {
        pipes.add(child);
      }
    }
    return pipes;
  }

  void pauseGame() {
    if (isGameOver || isPaused) return;
    isPaused = true;
    pauseEngine();
  }

  void resumeGame() {
    if (isGameOver || !isPaused) return;
    isPaused = false;
    resumeEngine();
  }

  void togglePause() {
    if (isGameOver) return;
    if (isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void _addScreenShake(double intensity) {
    _screenShakeIntensity = intensity;
  }

  void _applyScreenShake(double dt) {
    if (_screenShakeIntensity > 0) {
      final shakeX = (DateTime.now().millisecondsSinceEpoch % 100) /
          100 *
          _screenShakeIntensity;
      final shakeY = (DateTime.now().millisecondsSinceEpoch % 67) /
          100 *
          _screenShakeIntensity;
      _shakeCamera(Vector2(shakeX - _screenShakeIntensity / 2,
          shakeY - _screenShakeIntensity / 2));
      _screenShakeIntensity *= 0.9;

      if (_screenShakeIntensity < 0.1) {
        _screenShakeIntensity = 0;
        _shakeCamera(Vector2.zero());
      }
    }
  }

  void _shakeCamera(Vector2 offset) {
    camera.viewfinder.position += offset;
  }

  void _applyHitStop(double dt) {
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
    }
  }

  void gameOver() {
    if (isGameOver || _isTransitioning) return;

    isGameOver = true;
    _isTransitioning = true;
    bird.isAlive = false;

    final finalScore = scoreManager.score;
    final finalDistance = _distance.toInt();

    if (finalScore > _bestScore) {
      _bestScore = finalScore;
    }
    if (finalDistance > _bestDistance) {
      _bestDistance = finalDistance;
    }

    _saveBestScores();
    _addScreenShake(15);
    _hitStopTimer = 0.3;

    // Play game over sound
    try {
      AudioManager.instance.pauseBackgroundMusic();
      AudioManager.instance.playGameOverSound();
    } catch (e) {
      // AudioManager may not be initialized yet
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      pauseEngine();
      // ✅ Directly add overlay
      if (!overlays.isActive('GameOver')) {
        overlays.add('GameOver');
      }
      _isTransitioning = false;
    });

    print(
        "💀 Game Over! Score: $finalScore | Distance: ${finalDistance}m | Coins: $_collectedCoins");
  }

  void addCoin(int value) {
    if (!isGameOver && !isPaused) {
      _collectedCoins += value;
      _totalCoinsCollected += value;

      _hud.notifyCoinCollected();
      scoreManager.increaseScore(points: value);
      _hud.notifyScoreIncrease(value);

      // ✅ Add to global coin total via shared GameStateController
      GameStateController.instance.addGameCoins(value);

      // Play coin collect sound
      try {
        AudioManager.instance.playCoinCollectSound();
      } catch (e) {
        // AudioManager may not be initialized
      }

      // Update task progress for streak mode
      updateTaskProgress('coins', _collectedCoins);
      updateTaskProgress('score', scoreManager.score);

      print("💰 Coin! +$value | Total: $_collectedCoins");
    }
  }

  void addScore(int points) {
    if (!isGameOver && !isPaused) {
      scoreManager.increaseScore(points: points);
      _hud.notifyScoreIncrease(points);
      updateTaskProgress('score', scoreManager.score);
    }
  }

  void addPipeScore() {
    if (!isGameOver && !isPaused) {
      scoreManager.increaseScore(points: 5);
      _hud.notifyScoreIncrease(5);
      updateTaskProgress('score', scoreManager.score);
    }
  }

  void addDistance() {
    if (!isGameOver && !isPaused) {
      _hud.notifyDistanceIncrease();
    }
  }

  void reviveBird() {
    if (isGameOver) {
      print("🕊️ Reviving bird...");

      // Reset game state flags
      isGameOver = false;
      _isTransitioning = false;
      _isGameReady = true; // ✅ Reset game ready flag

      // ✅ Call bird's revive method
      bird.revive(); // Use the new revive method

      // Resume the engine
      resumeEngine();

      print("✅ Game resumed!");
    }
  }

  Future<void> reset() async {
    if (_isTransitioning) return;

    _isTransitioning = true;
    isGameOver = false;
    isPaused = false;
    _collectedCoins = 0;
    _distance = 0;

    // ✅ Temporarily disable game ready flag during reset
    _isGameReady = false;

    // Remove overlay if showing
    if (overlays.isActive('GameOver')) {
      overlays.remove('GameOver');
    }
    // _pauseMenu.hide();

    // Remove all game components except background, ground, and UI
    final componentsToRemove = <Component>[];

    for (final component in children) {
      if (component is Background || component is Ground || component is HUD) {
        continue;
      }
      componentsToRemove.add(component);
    }

    for (final component in componentsToRemove) {
      remove(component);
    }

    // Recreate game components
    bird = Bird();
    bird.isAlive = true;
    add(bird);

    scoreManager = ScoreManager();
    add(scoreManager);

    spawnManager = SpawnManager();
    add(spawnManager);
    spawnManager.configure(_difficultyConfig);

    _shakeCamera(Vector2.zero());
    _screenShakeIntensity = 0;

    resumeEngine();
    try {
      AudioManager.instance.resumeBackgroundMusic();
    } catch (e) {
      // AudioManager may not be initialized yet.
    }

    // ✅ Small delay to ensure all components are ready
    await Future.delayed(const Duration(milliseconds: 100));
    _isGameReady = true;
    _isTransitioning = false;

    print("🔄 Game Reset!");
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ✅ Only update normal gameplay while ready and not paused/over
    if (_isGameReady &&
        !isGameOver &&
        !isPaused &&
        !_isCountdownActive &&
        bird.isAlive) {
      _distance += 100 * dt;
      _applyHitStop(dt);
      updateTaskProgress('distance', _distance.toInt());
      updateTaskProgress('time', (_distance / 100).toInt());
    }

    _applyScreenShake(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}
