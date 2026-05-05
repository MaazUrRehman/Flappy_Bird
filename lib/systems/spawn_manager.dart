import 'dart:math';
import 'package:flame/components.dart';

import '../components/pipe.dart';
import '../components/coin.dart';
import '../game/flappy_bird_game.dart';
import '../models/difficulty_config.dart';

class SpawnManager extends Component with HasGameRef<FlappyBirdGame> {
  double spawnTimer = 0;
  double spawnInterval = 2.5;

  final Random random = Random();

  // Difficulty variables
  double pipeSpeed = 180;
  double gap = 200;
  double _basePipeSpeed = 180;
  double _baseGap = 200;
  bool _hasMovingPipes = false;
  bool _hasRandomPatterns = false;

  // Coin spawn tracking
  int _coinsSpawnedThisWave = 0;
  int _waveCount = 0;

  // Special wave tracking
  bool _isSpecialWave = false;
  int _wavesSinceLastSpecial = 0;

  // Store current pipe gap position for coin spawning
  double _currentGapY = 0;
  double _currentGapSize = 200;

  void configure(DifficultyConfig config) {
    _basePipeSpeed = config.pipeSpeed;
    _baseGap = config.gapSize;
    pipeSpeed = config.pipeSpeed;
    gap = config.gapSize;
    _currentGapSize = config.gapSize;
    _hasMovingPipes = config.hasMovingPipes;
    _hasRandomPatterns = config.hasRandomPatterns;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver || gameRef.isPaused || gameRef.isCountdownActive)
      return;

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      spawnPipes();

      // ✅ NOW coins spawn with knowledge of pipe gap
      _spawnCoinsInGap();

      _waveCount++;
    }
  }

  // ✅ NEW METHOD: Spawn coins ONLY inside pipe gap
  void _spawnCoinsInGap() {
    _isSpecialWave =
        (_waveCount % (_hasRandomPatterns ? 3 : 5) == 0 && _waveCount > 0);

    // ✅ USE ACTUAL PIPE GAP (NOT RANDOM)
    double gapCenterY = _currentGapY;
    double gapSize = _currentGapSize;

    const double safeMargin = 25;

    double minCoinY = gapCenterY - (gapSize / 2) + safeMargin;
    double maxCoinY = gapCenterY + (gapSize / 2) - safeMargin;

    print("🎯 REAL Gap: $gapCenterY | Safe: $minCoinY - $maxCoinY");

    if (_isSpecialWave) {
      _spawnPatternCoinsInGap(minCoinY, maxCoinY, gapCenterY);
    } else {
      _spawnRandomCoinsInGap(minCoinY, maxCoinY);
    }

    _wavesSinceLastSpecial++;
  }

  // ✅ NEW: Spawn random coins strictly inside gap
  void _spawnRandomCoinsInGap(double minY, double maxY) {
    if (random.nextDouble() > 0.7) return;

    int coinCount = 1 + random.nextInt(3);

    double pipeX = gameRef.size.x + 50;

    for (int i = 0; i < coinCount; i++) {
      double coinY = minY + random.nextDouble() * (maxY - minY);

      // ✅ IMPORTANT: SHIFT COIN AWAY FROM PIPE
      double coinX = pipeX + 60 + (i * 40);

      final coin = Coin(
        position: Vector2(coinX, coinY),
        coinType: CoinType.gold,
        coinValue: 1,
        radius: 7,
      );
      coin.speed = pipeSpeed;

      gameRef.add(coin);
    }
  }

  // ✅ NEW: Spawn pattern coins (for special waves) strictly inside gap
  void _spawnPatternCoinsInGap(double minY, double maxY, double centerY) {
    double pipeX = gameRef.size.x + 50;

    // Pattern 1
    for (int i = 0; i < 3; i++) {
      double coinY = centerY - 30 + (i * 30);
      coinY = coinY.clamp(minY, maxY);

      final coin = Coin(
        position: Vector2(pipeX + 60, coinY), // ✅ shifted
        coinType: CoinType.gold,
        coinValue: 2,
        radius: 8,
      );
      coin.speed = pipeSpeed;
      gameRef.add(coin);
    }

    // Pattern 2
    for (int i = 0; i < 3; i++) {
      double coinY = centerY + (i.isEven ? -20 : 20);
      coinY = coinY.clamp(minY, maxY);

      final coin = Coin(
        position: Vector2(pipeX + 120 + (i * 25), coinY), // ✅ shifted more
        coinType: CoinType.gold,
        coinValue: 2,
        radius: 8,
      );
      coin.speed = pipeSpeed;
      gameRef.add(coin);
    }
  }

  void spawnPipes() {
    final screenHeight = gameRef.size.y;
    const groundHeight = 55.0;

    // Dynamic gap based on score
    double dynamicGap = _calculateDynamicGap();
    _currentGapSize = dynamicGap; // Store for reference

    // Dynamic pipe speed
    double currentSpeed = _calculateDynamicSpeed();

    // Calculate pipe heights
    double minHeight = 60;
    double maxHeight = screenHeight - dynamicGap - groundHeight - 60;

    double topPipeHeight =
        minHeight + random.nextDouble() * (maxHeight - minHeight);
    double bottomPipeHeight =
        screenHeight - topPipeHeight - dynamicGap - groundHeight;

    // ✅ Store gap center for coin spawning
    _currentGapY = topPipeHeight + (dynamicGap / 2);

    final xPosition = gameRef.size.x + 50;

    // Create and add pipes
    _createTopPipe(xPosition, topPipeHeight, currentSpeed);
    _createBottomPipe(xPosition, bottomPipeHeight, groundHeight, currentSpeed);

    // Update difficulty progression
    _updateDifficulty();
  }

  double _calculateDynamicGap() {
    double dynamicGap = gap;
    int currentScore = gameRef.score;

    if (currentScore > 100) {
      dynamicGap = max(_baseGap - 50, _baseGap - (currentScore / 200));
    } else if (currentScore > 50) {
      dynamicGap = max(_baseGap - 35, _baseGap - (currentScore / 150));
    } else if (currentScore > 20) {
      dynamicGap = max(_baseGap - 20, _baseGap - (currentScore / 100));
    }

    // Special waves have slightly larger gaps (easier to collect special coins)
    if (_isSpecialWave) {
      dynamicGap += 20;
    }

    return dynamicGap;
  }

  double _calculateDynamicSpeed() {
    double currentSpeed = pipeSpeed;
    int currentScore = gameRef.score;

    if (currentScore > 100) {
      currentSpeed =
          min(_basePipeSpeed + 140, _basePipeSpeed + (currentScore / 2.5));
    } else if (currentScore > 50) {
      currentSpeed =
          min(_basePipeSpeed + 100, _basePipeSpeed + (currentScore / 3));
    } else if (currentScore > 20) {
      currentSpeed =
          min(_basePipeSpeed + 60, _basePipeSpeed + (currentScore / 4));
    }

    return currentSpeed;
  }

  void _createTopPipe(double xPosition, double height, double speed) {
    Pipe topPipe = Pipe(
      position: Vector2(xPosition, 0),
      size: Vector2(65, height),
      pipeType: PipeType.top,
    );
    topPipe.speed = speed;
    topPipe.setMovement(enabled: _hasMovingPipes, phase: 0);
    gameRef.add(topPipe);
  }

  void _createBottomPipe(
      double xPosition, double height, double groundHeight, double speed) {
    final screenHeight = gameRef.size.y;

    Pipe bottomPipe = Pipe(
      position: Vector2(xPosition, screenHeight - height - groundHeight),
      size: Vector2(65, height),
      pipeType: PipeType.bottom,
    );
    bottomPipe.speed = speed;
    bottomPipe.setMovement(enabled: _hasMovingPipes, phase: pi);
    gameRef.add(bottomPipe);
  }

  void _updateDifficulty() {
    int currentScore = gameRef.score;

    // Dynamic spawn interval based on score
    if (currentScore > 100) {
      spawnInterval = max(1.3, 2.5 - (currentScore / 300));
      pipeSpeed =
          min(_basePipeSpeed + 140, _basePipeSpeed + (currentScore / 2.5));
      gap = max(_baseGap - 50, _baseGap - (currentScore / 20));
    } else if (currentScore > 50) {
      spawnInterval = max(1.5, 2.5 - (currentScore / 200));
      pipeSpeed =
          min(_basePipeSpeed + 100, _basePipeSpeed + (currentScore / 3));
      gap = max(_baseGap - 35, _baseGap - (currentScore / 25));
    } else if (currentScore > 20) {
      spawnInterval = max(1.8, 2.5 - (currentScore / 100));
      pipeSpeed = min(_basePipeSpeed + 60, _basePipeSpeed + (currentScore / 4));
      gap = max(_baseGap - 20, _baseGap - (currentScore / 30));
    }

    // Special wave adjustment
    if (_isSpecialWave) {
      spawnInterval = max(1.5, spawnInterval * 1.2);
    }
  }

  /// Get current wave statistics
  Map<String, dynamic> getWaveStats() {
    return {
      'waveCount': _waveCount,
      'isSpecialWave': _isSpecialWave,
      'spawnInterval': spawnInterval,
      'pipeSpeed': pipeSpeed,
      'gap': gap,
      'currentGapY': _currentGapY,
      'currentGapSize': _currentGapSize,
    };
  }

  void reset() {
    spawnTimer = 0;
    spawnInterval = 2.5;
    pipeSpeed = _basePipeSpeed;
    gap = _baseGap;
    _coinsSpawnedThisWave = 0;
    _waveCount = 0;
    _isSpecialWave = false;
    _wavesSinceLastSpecial = 0;
    _currentGapY = 0;
    _currentGapSize = _baseGap;
  }
}
