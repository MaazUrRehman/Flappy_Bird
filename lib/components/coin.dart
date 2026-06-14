import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../game/flappy_bird_game.dart';
import 'bird.dart';

class Coin extends CircleComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
  double speed = 200;
  double rotationSpeed = 3;

  // Animation properties
  double _pulseScale = 1.0;
  double _pulseDirection = 1;
  double _time = 0;

  // Visual effects
  late Paint _coinGradient;
  late Paint _innerGradient;
  late Paint _glowPaint;

  // Coin details
  CoinType coinType;
  int coinValue;
  @override
  double radius;

  // Particles
  final List<Sparkle> _sparkles = [];
  bool _isCollected = false;
  double _collectionAnimation = 0;

  Coin({
    required Vector2 position,
    this.coinType = CoinType.gold,
    this.coinValue = 1,
    this.radius = 7,
  }) : super(
          radius: 7,
          position: position,
          anchor: Anchor.center,
          paint: Paint(),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    radius = radius; // Apply custom radius

    _setupCoinType();
    _setupGradients();

    final hitbox = CircleHitbox()
      ..radius = radius * 0.7
      ..collisionType = CollisionType.passive;
    add(hitbox);

    _generateSparkles();
  }

  void _setupCoinType() {
    rotationSpeed = 3;
  }

  void _setupGradients() {
    _coinGradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.2, 0.3),
        radius: 0.8,
        colors: [
          Color(0xFFFFF8E7),
          Color(0xFFFFD700),
          Color(0xFFDAA520),
          Color(0xFFB8860B),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(position.x, position.y),
        radius: radius,
      ));

    _innerGradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [
          Color(0xFFFFE44D),
          Color(0xFFDAA520),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(position.x, position.y),
        radius: radius * 0.7,
      ));

    _glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  }

  void _generateSparkles() {
    final random = Random();
    for (int i = 0; i < 4; i++) {
      _sparkles.add(Sparkle(
        angle: random.nextDouble() * pi * 2,
        distance: random.nextDouble() * radius * 1.2,
        speed: 1 + random.nextDouble() * 2,
        size: 1 + random.nextDouble() * 1.5,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final animationDt = dt * gameRef.animationFactor;
    _time += animationDt;

    if (gameRef.isCountdownActive) {
      return;
    }

    if (!_isCollected) {
      // ✅ ONLY horizontal movement - right to left (same as pipes)
      position.x -= speed * gameRef.motionFactor * dt;

      // ✅ Rotation animation only (visual only - doesn't affect position)
      angle += rotationSpeed * animationDt;

      // ✅ Pulse effect (scale only - no position change)
      _pulseScale += _pulseDirection * animationDt * 3;
      if (_pulseScale > 1.1) {
        _pulseScale = 1.1;
        _pulseDirection = -1;
      } else if (_pulseScale < 0.9) {
        _pulseScale = 0.9;
        _pulseDirection = 1;
      }

      // Update sparkles
      for (var sparkle in _sparkles) {
        sparkle.update(animationDt);
      }

      // Remove when offscreen
      if (position.x < -radius * 2) {
        removeFromParent();
      }
    } else {
      _collectionAnimation += animationDt * 5;
      if (_collectionAnimation >= 1) {
        removeFromParent();
      }
    }

    _updateGradients();
  }

  void _updateGradients() {
    _coinGradient.shader = RadialGradient(
      center:
          Alignment(0.2 + sin(_time * 5) * 0.05, 0.3 + cos(_time * 4) * 0.05),
      radius: 0.8,
      colors: const [
        Color(0xFFFFF8E7),
        Color(0xFFFFD700),
        Color(0xFFDAA520),
        Color(0xFFB8860B),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromCircle(
      center: Offset(position.x, position.y),
      radius: radius,
    ));

    final glowIntensity = 0.3 + sin(_time * 8) * 0.15;
    _glowPaint.color = const Color(0xFFFFD700).withOpacity(glowIntensity);
  }

  @override
  void render(Canvas canvas) {
    if (_isCollected) {
      _renderCollectionBurst(canvas);
      return;
    }

    canvas.save();

    canvas.scale(_pulseScale);

    // Draw glow
    canvas.drawCircle(Offset.zero, radius + 3, _glowPaint);

    final rimPaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset.zero, radius, rimPaint);
    canvas.drawCircle(Offset.zero, radius - 1, _coinGradient);
    canvas.drawCircle(Offset.zero, radius * 0.7, _innerGradient);

    canvas.drawCircle(
      Offset.zero,
      radius * 0.7,
      rimPaint..strokeWidth = 1,
    );

    _drawStar(canvas, Offset.zero, radius * 0.5, 5);
    _renderSparkles(canvas);
    _renderHighlight(canvas);

    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset center, double size, int points) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.4;
    final paint = Paint()..color = const Color(0xFFDAA520);

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _renderSparkles(Canvas canvas) {
    for (var sparkle in _sparkles) {
      final sparklePaint = Paint()
        ..color = Colors.white
            .withOpacity(0.5 + sin(_time * sparkle.speed * 10) * 0.3);

      final x = cos(sparkle.angle + _time * 2) * sparkle.distance;
      final y = sin(sparkle.angle + _time * 2) * sparkle.distance;

      canvas.drawCircle(Offset(x, y), sparkle.size, sparklePaint);
    }
  }

  void _renderHighlight(Canvas canvas) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );
  }

  void _renderCollectionBurst(Canvas canvas) {
    final progress = _collectionAnimation;
    final burstRadius = radius * (1 + progress * 3);
    final opacity = (1 - progress).clamp(0.0, 1.0);

    final burstPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(opacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(position.x, position.y), burstRadius, burstPaint);

    if (progress < 0.5) {
      final textPaint = TextPainter(
        text: TextSpan(
          text: '+$coinValue',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPaint.layout();
      textPaint.paint(
        canvas,
        Offset(position.x - textPaint.width / 2, position.y - 15),
      );
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bird && !_isCollected) {
      _isCollected = true;
      // ✅ FIXED: Call addCoin instead of addScore
      gameRef.addCoin(coinValue);
    }
  }
}

enum CoinType {
  gold,
}

class Sparkle {
  double angle;
  double distance;
  double speed;
  double size;

  Sparkle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
  });

  void update(double dt) {}
}
