import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/flappy_bird_game.dart';

class HUD extends Component with HasGameRef<FlappyBirdGame> {
  late TextComponent _coinText;
  late TextComponent _scoreText;
  late TextComponent _distanceText;
  late TextComponent _timerText;
  late TextComponent _coinLabel;
  late TextComponent _scoreLabel;
  late TextComponent _distanceLabel;
  late TextComponent _timerLabel;

  double _coinScale = 1.0;
  double _scoreScale = 1.0;
  double _distanceScale = 1.0;

  late CustomPaintComponent _coinContainer;
  late CustomPaintComponent _scoreContainer;
  late CustomPaintComponent _distanceContainer;
  late CustomPaintComponent _timerContainer;

  late CustomPaintComponent _starIcon;
  late CustomPaintComponent _flagIcon;
  late CustomPaintComponent _timerIcon;
  late CircleComponent _coinIconOuter;
  late CircleComponent _coinIconInner;

  bool _isLoaded = false;
  bool _timerVisible = false;

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
    _buildTimerContainer();
    _isLoaded = true;
    _layoutHud();
    _timerVisible = gameRef.isTimerTask;
  }

  void _buildCoinContainer() {
    // Main container with rounded corners and dark blue background
    _coinContainer = CustomPaintComponent(
      size: Vector2.zero(),
      position: Vector2.zero(),
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
    _coinIconOuter = CircleComponent(
      radius: 14,
      position: Vector2.zero(),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFFFD700),
    );
    add(_coinIconOuter);

    _coinIconInner = CircleComponent(
      radius: 10,
      position: Vector2.zero(),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFFFC107),
    );
    add(_coinIconInner);

    // Label
    _coinLabel = TextComponent(
      text: 'COINS',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(_coinLabel);

    // Value with proper bottom padding
    _coinText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFD700),
        fontFamily: 'monospace',
      )),
    );
    add(_coinText);
  }

  void _buildScoreContainer() {
    // Main container with rounded corners and dark blue background
    _scoreContainer = CustomPaintComponent(
      size: Vector2.zero(),
      position: Vector2.zero(),
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
      position: Vector2.zero(),
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
    _scoreLabel = TextComponent(
      text: 'SCORE',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(_scoreLabel);

    // Value with proper bottom padding
    _scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF6B6B),
        fontFamily: 'monospace',
      )),
    );
    add(_scoreText);
  }

  void _buildDistanceContainer() {
    // Main container with rounded corners and dark blue background
    _distanceContainer = CustomPaintComponent(
      size: Vector2.zero(),
      position: Vector2.zero(),
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
      position: Vector2.zero(),
      painter: (canvas, size) {
        // Flag pole
        final polePaint = Paint()
          ..color = Colors.white70
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(15, size.y - 15),
          const Offset(15, 5),
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
    _distanceLabel = TextComponent(
      text: 'DISTANCE',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(_distanceLabel);

    // Value with proper bottom padding
    _distanceText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4CAF50),
        fontFamily: 'monospace',
      )),
    );
    add(_distanceText);
  }

  void _buildTimerContainer() {
    _timerContainer = CustomPaintComponent(
      size: Vector2.zero(),
      position: Vector2.zero(),
      painter: (canvas, size) {
        final rect = Rect.fromLTWH(0, 0, size.x, size.y);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

        final fillPaint = Paint()
          ..color = const Color(0xFF1A1A2E).withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);

        final borderPaint = Paint()
          ..color = const Color(0xFF40C4FF).withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rrect, borderPaint);
      },
    );
    add(_timerContainer);

    _timerIcon = CustomPaintComponent(
      size: Vector2.zero(),
      position: Vector2.zero(),
      painter: (canvas, size) {
        if (size.x <= 0 || size.y <= 0) return;

        final center = Offset(size.x / 2, size.y / 2);
        final radius = min(size.x, size.y) / 2 - 3;
        final clockPaint = Paint()
          ..color = const Color(0xFF40C4FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        final handPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

        canvas.drawCircle(center, radius, clockPaint);
        canvas.drawLine(
            center, Offset(center.dx, center.dy - radius * 0.55), handPaint);
        canvas.drawLine(
            center, Offset(center.dx + radius * 0.45, center.dy), handPaint);
      },
    );
    add(_timerIcon);

    _timerLabel = TextComponent(
      text: '',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 11,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      )),
    );
    add(_timerLabel);

    _timerText = TextComponent(
      text: '',
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF40C4FF),
        fontFamily: 'monospace',
      )),
    );
    add(_timerText);
  }

  _HudLayout _hudLayout() {
    final screenWidth = gameRef.size.x;
    final isCompact = screenWidth < 430;
    final padding = isCompact ? 8.0 : 15.0;
    final gap = isCompact ? 6.0 : 12.0;
    final cardCount = gameRef.isTimerTask ? 4 : 3;
    final availableWidth =
        max(0.0, screenWidth - (padding * 2) - (gap * (cardCount - 1)));
    final cardWidth = min(130.0, availableWidth / cardCount);
    final cardHeight = isCompact ? 54.0 : 60.0;
    final y = isCompact ? 10.0 : 15.0;
    final iconX = isCompact ? 18.0 : 22.0;
    final textX = isCompact ? 36.0 : 50.0;
    final labelFontSize = isCompact ? 9.0 : 11.0;
    final valueFontSize = isCompact ? 20.0 : 24.0;
    final iconScale = isCompact ? 0.78 : 1.0;

    return _HudLayout(
      padding: padding,
      gap: gap,
      width: cardWidth,
      height: cardHeight,
      y: y,
      iconX: iconX,
      textX: textX,
      labelFontSize: labelFontSize,
      valueFontSize: valueFontSize,
      iconScale: iconScale,
    );
  }

  void _layoutHud() {
    final layout = _hudLayout();
    final coinX = layout.padding;
    final scoreX = coinX + layout.width + layout.gap;
    final distanceX = scoreX + layout.width + layout.gap;
    final timerX = distanceX + layout.width + layout.gap;

    _layoutCoinCard(coinX, layout);
    _layoutScoreCard(scoreX, layout);
    _layoutDistanceCard(distanceX, layout);
    _layoutTimerCard(timerX, layout);
  }

  void _layoutCoinCard(double x, _HudLayout layout) {
    final iconCenterY = getCenterY(layout.y, layout.height);
    final labelY = getLabelY(layout.y);
    final valueY = getValueY(layout.y, layout.height);

    _coinContainer
      ..position = Vector2(x, layout.y)
      ..size = Vector2(layout.width, layout.height);
    _coinIconOuter
      ..position = Vector2(x + layout.iconX, iconCenterY)
      ..radius = 14 * layout.iconScale;
    _coinIconInner
      ..position = Vector2(x + layout.iconX, iconCenterY)
      ..radius = 10 * layout.iconScale;
    _coinLabel
      ..position = Vector2(x + layout.textX, labelY)
      ..textRenderer = _labelRenderer(layout.labelFontSize);
    _coinText
      ..position = Vector2(x + layout.textX, valueY)
      ..textRenderer =
          _valueRenderer(layout.valueFontSize, const Color(0xFFFFD700));
  }

  void _layoutScoreCard(double x, _HudLayout layout) {
    final iconCenterY = getCenterY(layout.y, layout.height);
    final labelY = getLabelY(layout.y);
    final valueY = getValueY(layout.y, layout.height);
    final iconSize = 30 * layout.iconScale;

    _scoreContainer
      ..position = Vector2(x, layout.y)
      ..size = Vector2(layout.width, layout.height);
    _starIcon
      ..position =
          Vector2(x + layout.iconX - iconSize / 2, iconCenterY - iconSize / 2)
      ..size = Vector2.all(iconSize);
    _scoreLabel
      ..position = Vector2(x + layout.textX, labelY)
      ..textRenderer = _labelRenderer(layout.labelFontSize);
    _scoreText
      ..position = Vector2(x + layout.textX, valueY)
      ..textRenderer =
          _valueRenderer(layout.valueFontSize, const Color(0xFFFF6B6B));
  }

  void _layoutDistanceCard(double x, _HudLayout layout) {
    final iconCenterY = getCenterY(layout.y, layout.height);
    final labelY = getLabelY(layout.y);
    final valueY = getValueY(layout.y, layout.height);
    final iconSize = 40 * layout.iconScale;

    _distanceContainer
      ..position = Vector2(x, layout.y)
      ..size = Vector2(layout.width, layout.height);
    _flagIcon
      ..position =
          Vector2(x + layout.iconX - iconSize / 2, iconCenterY - iconSize / 2)
      ..size = Vector2.all(iconSize);
    _distanceLabel
      ..position = Vector2(x + layout.textX, labelY)
      ..textRenderer = _labelRenderer(layout.labelFontSize);
    _distanceText
      ..position = Vector2(x + layout.textX, valueY)
      ..textRenderer =
          _valueRenderer(layout.valueFontSize, const Color(0xFF4CAF50));
  }

  void _layoutTimerCard(double x, _HudLayout layout) {
    final isVisible = gameRef.isTimerTask;
    if (!isVisible) {
      _timerContainer.size = Vector2.zero();
      _timerIcon.size = Vector2.zero();
      _timerLabel.text = '';
      _timerText.text = '';
      return;
    }

    final y = layout.y;
    final iconCenterY = getCenterY(y, layout.height);
    final labelY = getLabelY(y);
    final valueY = getValueY(y, layout.height);
    final iconSize = 32 * layout.iconScale;

    _timerContainer
      ..position = Vector2(x, y)
      ..size = Vector2(layout.width, layout.height);
    _timerIcon
      ..position =
          Vector2(x + layout.iconX - iconSize / 2, iconCenterY - iconSize / 2)
      ..size = Vector2.all(iconSize);
    _timerLabel
      ..text = 'TIME'
      ..position = Vector2(x + layout.textX, labelY)
      ..textRenderer = _labelRenderer(layout.labelFontSize);
    _timerText
      ..position = Vector2(x + layout.textX, valueY)
      ..textRenderer =
          _valueRenderer(layout.valueFontSize, const Color(0xFF40C4FF));
  }

  TextPaint _labelRenderer(double fontSize) {
    return TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  TextPaint _valueRenderer(double fontSize, Color color) {
    return TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: 'monospace',
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isLoaded) {
      _layoutHud();
    }
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
    if (_isLoaded && gameRef.isTimerTask != _timerVisible) {
      _layoutHud();
      _timerVisible = gameRef.isTimerTask;
    }
    _updateScales(dt);
    _updateValues();
  }

  void _updateScales(double dt) {
    final animationDt = dt * gameRef.animationFactor;
    if (_coinScale > 1.0) {
      _coinScale = (_coinScale - animationDt * 6).clamp(1.0, 1.5);
      _coinText.scale = Vector2(_coinScale, _coinScale);
    }
    if (_scoreScale > 1.0) {
      _scoreScale = (_scoreScale - animationDt * 6).clamp(1.0, 1.5);
      _scoreText.scale = Vector2(_scoreScale, _scoreScale);
    }
    if (_distanceScale > 1.0) {
      _distanceScale = (_distanceScale - animationDt * 6).clamp(1.0, 1.5);
      _distanceText.scale = Vector2(_distanceScale, _distanceScale);
    }
  }

  void _updateValues() {
    if (gameRef.isGameOverState) return;

    _coinText.text = '${gameRef.collectedCoins}';
    _scoreText.text = '${gameRef.score}';

    final distance = gameRef.distance.toInt();
    _distanceText.text = '$distance';

    final layout = _hudLayout();
    final timerX = layout.padding + ((layout.width + layout.gap) * 3);
    _layoutTimerCard(timerX, layout);
    if (gameRef.isTimerTask) {
      _timerText.text = '${gameRef.remainingTaskSeconds}s';
    }
  }
}

class _HudLayout {
  final double padding;
  final double gap;
  final double width;
  final double height;
  final double y;
  final double iconX;
  final double textX;
  final double labelFontSize;
  final double valueFontSize;
  final double iconScale;

  const _HudLayout({
    required this.padding,
    required this.gap,
    required this.width,
    required this.height,
    required this.y,
    required this.iconX,
    required this.textX,
    required this.labelFontSize,
    required this.valueFontSize,
    required this.iconScale,
  });
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
