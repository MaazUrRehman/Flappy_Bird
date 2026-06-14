// import 'dart:math';
// import 'package:flame/components.dart';
// import 'package:flame/collisions.dart';
// import 'package:flame/sprite.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../game/flappy_bird_game.dart';
// import '../controllers/game_config_controller.dart';
// import 'pipe.dart';
// import 'ground.dart';

// class Bird extends RectangleComponent
//     with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
//   // Physics
//   double velocity = 0;
//   double gravity = 900;
//   double jumpForce = -320;

//   // Animation
//   double _timeAlive = 0;
//   double _wingFlapAngle = 0;

//   // Effects
//   double _hitFlashIntensity = 0;
//   double _scalePulse = 0;

//   // State
//   bool isAlive = true;
//   bool _isGameOverTriggered = false;

//   // Sprite management
//   SpriteComponent? _birdSprite;
//   bool _hasSprite = false;

//   Bird()
//       : super(
//           size: Vector2(50, 40),
//           position: Vector2(100, 300),
//         );

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     // Load selected bird sprite
//     await _loadBirdSprite();

//     // Listen for bird changes
//     _listenToBirdChanges();

//     // Add hitbox
//     add(RectangleHitbox(
//       size: Vector2(38, 35),
//       position: Vector2(6, 2.5),
//     ));

//     await _addShadow();
//   }

//   void _listenToBirdChanges() {
//     // Re-load sprite when bird type changes
//     ever(Get.find<GameConfigController>().selectedBird, (_) {
//       _loadBirdSprite();
//     });
//   }

//   Future<void> _loadBirdSprite() async {
//     try {
//       final config = Get.find<GameConfigController>();
//       final birdPath = config.getBirdAssetPath();

//       // Remove old sprite if exists
//       if (_birdSprite != null && _birdSprite!.parent != null) {
//         remove(_birdSprite!);
//       }

//       // Load image from assets
//       final image = await gameRef.images.load('assets/images/$birdPath');

//       // Create sprite
//       final sprite = Sprite(image);

//       _birdSprite = SpriteComponent(
//         sprite: sprite,
//         size: size,
//       );

//       print("🔥 Loading: $birdPath");

//       add(_birdSprite!);
//       _hasSprite = true;
//     } catch (e) {
//       print("⚠️ Failed to load bird sprite: $e");
//       _hasSprite = false;
//       _birdSprite = null;
//     }
//   }

//   Future<void> _addShadow() async {
//     final shadow = CircleComponent(
//       radius: 22,
//       position: Vector2(5, 30),
//       paint: Paint()
//         ..color = Colors.black.withOpacity(0.2)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
//     );
//     add(shadow);
//   }

//   void jump() {
//     if (!gameRef.isGameOver && isAlive) {
//       velocity = jumpForce;
//       _scalePulse = 0.3;
//       _animateJump();
//     }
//   }

//   void _animateJump() {
//     scale.setValues(0.8, 1.2);
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!gameRef.isGameOver && isAlive) {
//         scale.setValues(1.0, 1.0);
//       }
//     });
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     if (gameRef.isGameOver && !isAlive) {
//       return;
//     }

//     _timeAlive += dt;
//     velocity += gravity * dt;
//     position.y += velocity * dt;

//     // Update sprite visibility by adding/removing
//     _updateSpriteVisibility();

//     // Tilt animation
//     angle = (velocity / 350).clamp(-0.8, 0.8);

//     if (_birdSprite != null) {
//       _birdSprite!.angle = angle;
//     }

//     // Idle bobbing
//     if (velocity.abs() < 50) {
//       position.y += sin(_timeAlive * 12) * 0.5;
//     }

//     // Scale pulse
//     if (_scalePulse > 0) {
//       _scalePulse -= dt * 5;
//       double s = 1.0 + sin(_scalePulse * 20) * 0.1;
//       scale.setValues(s, s);
//       if (_birdSprite != null) {
//         _birdSprite!.scale.setValues(s, s);
//       }
//     } else {
//       scale.setValues(1.0, 1.0);
//       if (_birdSprite != null) {
//         _birdSprite!.scale.setValues(1.0, 1.0);
//       }
//     }

//     _checkBoundaries();
//   }

//   void _updateSpriteVisibility() {
//     final shouldBeVisible = isAlive && !gameRef.isGameOver;

//     if (_birdSprite != null) {
//       if (shouldBeVisible && _birdSprite!.parent == null) {
//         // Add sprite if it should be visible but isn't
//         add(_birdSprite!);
//       } else if (!shouldBeVisible && _birdSprite!.parent != null) {
//         // Remove sprite if it shouldn't be visible but is
//         remove(_birdSprite!);
//       }
//     }
//   }

//   void _checkBoundaries() {
//     if (!isAlive) return;

//     if (position.y <= 0) {
//       position.y = 0;
//       velocity = max(velocity, 0);
//       _triggerGameOver();
//     }

//     double groundY = gameRef.size.y - 55;

//     if (position.y + size.y >= groundY) {
//       position.y = groundY - size.y;
//       scale.setValues(1.2, 0.6);
//       if (_birdSprite != null) {
//         _birdSprite!.scale.setValues(1.2, 0.6);
//       }
//       _triggerGameOver();
//     }
//   }

//   void _triggerGameOver() {
//     if (!_isGameOverTriggered && isAlive && !gameRef.isGameOver) {
//       _hitFlashIntensity = 1.0;
//       _isGameOverTriggered = true;
//       isAlive = false;
//       gameRef.gameOver();
//     }
//   }

//   @override
//   void onCollisionStart(
//     Set<Vector2> intersectionPoints,
//     PositionComponent other,
//   ) {
//     super.onCollisionStart(intersectionPoints, other);

//     if (_isGameOverTriggered || !isAlive || gameRef.isGameOver) return;

//     if (other is Pipe || other is Ground) {
//       _triggerGameOver();
//     }
//   }

//   void revive() {
//     print("🐦 Reviving bird...");

//     _isGameOverTriggered = false;
//     isAlive = true;
//     velocity = 0;
//     position = Vector2(100, 300);
//     _timeAlive = 0;
//     _hitFlashIntensity = 0;
//     _scalePulse = 0;
//     angle = 0;
//     scale.setValues(1.0, 1.0);

//     if (_birdSprite != null) {
//       _birdSprite!.scale.setValues(1.0, 1.0);
//       _birdSprite!.angle = 0;
//       // Ensure sprite is added back
//       if (_birdSprite!.parent == null) {
//         add(_birdSprite!);
//       }
//     }

//     print("✅ Bird revived and ready to fly!");
//   }

//   void reset() {
//     revive();
//   }

//   @override
//   void render(Canvas canvas) {
//     // Only render fallback if no sprite is loaded
//     if (!_hasSprite || _birdSprite == null) {
//       _renderFallbackBird(canvas);
//     }
//   }

//   void _renderFallbackBird(Canvas canvas) {
//     // Get environment color adaptation
//     final config = Get.find<GameConfigController>();
//     final env = config.selectedEnvironment.value;

//     // Get bird color based on environment
//     Color birdColor = _getBirdColorForEnvironment(env);

//     // Draw glow effect
//     if (!gameRef.isGameOver && isAlive) {
//       final glow = Paint()
//         ..color = birdColor.withOpacity(0.3 + sin(_timeAlive * 10) * 0.1)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(-5, -3, size.x + 10, size.y + 6),
//           const Radius.circular(15),
//         ),
//         glow,
//       );
//     }

//     // Draw bird body
//     final bodyPaint = Paint();

//     // Hit flash effect
//     if (_hitFlashIntensity > 0.5) {
//       bodyPaint.color = Colors.red;
//       _hitFlashIntensity -= 0.05;
//     } else {
//       bodyPaint.color = birdColor;
//     }

//     // Draw rounded body
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, size.x, size.y),
//         const Radius.circular(20),
//       ),
//       bodyPaint,
//     );

//     // Draw belly (lighter color)
//     final bellyPaint = Paint()..color = birdColor.withOpacity(0.7);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(5, 15, size.x - 10, size.y - 20),
//         const Radius.circular(10),
//       ),
//       bellyPaint,
//     );

//     // Draw eye
//     final eyePaint = Paint()..color = Colors.white;
//     canvas.drawCircle(
//       Offset(size.x - 12, size.y * 0.3),
//       7,
//       eyePaint,
//     );

//     // Draw pupil
//     final pupilPaint = Paint()..color = Colors.black;
//     double pupilOffset = (velocity / 500).clamp(-2, 2);
//     canvas.drawCircle(
//       Offset(size.x - 12 + pupilOffset, size.y * 0.3),
//       4,
//       pupilPaint,
//     );

//     // Draw eye highlight
//     final highlightPaint = Paint()..color = Colors.white;
//     canvas.drawCircle(
//       Offset(size.x - 14, size.y * 0.28),
//       2,
//       highlightPaint,
//     );

//     // Draw beak
//     final beakPaint = Paint()..color = Colors.orange.shade700;
//     final beakPath = Path();
//     beakPath.moveTo(size.x - 5, size.y * 0.3);
//     beakPath.lineTo(size.x + 8, size.y * 0.35);
//     beakPath.lineTo(size.x - 5, size.y * 0.4);
//     beakPath.close();
//     canvas.drawPath(beakPath, beakPaint);

//     // Draw wing
//     final wingPaint = Paint()..color = birdColor.withOpacity(0.8);
//     final wingPath = Path();
//     double wingAngle = sin(_timeAlive * 15) * 0.5;

//     if (velocity > 0) {
//       wingPath.moveTo(8, size.y * 0.5);
//       wingPath.quadraticBezierTo(
//           15 + wingAngle * 5, size.y * 0.3, 25, size.y * 0.5);
//     } else {
//       wingPath.moveTo(8, size.y * 0.5);
//       wingPath.quadraticBezierTo(
//           15 + wingAngle * 5, size.y * 0.7, 25, size.y * 0.5);
//     }
//     wingPath.lineTo(25, size.y * 0.6);
//     wingPath.lineTo(8, size.y * 0.6);
//     wingPath.close();
//     canvas.drawPath(wingPath, wingPaint);

//     // Draw cheek
//     final cheekPaint = Paint()..color = Colors.red.withOpacity(0.6);
//     canvas.drawCircle(
//       Offset(size.x - 18, size.y * 0.45),
//       3,
//       cheekPaint,
//     );

//     // Draw feathers on top
//     final featherPaint = Paint()..color = birdColor.withOpacity(0.9);
//     final featherPath = Path();
//     featherPath.moveTo(size.x * 0.3, 0);
//     featherPath.lineTo(size.x * 0.4, -8);
//     featherPath.lineTo(size.x * 0.5, 0);
//     featherPath.close();
//     canvas.drawPath(featherPath, featherPaint);

//     featherPath.reset();
//     featherPath.moveTo(size.x * 0.45, 0);
//     featherPath.lineTo(size.x * 0.55, -6);
//     featherPath.lineTo(size.x * 0.65, 0);
//     featherPath.close();
//     canvas.drawPath(featherPath, featherPaint);

//     // Draw tail feathers
//     final tailPaint = Paint()..color = birdColor.withOpacity(0.8);
//     final tailPath = Path();
//     tailPath.moveTo(0, size.y * 0.6);
//     tailPath.lineTo(-10, size.y * 0.55);
//     tailPath.lineTo(-5, size.y * 0.65);
//     tailPath.lineTo(-12, size.y * 0.7);
//     tailPath.lineTo(-3, size.y * 0.75);
//     tailPath.lineTo(0, size.y * 0.7);
//     tailPath.close();
//     canvas.drawPath(tailPath, tailPaint);
//   }

//   Color _getBirdColorForEnvironment(EnvironmentType environment) {
//     switch (environment) {
//       case EnvironmentType.sunny:
//         return const Color(0xFFFFD700); // Gold/Yellow
//       case EnvironmentType.night:
//         return const Color(0xFF4169E1); // Royal Blue
//       case EnvironmentType.sunset:
//         return const Color(0xFFFF6B35); // Orange-Red
//       case EnvironmentType.forest:
//         return const Color(0xFF228B22); // Forest Green
//       case EnvironmentType.winter:
//         return const Color(0xFF87CEEB); // Sky Blue
//     }
//   }
// }

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../game/flappy_bird_game.dart';
import '../controllers/game_config_controller.dart';
import 'pipe.dart';
import 'ground.dart';

class Bird extends RectangleComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
  // Physics
  double velocity = 0;
  double gravity = 900;
  double jumpForce = -320;
  double maxFallSpeed = 520;
  double maxRiseSpeed = -420;

  // Animation
  double _timeAlive = 0;

  // Effects
  double _hitFlashIntensity = 0;
  double _scalePulse = 0;

  // State
  bool isAlive = true;
  bool _isGameOverTriggered = false;

  // Bird type
  BirdType birdType = BirdType.blue;

  Bird()
      : super(
          size: Vector2(50, 40),
          position: Vector2(100, 300),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get selected bird type
    final config = Get.find<GameConfigController>();
    birdType = config.selectedBird.value;

    // Listen for bird changes
    _listenToBirdChanges();

    // Add hitbox
    add(RectangleHitbox(
      size: Vector2(38, 35),
      position: Vector2(6, 2.5),
    ));

    await _addShadow();
  }

  void _listenToBirdChanges() {
    // Update bird type when changed
    ever(Get.find<GameConfigController>().selectedBird, (BirdType newBird) {
      birdType = newBird;
    });
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
    if (!gameRef.isGameOver &&
        !gameRef.isCountdownActive &&
        gameRef.isUserControlEnabled &&
        isAlive) {
      velocity = min(velocity, 0) + jumpForce;
      velocity = velocity.clamp(maxRiseSpeed, maxFallSpeed).toDouble();
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

    if (gameRef.isGameOver && !isAlive) {
      return;
    }

    final step = dt.clamp(0.0, 1 / 30).toDouble();
    final animationStep = step * gameRef.animationFactor;
    _timeAlive += animationStep;

    if (gameRef.isCountdownActive) {
      velocity = 0;
      angle += (0 - angle) * min(1, step * 12);
      scale.setValues(1.0, 1.0);
      return;
    }

    final previousVelocity = velocity;
    velocity = (velocity + gravity * step)
        .clamp(maxRiseSpeed, maxFallSpeed)
        .toDouble();
    position.y += ((previousVelocity + velocity) * 0.5) * step;

    // Tilt animation
    final targetAngle = (velocity / maxFallSpeed).clamp(-0.55, 0.95);
    angle += (targetAngle - angle) * min(1, step * 12);

    // Idle bobbing
    if (velocity.abs() < 50) {
      position.y += sin(_timeAlive * 12) * 0.5;
    }

    // Scale pulse
    if (_scalePulse > 0) {
      _scalePulse -= dt * 5 * gameRef.animationFactor;
      double s = 1.0 + sin(_scalePulse * 20) * 0.1;
      scale.setValues(s, s);
    } else {
      scale.setValues(1.0, 1.0);
    }

    _checkBoundaries();
  }

  void _checkBoundaries() {
    if (!isAlive) return;

    if (position.y <= 0) {
      position.y = 0;
      velocity = max(velocity, 0);
      _triggerGameOver();
    }

    double groundY = gameRef.size.y;

    if (position.y + size.y >= groundY) {
      position.y = groundY - size.y;
      scale.setValues(1.2, 0.6);
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    if (gameRef.isReviveCountdownActive) return;
    if (!_isGameOverTriggered && isAlive && !gameRef.isGameOver) {
      _hitFlashIntensity = 1.0;
      _isGameOverTriggered = true;
      isAlive = false;
      gameRef.gameOver();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isGameOverTriggered || !isAlive || gameRef.isGameOver) return;

    if (other is Pipe || other is Ground) {
      _triggerGameOver();
    }
  }

  void revive() {
    _isGameOverTriggered = false;
    isAlive = true;
    velocity = 0;
    position = Vector2(100, 300);
    _timeAlive = 0;
    _hitFlashIntensity = 0;
    _scalePulse = 0;
    angle = 0;
    scale.setValues(1.0, 1.0);
  }

  void reset() {
    revive();
  }

  @override
  void render(Canvas canvas) {
    _renderBird(canvas);
  }

  void _renderBird(Canvas canvas) {
    // Get bird color based on bird type and environment
    // Get main bird color
    final skin = GameConfigController.skinFromType(birdType);
    Color birdColor = skin.bodyColor;
    Color wingColor = skin.wingColor;
    Color bellyColor = skin.bellyColor;
    Color beakColor = _getBeakColor(birdType);

    // Draw glow effect
    if (!gameRef.isGameOver && isAlive) {
      final glow = Paint()
        ..color = birdColor.withOpacity(0.3 + sin(_timeAlive * 10) * 0.1)
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
      bodyPaint.color = birdColor;
    }

    _drawBody(canvas, skin, bodyPaint);

    // Draw belly
    final bellyPaint = Paint()..color = bellyColor;
    _drawBelly(canvas, skin, bellyPaint);

    // Draw eye
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.x - 12, size.y * 0.3),
      7,
      eyePaint,
    );

    // Draw pupil
    final pupilPaint = Paint()..color = Colors.black;
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
    final beakPaint = Paint()..color = beakColor;
    final beakPath = Path();
    beakPath.moveTo(size.x - 5, size.y * 0.3);
    beakPath.lineTo(size.x + 8, size.y * 0.35);
    beakPath.lineTo(size.x - 5, size.y * 0.4);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    _drawWing(canvas, skin, wingColor);

    // Draw cheek
    final cheekPaint = Paint()..color = Colors.red.withOpacity(0.5);
    canvas.drawCircle(
      Offset(size.x - 18, size.y * 0.45),
      3,
      cheekPaint,
    );

    _drawHeadAccent(canvas, skin);

    // Draw tail feathers
    _drawTail(canvas, skin, wingColor);

    // Draw crown/crest for golden bird
    _drawSpecialAccent(canvas, skin);
  }

  void _drawBody(Canvas canvas, BirdSkin skin, Paint paint) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    switch (skin.shape) {
      case BirdBodyShape.circle:
        canvas.drawOval(Rect.fromLTWH(3, 0, size.y, size.y), paint);
        break;
      case BirdBodyShape.oval:
        canvas.drawOval(rect, paint);
        break;
      case BirdBodyShape.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(2, size.y * 0.86)
            ..quadraticBezierTo(size.x * 0.22, 2, size.x * 0.82, 2)
            ..lineTo(size.x, size.y * 0.52)
            ..quadraticBezierTo(size.x * 0.52, size.y, 2, size.y * 0.86)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(9)),
          paint,
        );
        break;
      case BirdBodyShape.diamond:
        canvas.drawPath(
          Path()
            ..moveTo(size.x * 0.5, 0)
            ..lineTo(size.x, size.y * 0.5)
            ..lineTo(size.x * 0.5, size.y)
            ..lineTo(0, size.y * 0.5)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.teardrop:
        canvas.drawPath(
          Path()
            ..moveTo(size.x * 0.86, size.y * 0.48)
            ..cubicTo(size.x * 0.72, -5, 8, 0, 6, size.y * 0.48)
            ..cubicTo(4, size.y * 0.95, size.x * 0.6, size.y * 1.08,
                size.x * 0.86, size.y * 0.48)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(20)),
          paint,
        );
        break;
    }

    final shine = Paint()..color = Colors.white.withOpacity(0.13);
    canvas.drawOval(Rect.fromLTWH(8, 5, size.x * 0.42, size.y * 0.28), shine);
  }

  void _drawBelly(Canvas canvas, BirdSkin skin, Paint paint) {
    switch (skin.shape) {
      case BirdBodyShape.triangle:
      case BirdBodyShape.diamond:
        canvas.drawOval(
            Rect.fromLTWH(12, 18, size.x * 0.48, size.y * 0.38), paint);
        break;
      case BirdBodyShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(8, 16, size.x - 18, size.y - 22),
            const Radius.circular(7),
          ),
          paint,
        );
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(6, 15, size.x - 14, size.y - 20),
            const Radius.circular(14),
          ),
          paint,
        );
    }
  }

  void _drawWing(Canvas canvas, BirdSkin skin, Color wingColor) {
    final wingPaint = Paint()..color = wingColor;
    final wingPath = Path();
    double wingAngle = sin(_timeAlive * 15) * 0.8;
    final wingTop = velocity > 0 ? size.y * 0.25 : size.y * 0.75;

    wingPath.moveTo(8, size.y * 0.5);
    wingPath.quadraticBezierTo(15 + wingAngle * 8, wingTop, 29, size.y * 0.48);
    wingPath.lineTo(28, size.y * 0.66);
    wingPath.quadraticBezierTo(18, size.y * 0.72, 8, size.y * 0.6);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    canvas.drawLine(
      Offset(12, size.y * 0.54),
      Offset(27, size.y * 0.58),
      Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 2,
    );
  }

  void _drawHeadAccent(Canvas canvas, BirdSkin skin) {
    final featherPaint = Paint()..color = skin.accentColor.withOpacity(0.9);
    if (skin.shape == BirdBodyShape.square || skin.type == BirdType.ninja) {
      canvas.drawRect(
          Rect.fromLTWH(size.x * 0.22, -3, size.x * 0.42, 5), featherPaint);
      return;
    }
    final featherPath = Path()
      ..moveTo(size.x * 0.3, 0)
      ..lineTo(size.x * 0.4, -8)
      ..lineTo(size.x * 0.5, 0)
      ..close();
    canvas.drawPath(featherPath, featherPaint);
    featherPath
      ..reset()
      ..moveTo(size.x * 0.45, 0)
      ..lineTo(size.x * 0.55, -6)
      ..lineTo(size.x * 0.65, 0)
      ..close();
    canvas.drawPath(featherPath, featherPaint);
  }

  void _drawTail(Canvas canvas, BirdSkin skin, Color wingColor) {
    final tailPaint = Paint()..color = wingColor;
    final tailPath = Path()
      ..moveTo(0, size.y * 0.6)
      ..lineTo(-12, size.y * 0.48)
      ..lineTo(-7, size.y * 0.62)
      ..lineTo(-16, size.y * 0.72)
      ..lineTo(-4, size.y * 0.76)
      ..lineTo(0, size.y * 0.68)
      ..close();
    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawSpecialAccent(Canvas canvas, BirdSkin skin) {
    final accentPaint = Paint()..color = skin.accentColor;
    if ([BirdType.golden, BirdType.royal].contains(skin.type)) {
      final crownPath = Path()
        ..moveTo(size.x * 0.35, -5)
        ..lineTo(size.x * 0.4, -12)
        ..lineTo(size.x * 0.45, -5)
        ..lineTo(size.x * 0.5, -12)
        ..lineTo(size.x * 0.55, -5)
        ..close();
      canvas.drawPath(crownPath, accentPaint);
    } else if ([BirdType.demon, BirdType.magma].contains(skin.type)) {
      canvas.drawPath(
        Path()
          ..moveTo(size.x * 0.28, 2)
          ..lineTo(size.x * 0.18, -10)
          ..lineTo(size.x * 0.38, -2)
          ..close(),
        accentPaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.x * 0.62, 2)
          ..lineTo(size.x * 0.75, -10)
          ..lineTo(size.x * 0.52, -2)
          ..close(),
        accentPaint,
      );
    } else if (skin.type == BirdType.angel) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.x * 0.48, -8),
          width: 24,
          height: 8,
        ),
        Paint()
          ..color = skin.accentColor.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else if (skin.type == BirdType.thunder) {
      canvas.drawPath(
        Path()
          ..moveTo(size.x * 0.45, 4)
          ..lineTo(size.x * 0.3, 19)
          ..lineTo(size.x * 0.43, 19)
          ..lineTo(size.x * 0.34, 34)
          ..lineTo(size.x * 0.6, 14)
          ..lineTo(size.x * 0.46, 14)
          ..close(),
        accentPaint,
      );
    }
  }

  Color _getBeakColor(BirdType bird) {
    return const Color(0xFFFF9800); // Orange beak for all birds
  }
}
