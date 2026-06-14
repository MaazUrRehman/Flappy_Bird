// ignore_for_file: unused_field

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/flappy_bird_game.dart';
import '../models/environment_theme.dart';

class Ground extends RectangleComponent with HasGameRef<FlappyBirdGame> {
  late RectangleComponent _dirtLayer;
  late RectangleComponent _detailLayer;

  double _scrollOffset = 0;
  double _scrollSpeed = 150;

  late Paint _shadowPaint;

  final List<GroundDetail> _details = [];
  final List<SmallStone> _stones = [];
  final List<GrassBlade> _grassBlades = []; // Realistic grass

  double _time = 0;
  bool _isRaining = false;

  Ground()
      : super(
          size: Vector2(1000, 65),
          paint: Paint()..color = Colors.transparent,
        ) {
    priority = 2;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(gameRef.size.x, 65);
    position = Vector2(0, gameRef.size.y - size.y);

    _setupLayers();
    _setupGradients();
    _generateDetails();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, 65);
    position = Vector2(0, size.y - this.size.y);
  }

  void _setupLayers() {
    _dirtLayer = RectangleComponent(
      size: Vector2(size.x, size.y),
      position: Vector2(0, 0),
      paint: Paint()..color = const Color(0xFF8B5A2B),
    );

    _detailLayer = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.transparent,
    );

    add(_dirtLayer);
    add(_detailLayer);
  }

  void _setupGradients() {
    _shadowPaint = Paint()..color = const Color(0xFF6D4C41).withOpacity(0.3);
  }

  void _generateDetails() {
    final random = Random(42);

    // Ground cracks and patches
    for (int i = 0; i < 50; i++) {
      _details.add(GroundDetail(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        width: 2 + random.nextDouble() * 8,
        height: 1 + random.nextDouble() * 3,
        color: _getRandomBrownColor(random),
      ));
    }

    // Stones
    for (int i = 0; i < 20; i++) {
      _stones.add(SmallStone(
        x: random.nextDouble() * size.x,
        size: 3 + random.nextDouble() * 6,
        yOffset: random.nextDouble() * size.y,
        color: _getRandomStoneColor(random),
      ));
    }

    // Realistic grass blades on top edge
    for (int i = 0; i < 80; i++) {
      _grassBlades.add(GrassBlade(
        x: random.nextDouble() * size.x,
        height: 6 + random.nextDouble() * 10,
        angle: -0.3 + random.nextDouble() * 0.6,
        color: _getRandomGrassColor(random),
      ));
    }
  }

  Color _getRandomBrownColor(Random random) {
    final colors = [
      const Color(0xFF6D4C41),
      const Color(0xFF795548),
      const Color(0xFF5D4037),
      const Color(0xFF8D6E63),
      const Color(0xFF7B5B4A),
    ];
    return colors[random.nextInt(colors.length)]
        .withOpacity(0.5 + random.nextDouble() * 0.4);
  }

  Color _getRandomStoneColor(Random random) {
    final colors = [
      const Color(0xFF8D6E63),
      const Color(0xFF795548),
      const Color(0xFF6D4C41),
      const Color(0xFF9E8B7A),
    ];
    return colors[random.nextInt(colors.length)];
  }

  Color _getRandomGrassColor(Random random) {
    final colors = [
      const Color(0xFF66BB6A),
      const Color(0xFF4CAF50),
      const Color(0xFF43A047),
      const Color(0xFF81C784),
    ];
    return colors[random.nextInt(colors.length)];
  }

  void startRainEffect() {
    _isRaining = true;
  }

  void stopRainEffect() {
    _isRaining = false;
  }

  void setScrollSpeed(double speed) {
    _scrollSpeed = speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final motionDt = dt * gameRef.motionFactor;
    final animationDt = dt * gameRef.animationFactor;
    _time += animationDt;

    _scrollOffset += _scrollSpeed * motionDt;
    if (_scrollOffset >= size.x) {
      _scrollOffset -= size.x;
    }

    // Animate grass blades
    for (var grass in _grassBlades) {
      grass.update(animationDt, _time);
    }
  }

  @override
  void render(Canvas canvas) {
    final theme = EnvironmentTheme.current();
    _renderDirtLayer(canvas, theme);
    _renderDetails(canvas);
    _renderStones(canvas, theme);
    _renderThemeForeground(canvas, theme);
    _renderGrassBlades(canvas, theme); // Realistic grass on top
    _renderTopEdgeShadow(canvas, theme);

    if (_isRaining) {
      _renderRainEffect(canvas);
    }
  }

  void _renderDirtLayer(Canvas canvas, EnvironmentTheme theme) {
    // Base brown color
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.groundTop, theme.groundBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), basePaint);

    // Texture dots for realistic dirt
    final dotPaint = Paint()..color = theme.groundBottom.withOpacity(0.5);
    for (int i = 0; i < 200; i++) {
      final x = ((i * 17 - _scrollOffset) % size.x + size.x) % size.x;
      final y = (i * 13 % size.y);
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3).toDouble(), dotPaint);
    }

    // Light spots (sand/pebbles)
    final lightPaint = Paint()..color = theme.accent.withOpacity(0.18);
    for (int i = 0; i < 100; i++) {
      final x = ((i * 23 - _scrollOffset) % size.x + size.x) % size.x;
      final y = (i * 19 % size.y);
      canvas.drawCircle(Offset(x, y), 1, lightPaint);
    }

    // Horizontal texture lines
    final linePaint = Paint()
      ..color = theme.groundBottom.withOpacity(0.35)
      ..strokeWidth = 1.5;

    for (double y = 6; y < size.y; y += 10) {
      final offsetY = y + sin(_time * 1.5 + y * 0.1) * 1;
      canvas.drawLine(
        Offset(0, offsetY),
        Offset(size.x, offsetY + 2),
        linePaint,
      );
    }
  }

  void _renderDetails(Canvas canvas) {
    final paint = Paint();
    for (var detail in _details) {
      paint.color = detail.color;
      canvas.drawRect(
        Rect.fromLTWH(
          (detail.x - _scrollOffset * 0.3) % size.x,
          detail.y,
          detail.width,
          detail.height,
        ),
        paint,
      );
    }
  }

  void _renderStones(Canvas canvas, EnvironmentTheme theme) {
    final paint = Paint();
    for (var stone in _stones) {
      paint.color = Color.lerp(stone.color, theme.groundBottom, 0.45)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (stone.x - _scrollOffset * 0.4) % size.x,
            stone.yOffset,
            stone.size,
            stone.size * 0.7,
          ),
          Radius.circular(stone.size / 2),
        ),
        paint,
      );

      // Stone highlight
      paint.color = theme.lightColor.withOpacity(0.28);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (stone.x - _scrollOffset * 0.4) % size.x + 1,
            stone.yOffset + 1,
            stone.size - 2,
            stone.size * 0.3,
          ),
          Radius.circular(stone.size / 3),
        ),
        paint,
      );

      // Stone shadow
      paint.color = theme.groundBottom.withOpacity(0.45);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (stone.x - _scrollOffset * 0.4) % size.x + 1,
            stone.yOffset + stone.size * 0.5,
            stone.size - 2,
            stone.size * 0.3,
          ),
          Radius.circular(stone.size / 3),
        ),
        paint,
      );
    }
  }

  void _renderGrassBlades(Canvas canvas, EnvironmentTheme theme) {
    if (['cyber', 'space', 'volcano', 'nightmare', 'ocean', 'arctic']
        .contains(theme.id)) {
      return;
    }
    for (var grass in _grassBlades) {
      final x = ((grass.x - _scrollOffset * 0.5) % size.x + size.x) % size.x;
      final currentAngle = grass.getCurrentAngle();
      final currentHeight = grass.getCurrentHeight();

      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + sin(currentAngle) * currentHeight * 0.3, -currentHeight);
      path.lineTo(x + cos(currentAngle + 0.5) * currentHeight * 0.2,
          -currentHeight * 0.6);
      path.lineTo(
          x - sin(currentAngle) * currentHeight * 0.2, -currentHeight * 0.3);
      path.close();

      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(grass.color, theme.accent, 0.25)!,
      );

      // Tip of grass (lighter)
      final tipPaint = Paint()..color = grass.color.withOpacity(0.8);
      canvas.drawCircle(
          Offset(x + sin(currentAngle) * currentHeight * 0.3, -currentHeight),
          1.5,
          tipPaint);
    }
  }

  void _renderTopEdgeShadow(Canvas canvas, EnvironmentTheme theme) {
    // Dark shadow at the top edge of ground
    final shadowPaint = Paint()
      ..color = theme.groundBottom.withOpacity(0.48)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRect(
      Rect.fromLTWH(0, -2, size.x, 8),
      shadowPaint,
    );

    // Top highlight edge
    final edgePaint = Paint()
      ..color = theme.lightColor.withOpacity(0.45)
      ..strokeWidth = 1.5;

    for (double x = 0; x < size.x; x += 4) {
      final y = sin((x + _time * 60) / 25) * 1.2;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 2, y + sin((x + 5 + _time * 60) / 25) * 1.2),
        edgePaint,
      );
    }
  }

  void _renderRainEffect(Canvas canvas) {
    final rainPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1;

    for (int i = 0; i < 80; i++) {
      final x = (i * 31 + _time * 200) % size.x;
      final y = (i * 17 + _time * 400) % size.y;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 8), rainPaint);
    }
  }

  void _renderThemeForeground(Canvas canvas, EnvironmentTheme theme) {
    final accent = Paint()..color = theme.accent.withOpacity(0.58);
    final dark = Paint()..color = theme.groundBottom.withOpacity(0.72);
    for (var i = 0; i < 18; i++) {
      final x = ((i * 41 - _scrollOffset * 0.75) % size.x + size.x) % size.x;
      final y = (12 + (i * 17 % max(16, size.y.toInt() - 10))).toDouble();
      switch (theme.id) {
        case 'cyber':
          canvas.drawRect(Rect.fromLTWH(x, y, 18, 3), accent);
          break;
        case 'arctic':
          canvas.drawPath(
            Path()
              ..moveTo(x, y + 14)
              ..lineTo(x + 8, y - 8)
              ..lineTo(x + 17, y + 14)
              ..close(),
            accent,
          );
          break;
        case 'ocean':
          canvas.drawCircle(Offset(x, y), 4 + (i % 3).toDouble(), accent);
          break;
        case 'volcano':
        case 'nightmare':
          canvas.drawCircle(Offset(x, y), 3 + (i % 2).toDouble(), accent);
          break;
        case 'candy':
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, 18, 8),
              const Radius.circular(5),
            ),
            accent,
          );
          break;
        case 'steampunk':
          canvas.drawCircle(
            Offset(x, y),
            7,
            Paint()
              ..color = theme.accent.withOpacity(0.38)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          break;
        default:
          canvas.drawOval(Rect.fromLTWH(x, y, 18, 8), dark);
      }
    }
  }

  void reset() {
    _scrollOffset = 0;
    _time = 0;
    _isRaining = false;
  }
}

class SmallStone {
  final double x;
  final double size;
  final double yOffset;
  final Color color;

  SmallStone({
    required this.x,
    required this.size,
    required this.yOffset,
    required this.color,
  });
}

class GroundDetail {
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;

  GroundDetail({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });
}

class GrassBlade {
  final double x;
  final double baseHeight;
  final double baseAngle;
  final Color color;
  double _swayOffset = 0;
  double _currentHeight;
  double _currentAngle;

  GrassBlade({
    required this.x,
    required double height,
    required double angle,
    required this.color,
  })  : baseHeight = height,
        baseAngle = angle,
        _currentHeight = height,
        _currentAngle = angle;

  void update(double dt, double time) {
    _swayOffset = sin(time * 6 + x * 0.8) * 0.15;
    _currentAngle = baseAngle + _swayOffset;
    _currentHeight = baseHeight + sin(time * 8 + x) * 1.5;
  }

  double getCurrentHeight() => _currentHeight;
  double getCurrentAngle() => _currentAngle;
}
