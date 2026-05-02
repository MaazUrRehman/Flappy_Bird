import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_config_controller.dart';

class Background extends Component with HasGameRef {
  late List<Cloud> _clouds;
  late List<Mountain> _mountains;
  late List<Tree> _trees;
  late Vector2 _sunPosition;
  double _time = 0;

  // ✅ Environment colors based on selection
  final List<List<Color>> _environmentColors = [
    [
      const Color(0xFF5BA3E6),
      const Color(0xFF87CEEB),
      const Color(0xFFB8E6FF)
    ], // sunny (default)
    [
      const Color(0xFF1A1A2E),
      const Color(0xFF2D3561),
      const Color(0xFF4A4E69)
    ], // night
    [
      const Color(0xFFFF6B35),
      const Color(0xFFFF8C42),
      const Color(0xFFFFB347)
    ], // sunset
    [
      const Color(0xFF2D5A27),
      const Color(0xFF4A7C43),
      const Color(0xFF6B9B5E)
    ], // forest
    [
      const Color(0xFFE8F4F8),
      const Color(0xFFB8D4E3),
      const Color(0xFF8FB8CE)
    ], // winter
    [
      const Color(0xFFFFD37A),
      const Color(0xFFE8A94F),
      const Color(0xFFC88735)
    ], // desert
    [
      const Color(0xFF090B1A),
      const Color(0xFF16163A),
      const Color(0xFF30265F)
    ], // space
    [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFD93D),
      const Color(0xFF4D96FF)
    ], // rainbow
  ];

  Background() {
    priority = 0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _clouds = [];
    _mountains = [];
    _trees = [];

    _createClouds();
    _createMountains();
    _createTrees();
    _sunPosition = Vector2(gameRef.size.x - 80, 70);
  }

  /// ✅ Get environment index from GameConfigController
  int _getEnvironmentIndex() {
    try {
      final config = Get.find<GameConfigController>();
      return config.selectedEnvironment.value.index;
    } catch (e) {
      return 0; // Default to sunny
    }
  }

  /// ✅ Get background colors based on selected environment
  List<Color> _getBackgroundColors() {
    final envIndex = _getEnvironmentIndex();
    return _environmentColors[
        envIndex.clamp(0, _environmentColors.length - 1).toInt()];
  }

  /// ✅ Check if we should show sun/moon based on environment
  bool _shouldShowCelestialBody() {
    final envIndex = _getEnvironmentIndex();
    // Show sun for sunny, sunset; show moon for night, winter; show subtle for forest
    return envIndex == 0 || envIndex == 1 || envIndex == 2 || envIndex == 5;
  }

  /// ✅ Check if we should show clouds based on environment
  bool _shouldShowClouds() {
    final envIndex = _getEnvironmentIndex();
    // No clouds for night and winter
    return envIndex != 1 && envIndex != 4;
  }

  void _createClouds() {
    // ✅ Only create clouds for appropriate environments
    if (!_shouldShowClouds()) return;

    final random = Random();
    // Responsive clouds: more clouds on larger screens
    int cloudCount = (gameRef.size.x / 150).clamp(6, 15).toInt();

    for (int i = 0; i < cloudCount; i++) {
      final cloud = Cloud(
        position: Vector2(
          random.nextDouble() * gameRef.size.x,
          20 + random.nextDouble() * 120,
        ),
        size: Vector2(
          80 + random.nextDouble() * 40,
          40 + random.nextDouble() * 20,
        ),
        speed: 15 + random.nextDouble() * 10,
      );
      _clouds.add(cloud);
      add(cloud);
    }
  }

  /// ✅ Get mountain colors based on environment
  List<Color> _getMountainColors() {
    final envIndex = _getEnvironmentIndex();
    switch (envIndex) {
      case 0: // sunny
        return [Colors.green.shade700, Colors.green.shade600];
      case 1: // night
        return [const Color(0xFF1A1A2E), const Color(0xFF2D3561)];
      case 2: // sunset
        return [Colors.orange.shade800, Colors.deepOrange.shade900];
      case 3: // forest
        return [Colors.green.shade800, Colors.green.shade900];
      case 4: // winter
        return [Colors.blueGrey.shade300, Colors.blueGrey.shade400];
      case 5: // desert
        return [const Color(0xFFC88735), const Color(0xFFA86C22)];
      case 6: // space
        return [const Color(0xFF15152F), const Color(0xFF242452)];
      case 7: // rainbow
        return [const Color(0xFF6BCB77), const Color(0xFF4D96FF)];
      default:
        return [Colors.green.shade700, Colors.green.shade600];
    }
  }

  void _createMountains() {
    final random = Random();

    // Responsive mountains count based on screen width
    int mountainCount;
    double screenWidth = gameRef.size.x;

    if (screenWidth < 600) {
      // Mobile
      mountainCount = 4;
    } else if (screenWidth < 900) {
      // Tablet
      mountainCount = 7;
    } else {
      // Desktop / Large screen
      mountainCount = 10;
    }

    // Ground height (65px)
    const groundHeight = 65.0;
    final mountainBottomY = gameRef.size.y - groundHeight;

    // ✅ Get mountain colors based on environment
    final mountainColors = _getMountainColors();

    for (int i = 0; i < mountainCount; i++) {
      final h = 60 + random.nextDouble() * 70;
      final w = 80 + random.nextDouble() * 100;

      final mountain = Mountain(
        position: Vector2(
          random.nextDouble() * gameRef.size.x * 1.5,
          mountainBottomY - h + 5, // GROUND SE ATTACHED
        ),
        width: w,
        height: h,
        color: mountainColors[random.nextInt(mountainColors.length)],
        speed: 20 + random.nextDouble() * 10,
      );
      _mountains.add(mountain);
      add(mountain);
    }
  }

  void _createTrees() {
    final random = Random();

    // Responsive trees count based on screen width
    int treeCount;
    double screenWidth = gameRef.size.x;

    if (screenWidth < 600) {
      // Mobile
      treeCount = 12;
    } else if (screenWidth < 900) {
      // Tablet
      treeCount = 20;
    } else {
      // Desktop / Large screen
      treeCount = 30;
    }

    // Ground height (65px)
    const groundHeight = 65.0;
    final treeBottomY = gameRef.size.y - groundHeight;

    for (int i = 0; i < treeCount; i++) {
      final h = 25 + random.nextDouble() * 25;
      final tree = Tree(
        position: Vector2(
          random.nextDouble() * gameRef.size.x,
          treeBottomY - h + 5, // GROUND SE ATTACHED
        ),
        speed: 45 + random.nextDouble() * 25,
        height: h,
      );
      _trees.add(tree);
      add(tree);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    _sunPosition.x = gameRef.size.x - 80 + sin(_time * 0.3) * 5;
    _sunPosition.y = 70 + cos(_time * 0.5) * 3;

    for (final cloud in _clouds) {
      cloud.updatePosition(dt, gameRef.size.x);
    }
    for (final mountain in _mountains) {
      mountain.updatePosition(dt, gameRef.size.x);
    }
    for (final tree in _trees) {
      tree.updatePosition(dt, gameRef.size.x);
    }
  }

  @override
  void render(Canvas canvas) {
    // ✅ Use dynamic background colors based on selected environment
    final bgColors = _getBackgroundColors();
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: bgColors,
      ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      gradientPaint,
    );

    // ✅ Only show celestial body (sun/moon) for appropriate environments
    if (_shouldShowCelestialBody()) {
      final envIndex = _getEnvironmentIndex();
      final isNight = envIndex == 1;
      final celestialColor =
          isNight ? const Color(0xFFE8E8E8) : const Color(0xFFFFD700);
      final glowColor = isNight
          ? Colors.white.withOpacity(0.2)
          : Colors.yellow.withOpacity(0.2);

      final glowPaint = Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(Offset(_sunPosition.x, _sunPosition.y), 60, glowPaint);

      final sunPaint = Paint()..color = celestialColor;
      canvas.drawCircle(Offset(_sunPosition.x, _sunPosition.y), 32, sunPaint);

      // Only show sun rays for sunny and sunset
      if (!isNight) {
        final rayPaint = Paint()..color = Colors.yellow.withOpacity(0.4);
        for (int i = 0; i < 12; i++) {
          double angle = _time * 2 + i * (pi * 2 / 12);
          double x = _sunPosition.x + cos(angle) * 45;
          double y = _sunPosition.y + sin(angle) * 45;
          canvas.drawLine(
            Offset(_sunPosition.x, _sunPosition.y),
            Offset(x, y),
            rayPaint..strokeWidth = 3,
          );
        }
      }
    }
  }
}

// Cloud, Mountain, Tree classes remain SAME as before
class Cloud extends PositionComponent {
  final double speed;

  Cloud({required Vector2 position, required Vector2 size, required this.speed})
      : super(position: position, size: size);

  void updatePosition(double dt, double screenWidth) {
    position.x -= speed * dt;
    if (position.x < -size.x) {
      position.x = screenWidth + Random().nextDouble() * 200;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.y / 2.5, paint);
    canvas.drawCircle(
        Offset(size.x / 2 + size.x * 0.35, size.y / 2.5), size.y / 3, paint);
    canvas.drawCircle(
        Offset(size.x / 2 - size.x * 0.25, size.y / 3), size.y / 3.5, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.15, size.y * 0.3, size.x * 0.7, size.y * 0.5),
        Radius.circular(size.y / 2),
      ),
      paint,
    );
  }
}

class Mountain extends PositionComponent {
  @override
  final double width;
  @override
  final double height;
  final Color color;
  final double speed;

  Mountain({
    required Vector2 position,
    required this.width,
    required this.height,
    required this.color,
    required this.speed,
  }) : super(position: position);

  void updatePosition(double dt, double screenWidth) {
    position.x -= speed * dt;
    if (position.x < -width) {
      position.x = screenWidth + Random().nextDouble() * 100;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    Path path = Path();
    path.moveTo(0, height);
    path.lineTo(width / 2, 0);
    path.lineTo(width, height);
    path.close();
    canvas.drawPath(path, paint);

    final snowPaint = Paint()..color = Colors.white.withOpacity(0.4);
    Path snowPath = Path();
    snowPath.moveTo(width * 0.4, height * 0.4);
    snowPath.lineTo(width / 2, height * 0.12);
    snowPath.lineTo(width * 0.6, height * 0.4);
    snowPath.close();
    canvas.drawPath(snowPath, snowPaint);
  }
}

class Tree extends PositionComponent {
  final double speed;
  @override
  final double height;

  Tree({
    required Vector2 position,
    required this.speed,
    required this.height,
  }) : super(position: position, size: Vector2(10, height));

  void updatePosition(double dt, double screenWidth) {
    position.x -= speed * dt;
    if (position.x < -size.x) {
      position.x = screenWidth + Random().nextDouble() * 50;
    }
  }

  @override
  void render(Canvas canvas) {
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    final foliagePaint = Paint()..color = const Color(0xFF2E7D32);

    canvas.drawRect(Rect.fromLTWH(2, size.y - 14, 5, 14), trunkPaint);

    Path foliage = Path();
    foliage.moveTo(-2, size.y - 14);
    foliage.lineTo(5, size.y - 35);
    foliage.lineTo(12, size.y - 14);
    foliage.close();
    canvas.drawPath(foliage, foliagePaint);

    Path foliage2 = Path();
    foliage2.moveTo(-4, size.y - 22);
    foliage2.lineTo(5, size.y - 42);
    foliage2.lineTo(14, size.y - 22);
    foliage2.close();
    canvas.drawPath(foliage2, foliagePaint..color = const Color(0xFF1B5E20));
  }
}
