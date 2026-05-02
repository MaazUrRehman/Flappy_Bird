import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/flappy_bird_game.dart';
import 'bird.dart';

class Pipe extends RectangleComponent with CollisionCallbacks, HasGameRef<FlappyBirdGame> {

  double speed = 200;
  PipeType pipeType;
  bool _scoreGiven = false;  // ✅ Track if score already given for this pipe
  bool _isMoving = false;
  double _movePhase = 0;
  double _baseY = 0;

  // Visual components
  late RectangleComponent _pipeBody;
  late RectangleComponent _pipeRim;
  late RectangleComponent _pipeShadow;

  // Gradient paints
  late Paint _bodyGradient;
  late Paint _rimGradient;
  late Paint _shadowPaint;

  // Animation properties
  double _time = 0;
  double _glowIntensity = 0;
  bool _isGlowing = false;

  // Decorative elements
  final List<Leaf> _leaves = [];
  final List<MossSpot> _mossSpots = [];

  // Pipe details
  final Color pipeColor;
  final Color rimColor;
  final Color darkColor;

  Pipe({
    required Vector2 position,
    required Vector2 size,
    this.pipeType = PipeType.top,
    Color? customColor,
  }) :
        pipeColor = customColor ?? const Color(0xFF2E7D32),
        rimColor = const Color(0xFF1B5E20),
        darkColor = const Color(0xFF0D3B0F),
        super(
        position: position,
        size: size,
        paint: Paint(),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup visual layers
    _baseY = position.y;
    _setupVisualLayers();

    // Setup gradients
    _setupGradients();

    // Add collision hitbox (slightly smaller for better gameplay)
    final hitbox = RectangleHitbox(
      size: Vector2(size.x - 4, size.y),
      position: Vector2(2, 0),
    );
    add(hitbox);

    // Generate decorative elements
    _generateDecorations();

    // Add special effects based on pipe type
    if (pipeType == PipeType.bonus) {
      _isGlowing = true;
    }
  }

  void _setupVisualLayers() {
    // Pipe body (main)
    _pipeBody = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint(),
    );

    // Pipe rim (top/bottom edge)
    double rimHeight = 15;
    double rimY = pipeType == PipeType.top ? size.y - rimHeight : 0;

    _pipeRim = RectangleComponent(
      size: Vector2(size.x + 10, rimHeight),
      position: Vector2(-5, rimY),
      paint: Paint(),
    );

    // Shadow for depth
    _pipeShadow = RectangleComponent(
      size: Vector2(size.x, size.y),
      position: Vector2(3, 3),
      paint: Paint()..color = Colors.black.withOpacity(0.3),
    );

    add(_pipeShadow);
    add(_pipeBody);
    add(_pipeRim);

    // Move shadow to back
    _pipeShadow.priority = -1;
  }

  void _setupGradients() {
    // Body gradient (cylindrical effect)
    _bodyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          pipeColor,
          pipeColor,
          pipeColor.lighten(0.2),
          pipeColor,
          pipeColor.darken(0.15),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Rim gradient
    _rimGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          rimColor.lighten(0.1),
          rimColor,
          rimColor.darken(0.1),
        ],
      ).createShader(Rect.fromLTWH(-5, 0, size.x + 10, 15));

    // Shadow paint
    _shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  }

  void _generateDecorations() {
    final random = Random(pipeType == PipeType.top ? 1 : 2);

    // Generate leaves/vines
    for (int i = 0; i < 4; i++) {
      _leaves.add(Leaf(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        size: 5 + random.nextDouble() * 8,
        angle: random.nextDouble() * pi * 2,
        color: const Color(0xFF4CAF50),
      ));
    }

    // Generate moss spots
    for (int i = 0; i < 8; i++) {
      _mossSpots.add(MossSpot(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        radius: 3 + random.nextDouble() * 6,
        opacity: 0.3 + random.nextDouble() * 0.4,
      ));
    }
  }

  void setGlowing(bool glowing) {
    _isGlowing = glowing;
  }

  void setMovement({required bool enabled, double phase = 0}) {
    _isMoving = enabled;
    _movePhase = phase;
    _baseY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // Move pipe
    position.x -= speed * dt;
    if (_isMoving) {
      position.y = _baseY + sin(_time * 2.2 + _movePhase) * 18;
    }

    // ✅ FIXED: Score logic - Sirf bottom pipe pe aur sirf ek baar
    if (!_scoreGiven &&
        pipeType == PipeType.bottom &&
        gameRef.bird != null &&
        gameRef.bird.isAlive) {

      if (position.x + size.x < gameRef.bird.position.x) {
        _scoreGiven = true;
        // +5 score for passing pipe
        gameRef.addScore(5);
        gameRef.incrementPipesPassed();
        print("✅ Pipe passed! +5 points. Total: ${gameRef.score}");
      }
    }

    // Update glow animation
    if (_isGlowing) {
      _glowIntensity = 0.5 + sin(_time * 8) * 0.3;
    } else {
      _glowIntensity = 0;
    }

    // Animate leaves (gentle sway)
    for (var leaf in _leaves) {
      leaf.angle += sin(_time * 2 + leaf.x) * 0.02;
    }

    // Remove when offscreen
    if (position.x + size.x < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Update gradients for animation
    _updateGradients();

    // Draw shadow
    _renderShadow(canvas);

    // Draw pipe body
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _bodyGradient,
    );

    // Draw pipe texture (lines for brick/pipe effect)
    _renderPipeTexture(canvas);

    // Draw moss spots
    _renderMossSpots(canvas);

    // Draw leaves/vines
    _renderLeaves(canvas);

    // Draw pipe rim
    _renderPipeRim(canvas);

    // Draw glow effect
    if (_isGlowing) {
      _renderGlowEffect(canvas);
    }

    // Draw highlight (light reflection)
    _renderHighlight(canvas);

    // ✅ Debug: Show score boundary (optional - remove in production)
    if (pipeType == PipeType.bottom && _scoreGiven == false) {
      final debugPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        debugPaint,
      );
    }
  }

  void _updateGradients() {
    // Update body gradient with slight shift for animated texture
    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        pipeColor,
        pipeColor,
        pipeColor.lighten(0.2 + sin(_time * 3) * 0.05),
        pipeColor,
        pipeColor.darken(0.15),
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    _bodyGradient.shader = shader;
  }

  void _renderShadow(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, size.x, size.y),
        const Radius.circular(5),
      ),
      _shadowPaint,
    );
  }

  void _renderPipeTexture(Canvas canvas) {
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 2;

    // Horizontal bands (pipe segments)
    for (double y = 20; y < size.y; y += 25) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        linePaint,
      );
    }

    // Vertical line (pipe seam)
    canvas.drawLine(
      Offset(size.x / 2, 0),
      Offset(size.x / 2, size.y),
      linePaint,
    );

    // Bolt/rivet details
    final boltPaint = Paint()..color = Colors.black.withOpacity(0.25);
    for (double y = 15; y < size.y; y += 25) {
      canvas.drawCircle(Offset(size.x / 4, y), 3, boltPaint);
      canvas.drawCircle(Offset(size.x * 3 / 4, y), 3, boltPaint);
    }
  }

  void _renderMossSpots(Canvas canvas) {
    for (var moss in _mossSpots) {
      final paint = Paint()
        ..color = const Color(0xFF558B2F).withOpacity(moss.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(moss.x, moss.y),
        moss.radius,
        paint,
      );
    }
  }

  void _renderLeaves(Canvas canvas) {
    for (var leaf in _leaves) {
      final paint = Paint()..color = leaf.color;

      final path = Path();
      final leafX = leaf.x;
      final leafY = leaf.y;
      final leafSize = leaf.size;
      final angle = leaf.angle;

      path.moveTo(leafX, leafY);
      path.lineTo(
        leafX + cos(angle) * leafSize,
        leafY + sin(angle) * leafSize,
      );
      path.lineTo(
        leafX + cos(angle + 0.8) * leafSize * 0.7,
        leafY + sin(angle + 0.8) * leafSize * 0.7,
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  void _renderPipeRim(Canvas canvas) {
    double rimY = pipeType == PipeType.top ? size.y - 15 : 0;

    // Update rim gradient
    final rimShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        rimColor.lighten(0.1),
        rimColor,
        rimColor.darken(0.1),
      ],
    ).createShader(Rect.fromLTWH(-5, rimY, size.x + 10, 15));

    _rimGradient.shader = rimShader;

    // Draw rim
    canvas.drawRect(
      Rect.fromLTWH(-5, rimY, size.x + 10, 15),
      _rimGradient,
    );

    // Rim highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2);

    canvas.drawRect(
      Rect.fromLTWH(-5, rimY, size.x + 10, 2),
      highlightPaint,
    );

    // Rim shadow
    if (pipeType == PipeType.top) {
      canvas.drawRect(
        Rect.fromLTWH(-5, rimY + 13, size.x + 10, 2),
        Paint()..color = Colors.black.withOpacity(0.3),
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(-5, rimY - 2, size.x + 10, 2),
        Paint()..color = Colors.black.withOpacity(0.3),
      );
    }
  }

  void _renderGlowEffect(Canvas canvas) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.3 * _glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20),
        const Radius.circular(20),
      ),
      glowPaint,
    );
  }

  void _renderHighlight(Canvas canvas) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15);

    canvas.drawRect(
      Rect.fromLTWH(5, 5, size.x * 0.15, size.y - 10),
      highlightPaint,
    );
  }

  void setSpeed(double newSpeed) {
    speed = newSpeed;
  }

  // Reset score flag for new pipe
  void resetScoreFlag() {
    _scoreGiven = false;
  }
}

enum PipeType {
  top,
  bottom,
  bonus,
}

// Helper extension for color manipulation
extension ColorExtension on Color {
  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class Leaf {
  double x;
  double y;
  double size;
  double angle;
  Color color;

  Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.color,
  });
}

class MossSpot {
  double x;
  double y;
  double radius;
  double opacity;

  MossSpot({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}
