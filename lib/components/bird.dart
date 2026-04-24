import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../game/flappy_bird_game.dart';
import 'pipe.dart';
import 'ground.dart';

class Bird extends RectangleComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {

  // Physics
  double velocity = 0;
  double gravity = 900;
  double jumpForce = -320;

  // Animation
  double _timeAlive = 0;
  double _wingFlapAngle = 0;

  // Effects
  double _hitFlashIntensity = 0;
  double _scalePulse = 0;

  // State
  bool isAlive = true;
  bool _isGameOverTriggered = false;

  Bird() : super(
    size: Vector2(50, 40),
    position: Vector2(100, 300),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add hitbox
    add(RectangleHitbox(
      size: Vector2(38, 35),
      position: Vector2(6, 2.5),
    ));

    await _addShadow();
  }

  Future<void> _addShadow() async {
    final shadow = CircleComponent(
      radius: 22,
      position: Vector2(5, 30),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    add(shadow);
  }

  void jump() {
    if (!gameRef.isGameOver && isAlive) {
      velocity = jumpForce;
      _scalePulse = 0.3;
      _animateJump();
    }
  }

  void _animateJump() {
    scale.setValues(0.8, 1.2);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!gameRef.isGameOver && isAlive) {
        scale.setValues(1.0, 1.0);
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver) {
      return;
    }

    _timeAlive += dt;

    velocity += gravity * dt;
    position.y += velocity * dt;

    // Tilt animation
    angle = (velocity / 350).clamp(-0.8, 0.8);

    // Idle bobbing
    if (velocity.abs() < 50) {
      position.y += sin(_timeAlive * 12) * 0.5;
    }

    // Scale pulse
    if (_scalePulse > 0) {
      _scalePulse -= dt * 5;
      double s = 1.0 + sin(_scalePulse * 20) * 0.1;
      scale.setValues(s, s);
    } else {
      scale.setValues(1.0, 1.0);
    }

    _checkBoundaries();
  }

  void _checkBoundaries() {
    if (position.y <= 0) {
      position.y = 0;
      velocity = max(velocity, 0);
      _triggerGameOver();
    }

    double groundY = gameRef.size.y - 55;

    if (position.y + size.y >= groundY) {
      position.y = groundY - size.y;
      scale.setValues(1.2, 0.6);
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    if (!_isGameOverTriggered && isAlive) {
      _hitFlashIntensity = 1.0;
      _isGameOverTriggered = true;
      gameRef.gameOver();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isGameOverTriggered) return;

    if (other is Pipe || other is Ground) {
      _triggerGameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw glow effect
    if (!gameRef.isGameOver) {
      final glow = Paint()
        ..color = Colors.yellow.withOpacity(0.3 + sin(_timeAlive * 10) * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-5, -3, size.x + 10, size.y + 6),
          const Radius.circular(15),
        ),
        glow,
      );
    }

    // Draw bird body
    final bodyPaint = Paint();

    // Hit flash effect
    if (_hitFlashIntensity > 0.5) {
      bodyPaint.color = Colors.red;
      _hitFlashIntensity -= 0.05;
    } else {
      bodyPaint.color = const Color(0xFFFFD700); // Gold/Yellow
    }

    // Draw rounded body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(20),
      ),
      bodyPaint,
    );

    // Draw belly (lighter color)
    final bellyPaint = Paint()..color = const Color(0xFFFFF176);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 15, size.x - 10, size.y - 20),
        const Radius.circular(10),
      ),
      bellyPaint,
    );

    // Draw eye
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.x - 12, size.y * 0.3),
      7,
      eyePaint,
    );

    // Draw pupil
    final pupilPaint = Paint()..color = Colors.black;
    // Pupil follows direction based on velocity
    double pupilOffset = (velocity / 500).clamp(-2, 2);
    canvas.drawCircle(
      Offset(size.x - 12 + pupilOffset, size.y * 0.3),
      4,
      pupilPaint,
    );

    // Draw eye highlight
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.x - 14, size.y * 0.28),
      2,
      highlightPaint,
    );

    // Draw beak
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    final beakPath = Path();
    beakPath.moveTo(size.x - 5, size.y * 0.3);
    beakPath.lineTo(size.x + 8, size.y * 0.35);
    beakPath.lineTo(size.x - 5, size.y * 0.4);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Draw wing (flapping animation)
    final wingPaint = Paint()..color = const Color(0xFFF9A825);
    final wingPath = Path();
    double wingAngle = sin(_timeAlive * 15) * 0.5;

    if (velocity > 0) {
      // Falling - wings up
      wingPath.moveTo(8, size.y * 0.5);
      wingPath.quadraticBezierTo(
          15 + wingAngle * 5,
          size.y * 0.3,
          25,
          size.y * 0.5
      );
    } else {
      // Flapping - wings down
      wingPath.moveTo(8, size.y * 0.5);
      wingPath.quadraticBezierTo(
          15 + wingAngle * 5,
          size.y * 0.7,
          25,
          size.y * 0.5
      );
    }
    wingPath.lineTo(25, size.y * 0.6);
    wingPath.lineTo(8, size.y * 0.6);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    // Draw cheek (red spot)
    final cheekPaint = Paint()..color = Colors.red.withOpacity(0.6);
    canvas.drawCircle(
      Offset(size.x - 18, size.y * 0.45),
      3,
      cheekPaint,
    );

    // Draw feathers on top
    final featherPaint = Paint()..color = const Color(0xFFFFC107);
    final featherPath = Path();
    featherPath.moveTo(size.x * 0.3, 0);
    featherPath.lineTo(size.x * 0.4, -8);
    featherPath.lineTo(size.x * 0.5, 0);
    featherPath.close();
    canvas.drawPath(featherPath, featherPaint);

    featherPath.reset();
    featherPath.moveTo(size.x * 0.45, 0);
    featherPath.lineTo(size.x * 0.55, -6);
    featherPath.lineTo(size.x * 0.65, 0);
    featherPath.close();
    canvas.drawPath(featherPath, featherPaint);

    // Draw tail feathers
    final tailPaint = Paint()..color = const Color(0xFFFFC107);
    final tailPath = Path();
    tailPath.moveTo(0, size.y * 0.6);
    tailPath.lineTo(-10, size.y * 0.55);
    tailPath.lineTo(-5, size.y * 0.65);
    tailPath.lineTo(-12, size.y * 0.7);
    tailPath.lineTo(-3, size.y * 0.75);
    tailPath.lineTo(0, size.y * 0.7);
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);
  }

  void reset() {
    velocity = 0;
    position = Vector2(100, 300);
    _isGameOverTriggered = false;
    _timeAlive = 0;
    _hitFlashIntensity = 0;
    _scalePulse = 0;
    angle = 0;
    scale.setValues(1.0, 1.0);
    isAlive = true;
  }
}