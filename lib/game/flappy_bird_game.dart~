import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/background.dart';
import '../components/coin.dart';
import '../components/ground.dart';
import '../components/bird.dart';
import '../components/pipe.dart';
import '../screens/pause_screen.dart';
import '../systems/spawn_manager.dart';
import '../systems/score_manager.dart';
import '../screens/hud.dart';
import '../screens/game_over_screen.dart';

class FlappyBirdGame extends FlameGame
    with TapDetector, HasCollisionDetection {

  late Bird bird;
  late ScoreManager scoreManager;
  late SpawnManager spawnManager;

  // UI Components
  late HUD _hud;
  // late PauseMenu _pauseMenu;

  bool isGameOver = false;
  bool isPaused = false;

  int _collectedCoins = 0;

  // Direct distance tracking
  double _distance = 0;

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

    // Add UI Components
    _hud = HUD();
    add(_hud);

    // _pauseMenu = PauseMenu();
    // add(_pauseMenu);

    await Future.delayed(const Duration(milliseconds: 500));
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
    _handleGameTap();
  }

  Future<void> _handleGameTap() async {
    if (_isTransitioning) return;

    if (isGameOver) {
      await reset();
      return;
    }

    if (isPaused) {
      togglePause();
      return;
    }

    if (bird.isAlive) {
      bird.jump();
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
      double coinY = safeYRange.$1 + random.nextDouble() * (safeYRange.$2 - safeYRange.$1);
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

  void togglePause() {
    if (isGameOver) return;

    isPaused = !isPaused;

    // if (isPaused) {
    //   pauseEngine();
    //   _pauseMenu.show();
    // } else {
    //   resumeEngine();
    //   _pauseMenu.hide();
    // }
  }

  void _addScreenShake(double intensity) {
    _screenShakeIntensity = intensity;
  }

  void _applyScreenShake(double dt) {
    if (_screenShakeIntensity > 0) {
      final shakeX = (DateTime.now().millisecondsSinceEpoch % 100) / 100 * _screenShakeIntensity;
      final shakeY = (DateTime.now().millisecondsSinceEpoch % 67) / 100 * _screenShakeIntensity;
      _shakeCamera(Vector2(shakeX - _screenShakeIntensity / 2, shakeY - _screenShakeIntensity / 2));
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

    Future.delayed(const Duration(milliseconds: 300), () {
      pauseEngine();
      // ✅ Directly add overlay
      if (!overlays.isActive('GameOver')) {
        overlays.add('GameOver');
      }
      _isTransitioning = false;
    });

    print("💀 Game Over! Score: $finalScore | Distance: ${finalDistance}m | Coins: $_collectedCoins");
  }

  void addCoin(int value) {
    if (!isGameOver && !isPaused) {
      _collectedCoins += value;
      _totalCoinsCollected += value;

      _hud.notifyCoinCollected();
      scoreManager.increaseScore(points: value);
      _hud.notifyScoreIncrease(value);

      print("💰 Coin! +$value | Total: $_collectedCoins");
    }
  }

  void addScore(int points) {
    if (!isGameOver && !isPaused) {
      scoreManager.increaseScore(points: points);
      _hud.notifyScoreIncrease(points);
    }
  }

  void addPipeScore() {
    if (!isGameOver && !isPaused) {
      scoreManager.increaseScore(points: 5);
      _hud.notifyScoreIncrease(5);
    }
  }

  void addDistance() {
    if (!isGameOver && !isPaused) {
      _hud.notifyDistanceIncrease();
    }
  }

  void reviveBird() {
    if (isGameOver) {
      isGameOver = false;
      bird.isAlive = true;
      resumeEngine();
      print("🕊️ Bird revived!");
    }
  }

  Future<void> reset() async {
    if (_isTransitioning) return;

    _isTransitioning = true;
    isGameOver = false;
    isPaused = false;
    _collectedCoins = 0;
    _distance = 0;

    // Remove overlay if showing
    if (overlays.isActive('GameOver')) {
      overlays.remove('GameOver');
    }
    // _pauseMenu.hide();

    // Remove all game components except background, ground, and UI
    final componentsToRemove = <Component>[];

    for (final component in children) {
      if (component is Background ||
          component is Ground ||
          component is HUD ) {
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

    _shakeCamera(Vector2.zero());
    _screenShakeIntensity = 0;

    resumeEngine();
    _isTransitioning = false;

    print("🔄 Game Reset!");
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isGameOver && !isPaused && bird.isAlive) {
      _distance += 100 * dt;
      _applyHitStop(dt);
    }

    _applyScreenShake(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}