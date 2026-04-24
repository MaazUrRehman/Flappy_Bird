import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreManager extends Component {

  // Core score variables
  int _score = 0;
  int _highScore = 0;
  int _coinsCollected = 0;

  // Animation properties
  double _scoreScale = 1.0;
  double _scorePopupTimer = 0;
  int _lastScoreAdded = 0;

  // Callbacks
  VoidCallback? onScoreChanged;
  VoidCallback? onHighScoreReached;

  ScoreManager() {
    _loadHighScore();
  }

  // ==================== GETTERS ====================

  int get score => _score;
  int get highScore => _highScore;
  int get coinsCollected => _coinsCollected;

  // ==================== SCORE METHODS ====================

  // ✅ For pipe pass: +5 points (or any points)
  void increaseScore({int points = 1}) {
    _score += points;
    _lastScoreAdded = points;

    // Trigger popup animation
    _scorePopupTimer = 0.5;
    _scoreScale = 1.3;

    // Check high score
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
      if (onHighScoreReached != null) onHighScoreReached!();
    }

    // Notify listeners
    if (onScoreChanged != null) onScoreChanged!();

    print("✅ Score increased by $points! Total: $_score");
  }

  // For coins collection
  void increaseCoins({int amount = 1}) {
    _coinsCollected += amount;
    if (onScoreChanged != null) onScoreChanged!();
    print("💰 Coins: $_coinsCollected");
  }

  // ==================== RESET METHODS ====================

  void reset() {
    _score = 0;
    _coinsCollected = 0;
    _scorePopupTimer = 0;
    _scoreScale = 1.0;

    if (onScoreChanged != null) onScoreChanged!();
  }

  // ==================== HIGH SCORE PERSISTENCE ====================

  void _loadHighScore() async {
    // In production, use SharedPreferences
    _highScore = 0;
  }

  void _saveHighScore() async {
    // In production, use SharedPreferences
  }

  // ==================== RENDERING ====================

  @override
  void update(double dt) {
    super.update(dt);

    // Animate score scale
    if (_scoreScale > 1.0) {
      _scoreScale -= dt * 8;
      if (_scoreScale < 1.0) _scoreScale = 1.0;
    }

    // Update popup timer
    if (_scorePopupTimer > 0) {
      _scorePopupTimer -= dt;
    }
  }

  void renderScorePopup(Canvas canvas, Offset position) {
    if (_scorePopupTimer > 0 && _lastScoreAdded > 0) {
      final opacity = (_scorePopupTimer / 0.5).clamp(0.0, 1.0);
      final fontSize = 28 * (1 + (1 - opacity) * 0.5);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '+$_lastScoreAdded',
          style: TextStyle(
            color: _lastScoreAdded == 5 ? Colors.cyan : Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(position.dx - textPainter.width / 2, position.dy - 40 * (1 - opacity)),
      );
    }
  }
}