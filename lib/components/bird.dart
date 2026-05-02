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

    if (gameRef.isGameOver && !isAlive) {
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
    if (!isAlive) return;

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
    print("🐦 Reviving bird...");
    
    _isGameOverTriggered = false;
    isAlive = true;
    velocity = 0;
    position = Vector2(100, 300);
    _timeAlive = 0;
    _hitFlashIntensity = 0;
    _scalePulse = 0;
    angle = 0;
    scale.setValues(1.0, 1.0);
    
    print("✅ Bird revived and ready to fly!");
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
    final config = Get.find<GameConfigController>();
    final env = config.selectedEnvironment.value;
    
    // Get main bird color
    Color birdColor = _getBirdColor(birdType, env);
    Color wingColor = _getWingColor(birdType, env);
    Color bellyColor = _getBellyColor(birdType, env);
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

    // Draw rounded body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(20),
      ),
      bodyPaint,
    );

    // Draw belly
    final bellyPaint = Paint()..color = bellyColor;
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

    // Draw wing with flapping animation
    final wingPaint = Paint()..color = wingColor;
    final wingPath = Path();
    double wingAngle = sin(_timeAlive * 15) * 0.8;

    if (velocity > 0) {
      // Falling - wings up
      wingPath.moveTo(8, size.y * 0.5);
      wingPath.quadraticBezierTo(
          15 + wingAngle * 8, size.y * 0.25, 28, size.y * 0.45);
    } else {
      // Flapping - wings down
      wingPath.moveTo(8, size.y * 0.5);
      wingPath.quadraticBezierTo(
          15 + wingAngle * 8, size.y * 0.75, 28, size.y * 0.55);
    }
    wingPath.lineTo(28, size.y * 0.65);
    wingPath.lineTo(8, size.y * 0.6);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    // Draw cheek
    final cheekPaint = Paint()..color = Colors.red.withOpacity(0.5);
    canvas.drawCircle(
      Offset(size.x - 18, size.y * 0.45),
      3,
      cheekPaint,
    );

    // Draw feathers on top
    final featherPaint = Paint()..color = birdColor.withOpacity(0.8);
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
    final tailPaint = Paint()..color = wingColor;
    final tailPath = Path();
    tailPath.moveTo(0, size.y * 0.6);
    tailPath.lineTo(-12, size.y * 0.5);
    tailPath.lineTo(-8, size.y * 0.6);
    tailPath.lineTo(-14, size.y * 0.7);
    tailPath.lineTo(-5, size.y * 0.75);
    tailPath.lineTo(0, size.y * 0.7);
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);
    
    // Draw crown/crest for golden bird
    if (birdType == BirdType.golden) {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path();
      crownPath.moveTo(size.x * 0.35, -5);
      crownPath.lineTo(size.x * 0.4, -12);
      crownPath.lineTo(size.x * 0.45, -5);
      crownPath.lineTo(size.x * 0.5, -12);
      crownPath.lineTo(size.x * 0.55, -5);
      crownPath.close();
      canvas.drawPath(crownPath, crownPaint);
    }
  }
  
  Color _getBirdColor(BirdType bird, EnvironmentType environment) {
    // First priority: Bird type
    switch (bird) {
      case BirdType.blue:
        return const Color(0xFF4A90E2);
      case BirdType.red:
        return const Color(0xFFE74C3C);
      case BirdType.yellow:
        return const Color(0xFFF1C40F);
      case BirdType.green:
        return const Color(0xFF2ECC71);
      case BirdType.purple:
        return const Color(0xFF8E44AD);
      case BirdType.orange:
        return const Color(0xFFE67E22);
      case BirdType.pink:
        return const Color(0xFFE91E63);
      case BirdType.golden:
        return const Color(0xFFFFD700);
    }
  }
  
  Color _getWingColor(BirdType bird, EnvironmentType environment) {
    switch (bird) {
      case BirdType.blue:
        return const Color(0xFF2C6FB7);
      case BirdType.red:
        return const Color(0xFFC0392B);
      case BirdType.yellow:
        return const Color(0xFFD4AC0D);
      case BirdType.green:
        return const Color(0xFF27AE60);
      case BirdType.purple:
        return const Color(0xFF6C3483);
      case BirdType.orange:
        return const Color(0xFFD35400);
      case BirdType.pink:
        return const Color(0xFFC2185B);
      case BirdType.golden:
        return const Color(0xFFF39C12);
    }
  }
  
  Color _getBellyColor(BirdType bird, EnvironmentType environment) {
    switch (bird) {
      case BirdType.blue:
        return const Color(0xFF85C1E9);
      case BirdType.red:
        return const Color(0xFFF1948A);
      case BirdType.yellow:
        return const Color(0xFFF9E79F);
      case BirdType.green:
        return const Color(0xFF82E0AA);
      case BirdType.purple:
        return const Color(0xFFD2B4DE);
      case BirdType.orange:
        return const Color(0xFFF5B041);
      case BirdType.pink:
        return const Color(0xFFF8BBD0);
      case BirdType.golden:
        return const Color(0xFFF7DC6F);
    }
  }
  
  Color _getBeakColor(BirdType bird) {
    return const Color(0xFFFF9800); // Orange beak for all birds
  }
}
