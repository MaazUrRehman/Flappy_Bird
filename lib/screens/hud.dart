import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/flappy_bird_game.dart';

class HUD extends Component with HasGameRef<FlappyBirdGame> {
  late TextComponent _coinText;
  late TextComponent _scoreText;
  late TextComponent _distanceText;

  double _coinScale = 1.0;
  double _scoreScale = 1.0;
  double _distanceScale = 1.0;

  late CustomPaintComponent _coinContainer;
  late CustomPaintComponent _scoreContainer;
  late CustomPaintComponent _distanceContainer;

  late CustomPaintComponent _starIcon;
  late CustomPaintComponent _flagIcon;

  // Helper methods for consistent alignment
  double getLabelY(double y) => y + 10;
  double getValueY(double y, double height) => y + height - 28;
  double getCenterY(double y, double height) => y + height / 2;

  @override
  Future<void> onLoad() async {
    priority = 1000;
    await super.onLoad();

    _buildCoinContainer();
    _buildScoreContainer();
    _buildDistanceContainer();
  }

  void _buildCoinContainer() {
    const x = 15.0;
    const y = 15.0;
    const width = 130.0;
    const height = 60.0;

    final iconCenterY = getCenterY(y, height);
    final labelY = getLabelY(y);
    final valueY = getValueY(y, height);

    // Main container with rounded corners and dark blue background
    _coinContainer = CustomPaintComponent(
      size: Vector2(width, height),
      position: Vector2(x, y),
      painter: (canvas, size) {
        final rect = Rect.fromLTWH(0, 0, size.x, size.y);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

        // Dark blue background fill
        final fillPaint = Paint()
          ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);

        // Colored border
        final borderPaint = Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rrect, borderPaint);
      },
    );
    add(_coinContainer);

    // Coin Icon with center anchor
    final iconCircle = CircleComponent(
      radius: 14,
      position: Vector2(x + 22, iconCenterY),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFFFD700),
    );
    add(iconCircle);

    final innerCircle = CircleComponent(
      radius: 10,
      position: Vector2(x + 22, iconCenterY),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFFFC107),
    );
    add(innerCircle);

    // Label
    final label = TextComponent(
      text: 'COINS',
      position: Vector2(x + 50, labelY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(label);

    // Value with proper bottom padding
    _coinText = TextComponent(
      text: '0',
      position: Vector2(x + 50, valueY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFD700),
        fontFamily: 'monospace',
      )),
    );
    add(_coinText);
  }

  void _buildScoreContainer() {
    final screenWidth = gameRef.size.x;
    const width = 130.0;
    const height = 60.0;
    final x = screenWidth / 2 - width / 2;
    const y = 15.0;

    final iconCenterY = getCenterY(y, height);
    final labelY = getLabelY(y);
    final valueY = getValueY(y, height);

    // Main container with rounded corners and dark blue background
    _scoreContainer = CustomPaintComponent(
      size: Vector2(width, height),
      position: Vector2(x, y),
      painter: (canvas, size) {
        final rect = Rect.fromLTWH(0, 0, size.x, size.y);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

        // Dark blue background fill
        final fillPaint = Paint()
          ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);

        // Colored border
        final borderPaint = Paint()
          ..color = const Color(0xFFFF6B6B).withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rrect, borderPaint);
      },
    );
    add(_scoreContainer);

    // Star Icon with center anchor
    _starIcon = CustomPaintComponent(
      size: Vector2(30, 30),
      position: Vector2(x + 7, iconCenterY - 15),
      painter: (canvas, size) {
        final centerX = size.x / 2;
        final centerY = size.y / 2;
        const outerRadius = 12.0;
        const innerRadius = 5.0;
        const points = 5;

        final path = Path();
        for (int i = 0; i < points * 2; i++) {
          final radius = i.isEven ? outerRadius : innerRadius;
          final angle = (i * pi / points) - pi / 2;
          final dx = centerX + radius * cos(angle);
          final dy = centerY + radius * sin(angle);
          if (i == 0) {
            path.moveTo(dx, dy);
          } else {
            path.lineTo(dx, dy);
          }
        }
        path.close();

        final paint = Paint()..color = const Color(0xFFFF6B6B);
        canvas.drawPath(path, paint);
      },
    );
    add(_starIcon);

    // Label
    final label = TextComponent(
      text: 'SCORE',
      position: Vector2(x + 50, labelY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(label);

    // Value with proper bottom padding
    _scoreText = TextComponent(
      text: '0',
      position: Vector2(x + 50, valueY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF6B6B),
        fontFamily: 'monospace',
      )),
    );
    add(_scoreText);
  }

  void _buildDistanceContainer() {
    final screenWidth = gameRef.size.x;
    const width = 130.0;
    const height = 60.0;
    final x = screenWidth - width - 15;
    const y = 15.0;

    final iconCenterY = getCenterY(y, height);
    final labelY = getLabelY(y);
    final valueY = getValueY(y, height);

    // Main container with rounded corners and dark blue background
    _distanceContainer = CustomPaintComponent(
      size: Vector2(width, height),
      position: Vector2(x, y),
      painter: (canvas, size) {
        final rect = Rect.fromLTWH(0, 0, size.x, size.y);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

        // Dark blue background fill
        final fillPaint = Paint()
          ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);

        // Colored border
        final borderPaint = Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rrect, borderPaint);
      },
    );
    add(_distanceContainer);

    // Flag Icon with center anchor
    _flagIcon = CustomPaintComponent(
      size: Vector2(40, 40),
      position: Vector2(x + 2, iconCenterY - 20),
      painter: (canvas, size) {
        // Flag pole
        final polePaint = Paint()
          ..color = Colors.white70
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(15, size.y - 15),
          Offset(15, 5),
          polePaint,
        );

        // Flag
        final flagPath = Path();
        flagPath.moveTo(15, 5);
        flagPath.lineTo(32, 12);
        flagPath.lineTo(15, 19);
        flagPath.close();

        final flagPaint = Paint()..color = const Color(0xFF4CAF50);
        canvas.drawPath(flagPath, flagPaint);
      },
    );
    add(_flagIcon);

    // Label
    final label = TextComponent(
      text: 'DISTANCE',
      position: Vector2(x + 50, labelY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(label);

    // Value with proper bottom padding
    _distanceText = TextComponent(
      text: '0',
      position: Vector2(x + 50, valueY),
      textRenderer: TextPaint(style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4CAF50),
        fontFamily: 'monospace',
      )),
    );
    add(_distanceText);
  }

  void notifyCoinCollected() {
    _coinScale = 1.3;
    _coinText.scale = Vector2(1.3, 1.3);
  }

  void notifyScoreIncrease(int points) {
    _scoreScale = 1.3;
    _scoreText.scale = Vector2(1.3, 1.3);
  }

  void notifyDistanceIncrease() {
    _distanceScale = 1.2;
    _distanceText.scale = Vector2(1.2, 1.2);
  }

  @override
  void update(double dt) {
    _updateScales(dt);
    _updateValues();
  }

  void _updateScales(double dt) {
    if (_coinScale > 1.0) {
      _coinScale = (_coinScale - dt * 6).clamp(1.0, 1.5);
      _coinText.scale = Vector2(_coinScale, _coinScale);
    }
    if (_scoreScale > 1.0) {
      _scoreScale = (_scoreScale - dt * 6).clamp(1.0, 1.5);
      _scoreText.scale = Vector2(_scoreScale, _scoreScale);
    }
    if (_distanceScale > 1.0) {
      _distanceScale = (_distanceScale - dt * 6).clamp(1.0, 1.5);
      _distanceText.scale = Vector2(_distanceScale, _distanceScale);
    }
  }

  void _updateValues() {
    if (gameRef.isGameOverState) return;

    _coinText.text = '${gameRef.collectedCoins}';
    _scoreText.text = '${gameRef.score}';

    final distance = gameRef.distance.toInt();
    _distanceText.text = '$distance';
  }
}

// Helper component for custom painting
class CustomPaintComponent extends PositionComponent {
  final void Function(Canvas canvas, Vector2 size) painter;

  CustomPaintComponent({
    required Vector2 size,
    required Vector2 position,
    required this.painter,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    painter(canvas, size);
  }
}