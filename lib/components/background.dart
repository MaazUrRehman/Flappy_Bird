import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/environment_theme.dart';

class Background extends Component with HasGameRef {
  final List<_AmbientParticle> _particles = [];
  final Random _random = Random(21);
  double _time = 0;

  Background() {
    priority = 0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _seedParticles();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _seedParticles();
  }

  void _seedParticles() {
    _particles.clear();
    final count = (gameRef.size.x / 12).clamp(28, 95).toInt();
    for (var i = 0; i < count; i++) {
      _particles.add(
        _AmbientParticle(
          x: _random.nextDouble() * max(1, gameRef.size.x),
          y: _random.nextDouble() * max(1, gameRef.size.y),
          radius: 0.8 + _random.nextDouble() * 2.8,
          speed: 12 + _random.nextDouble() * 42,
          phase: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _time += dt;
    final theme = EnvironmentTheme.current();
    final weatherBoost = _weatherBoost(theme.id);
    for (final particle in _particles) {
      particle.x -= particle.speed * weatherBoost * dt;
      particle.y += sin(_time * 1.4 + particle.phase) * dt * 10;
      if (_fallsDown(theme.id)) {
        particle.y += particle.speed * 0.8 * dt;
      }
      if (particle.x < -24 || particle.y > gameRef.size.y + 24) {
        particle.x = gameRef.size.x + _random.nextDouble() * 80;
        particle.y = _random.nextDouble() * gameRef.size.y * 0.82;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final theme = EnvironmentTheme.current();
    final width = gameRef.size.x;
    final height = gameRef.size.y;
    final rect = Rect.fromLTWH(0, 0, width, height);

    _drawSky(canvas, rect, theme);
    _drawCelestialAndLighting(canvas, width, height, theme);
    _drawFarLayer(canvas, width, height, theme);
    _drawMidLayer(canvas, width, height, theme);
    _drawAtmosphere(canvas, width, height, theme);
    _drawParticles(canvas, width, height, theme);
    _drawForeground(canvas, width, height, theme);
    _drawVignette(canvas, rect, theme);
  }

  double _environmentBaseY(double height) => height;

  void _drawSky(Canvas canvas, Rect rect, EnvironmentTheme theme) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: theme.skyColors,
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    if (theme.id == 'space') {
      final starPaint = Paint()..color = Colors.white.withOpacity(0.85);
      for (var i = 0; i < 90; i++) {
        final x = (i * 47 + _time * (i % 3 + 0.2)) % rect.width;
        final y = (i * 29) % (rect.height * 0.75);
        final r = 0.6 + (i % 4) * 0.35;
        canvas.drawCircle(Offset(x, y), r, starPaint);
      }
    }
  }

  void _drawCelestialAndLighting(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    final x = width * 0.78 + sin(_time * 0.18) * 12;
    final y = height * 0.14 + cos(_time * 0.22) * 8;
    final isDark = [
      'cyber',
      'space',
      'graveyard',
      'volcano',
      'nightmare',
      'ocean',
    ].contains(theme.id);

    final glow = Paint()
      ..color = theme.lightColor.withOpacity(isDark ? 0.22 : 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42);
    canvas.drawCircle(Offset(x, y), isDark ? 62 : 82, glow);

    if (theme.id == 'arctic') {
      _drawAurora(canvas, width, height, theme);
    } else if (theme.id == 'space') {
      _drawPlanet(canvas, Offset(x, y), theme);
    } else if (theme.id == 'ocean') {
      _drawWaterRays(canvas, width, height, theme);
    } else {
      canvas.drawCircle(
        Offset(x, y),
        isDark ? 26 : 34,
        Paint()..color = isDark ? const Color(0xFFE6E3FF) : theme.lightColor,
      );
    }

    final rayPaint = Paint()
      ..color = theme.lightColor.withOpacity(isDark ? 0.05 : 0.11)
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    for (var i = 0; i < 5; i++) {
      final startX = x - 80 + i * 36 + sin(_time + i) * 10;
      canvas.drawLine(
        Offset(startX, y + 20),
        Offset(startX - width * 0.35, height),
        rayPaint,
      );
    }
  }

  void _drawFarLayer(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    switch (theme.id) {
      case 'cyber':
        _drawSkyline(canvas, width, height, theme, far: true);
        break;
      case 'ocean':
        _drawRuins(canvas, width, height, theme, far: true);
        break;
      case 'space':
        _drawAsteroids(canvas, width, height, theme, speed: 8, far: true);
        break;
      case 'heaven':
        _drawFloatingIslands(canvas, width, height, theme, far: true);
        break;
      default:
        _drawMountains(canvas, width, height, theme, 0.62, theme.farColor);
        break;
    }
  }

  void _drawMidLayer(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    switch (theme.id) {
      case 'forest':
      case 'jungle':
        _drawTreeWall(canvas, width, height, theme,
            dense: theme.id == 'jungle');
        break;
      case 'sunset':
      case 'desert':
        _drawCanyon(canvas, width, height, theme);
        break;
      case 'cyber':
        _drawSkyline(canvas, width, height, theme, far: false);
        break;
      case 'arctic':
        _drawIcePeaks(canvas, width, height, theme);
        break;
      case 'graveyard':
        _drawCastleAndGraves(canvas, width, height, theme);
        break;
      case 'candy':
        _drawCandyHills(canvas, width, height, theme);
        break;
      case 'space':
        _drawAsteroids(canvas, width, height, theme, speed: 18, far: false);
        break;
      case 'volcano':
        _drawVolcanoes(canvas, width, height, theme);
        break;
      case 'sakura':
        _drawPagodas(canvas, width, height, theme);
        break;
      case 'steampunk':
        _drawFactory(canvas, width, height, theme);
        break;
      case 'heaven':
        _drawFloatingIslands(canvas, width, height, theme, far: false);
        break;
      case 'nightmare':
        _drawNightmareSpikes(canvas, width, height, theme);
        break;
      case 'ocean':
        _drawRuins(canvas, width, height, theme, far: false);
        break;
      default:
        _drawMountains(canvas, width, height, theme, 0.72, theme.midColor);
    }
  }

  void _drawForeground(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    final baseY = _environmentBaseY(height);
    final paint = Paint()..color = theme.foregroundColor.withOpacity(0.92);

    for (var i = 0; i < 14; i++) {
      final x = ((i * 67 - _time * 54) % (width + 140)) - 70;
      final scale = 0.65 + (i % 4) * 0.18;
      switch (theme.id) {
        case 'forest':
        case 'jungle':
          _drawPlant(canvas, Offset(x, baseY), paint, scale);
          break;
        case 'cyber':
          _drawNeonPole(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'arctic':
          _drawCrystal(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'desert':
          _drawCactus(canvas, Offset(x, baseY), paint, scale);
          break;
        case 'ocean':
          _drawCoral(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'graveyard':
          _drawTombstone(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'candy':
          _drawLollipop(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'space':
          _drawSpaceDebris(canvas, Offset(x, baseY - 40), theme, scale);
          break;
        case 'volcano':
          _drawLavaRock(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'sakura':
          _drawLantern(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'steampunk':
          _drawGear(canvas, Offset(x, baseY - 16), theme, 12 * scale);
          break;
        case 'heaven':
          _drawCloudPuff(canvas, Offset(x, baseY), theme, scale);
          break;
        case 'nightmare':
          _drawChainSpike(canvas, Offset(x, baseY), theme, scale);
          break;
        default:
          _drawRock(canvas, Offset(x, baseY), paint, scale);
      }
    }
  }

  void _drawParticles(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    final paint = Paint()
      ..color = theme.particleColor.withOpacity(_particleOpacity(theme.id))
      ..strokeWidth = theme.id == 'cyber' || theme.id == 'arctic' ? 1.3 : 1;

    for (final p in _particles) {
      final offset = Offset(p.x, p.y);
      if (theme.id == 'cyber' || theme.id == 'arctic' || theme.id == 'jungle') {
        canvas.drawLine(offset, Offset(p.x - 8, p.y + 18), paint);
      } else if (theme.id == 'sakura') {
        canvas.drawOval(
          Rect.fromCenter(
              center: offset, width: p.radius * 3, height: p.radius),
          paint,
        );
      } else if (theme.id == 'volcano' || theme.id == 'nightmare') {
        canvas.drawCircle(offset, p.radius * 1.5,
            paint..color = theme.accent.withOpacity(0.38));
      } else {
        canvas.drawCircle(offset, p.radius, paint);
      }
    }
  }

  void _drawAtmosphere(
    Canvas canvas,
    double width,
    double height,
    EnvironmentTheme theme,
  ) {
    if (['forest', 'jungle', 'graveyard', 'arctic', 'ocean']
        .contains(theme.id)) {
      for (var i = 0; i < 4; i++) {
        final y = height * (0.32 + i * 0.13);
        final x = ((_time * (12 + i * 3)) % (width + 180)) - 180;
        final fogPaint = Paint()
          ..color = theme.lightColor
              .withOpacity(theme.id == 'graveyard' ? 0.08 : 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
        canvas.drawOval(Rect.fromLTWH(x, y, width * 0.8, 48), fogPaint);
        canvas.drawOval(
            Rect.fromLTWH(x + width * 0.45, y + 18, width * 0.7, 36), fogPaint);
      }
    }

    if (theme.id == 'cyber') {
      final rainPaint = Paint()
        ..color = theme.particleColor.withOpacity(0.2)
        ..strokeWidth = 1;
      for (var i = 0; i < 70; i++) {
        final x = (i * 37 - _time * 420) % width;
        final y = (i * 23 + _time * 760) % height;
        canvas.drawLine(Offset(x, y), Offset(x - 9, y + 28), rainPaint);
      }
    }

    if (theme.id == 'volcano' || theme.id == 'desert') {
      final haze = Paint()
        ..color = theme.lightColor.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      for (var i = 0; i < 5; i++) {
        final y = height * (0.42 + i * 0.08) + sin(_time * 2 + i) * 5;
        canvas.drawRect(Rect.fromLTWH(0, y, width, 12), haze);
      }
    }
  }

  void _drawVignette(Canvas canvas, Rect rect, EnvironmentTheme theme) {
    final darkThemes = [
      'cyber',
      'space',
      'graveyard',
      'volcano',
      'nightmare',
      'ocean'
    ];
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(darkThemes.contains(theme.id) ? 0.42 : 0.22),
        ],
        stops: const [0.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawMountains(Canvas canvas, double w, double h, EnvironmentTheme t,
      double base, Color color) {
    final y = h * base;
    final paint = Paint()..color = color.withOpacity(0.72);
    for (var i = -1; i < 7; i++) {
      final x = i * w / 5 - (_time * 8 % (w / 5));
      final peak = y - 70 - (i % 3) * 38;
      final path = Path()
        ..moveTo(x - 90, h)
        ..lineTo(x + 70, peak)
        ..lineTo(x + 230, h)
        ..close();
      canvas.drawPath(path, paint);
      if (t.id == 'arctic') {
        canvas.drawPath(
          Path()
            ..moveTo(x + 35, peak + 28)
            ..lineTo(x + 70, peak)
            ..lineTo(x + 105, peak + 32)
            ..close(),
          Paint()..color = Colors.white.withOpacity(0.72),
        );
      }
    }
  }

  void _drawTreeWall(Canvas canvas, double w, double h, EnvironmentTheme t,
      {required bool dense}) {
    final paint = Paint()..color = t.midColor.withOpacity(0.86);
    final trunkPaint = Paint()..color = t.foregroundColor.withOpacity(0.74);
    final base = _environmentBaseY(h);
    final count = dense ? 18 : 14;
    for (var i = 0; i < count; i++) {
      final x = ((i * 58 - _time * 22) % (w + 120)) - 60;
      final treeH = (120 + (i % 5) * 24).toDouble();
      canvas.drawRect(
          Rect.fromLTWH(x + 16, base - treeH, 12, treeH), trunkPaint);
      for (var j = 0; j < 3; j++) {
        canvas.drawCircle(
            Offset(x + 22 + j * 13, base - treeH + j * 16), 36 - j * 3, paint);
      }
    }
    if (dense) {
      final waterfall = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withOpacity(0.55), t.accent.withOpacity(0.15)],
        ).createShader(Rect.fromLTWH(w * 0.66, h * 0.28, 42, h * 0.5));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.66, h * 0.28, 42, h * 0.5),
            const Radius.circular(18)),
        waterfall,
      );
    }
  }

  void _drawSkyline(Canvas canvas, double w, double h, EnvironmentTheme t,
      {required bool far}) {
    final paint = Paint()
      ..color = (far ? t.farColor : t.midColor).withOpacity(far ? 0.58 : 0.88);
    final base = _environmentBaseY(h);
    final width = far ? 44.0 : 62.0;
    for (var i = -1; i < 11; i++) {
      final x = ((i * width * 1.4 - _time * (far ? 12 : 28)) % (w + 120)) - 60;
      final bh = ((far ? 130 : 210) + (i % 4) * 42).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, base - bh, width, bh), const Radius.circular(4)),
        paint,
      );
      final neon = Paint()
        ..color = (i.isEven ? t.accent : t.particleColor)
            .withOpacity(far ? 0.28 : 0.72);
      for (var y = base - bh + 18; y < base - 18; y += 28) {
        canvas.drawRect(Rect.fromLTWH(x + 8, y, width - 16, 3), neon);
      }
    }
  }

  void _drawCanyon(Canvas canvas, double w, double h, EnvironmentTheme t) {
    final paint = Paint()..color = t.midColor.withOpacity(0.78);
    final base = _environmentBaseY(h);
    for (var i = -1; i < 8; i++) {
      final x = ((i * 90 - _time * 18) % (w + 180)) - 90;
      final pillarH = (90 + (i % 4) * 36).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, base - pillarH, 54, pillarH),
            const Radius.circular(14)),
        paint,
      );
      canvas.drawOval(
          Rect.fromLTWH(x - 16, base - pillarH - 14, 86, 28), paint);
    }
  }

  void _drawIcePeaks(Canvas canvas, double w, double h, EnvironmentTheme t) =>
      _drawMountains(canvas, w, h, t, 0.72, t.midColor);

  void _drawCastleAndGraves(
      Canvas canvas, double w, double h, EnvironmentTheme t) {
    final base = _environmentBaseY(h);
    final p = Paint()..color = t.midColor.withOpacity(0.86);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.62, base - 210, 130, 210),
            const Radius.circular(8)),
        p);
    for (var i = 0; i < 3; i++) {
      final x = w * 0.6 + i * 48;
      canvas.drawRect(
          Rect.fromLTWH(x, base - 260 + i * 18, 34, 260 - i * 18), p);
      canvas.drawPath(
          Path()
            ..moveTo(x - 6, base - 260 + i * 18)
            ..lineTo(x + 17, base - 302 + i * 18)
            ..lineTo(x + 40, base - 260 + i * 18)
            ..close(),
          p);
    }
  }

  void _drawCandyHills(Canvas canvas, double w, double h, EnvironmentTheme t) {
    final base = _environmentBaseY(h);
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = (i.isEven ? t.midColor : t.accent).withOpacity(0.55);
      canvas.drawCircle(
          Offset(i * w / 4 + sin(_time + i) * 8, base + 26), 95 + i * 8, paint);
    }
  }

  void _drawAsteroids(Canvas canvas, double w, double h, EnvironmentTheme t,
      {required double speed, required bool far}) {
    final paint = Paint()
      ..color = (far ? t.farColor : t.midColor).withOpacity(far ? 0.55 : 0.85);
    for (var i = 0; i < (far ? 8 : 6); i++) {
      final x = (i * 93 - _time * speed) % (w + 110);
      final y = h * (0.18 + (i % 5) * 0.12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(x, y),
                width: 32 + i % 4 * 12,
                height: 20 + i % 3 * 10),
            const Radius.circular(16)),
        paint,
      );
    }
  }

  void _drawRuins(Canvas canvas, double w, double h, EnvironmentTheme t,
      {required bool far}) {
    final base = _environmentBaseY(h);
    final paint = Paint()
      ..color = (far ? t.farColor : t.midColor).withOpacity(far ? 0.5 : 0.78);
    for (var i = 0; i < 7; i++) {
      final x = ((i * 86 - _time * (far ? 8 : 18)) % (w + 150)) - 60;
      final columnH = ((far ? 90 : 150) + (i % 3) * 28).toDouble();
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, base - columnH, 28, columnH),
              const Radius.circular(8)),
          paint);
      canvas.drawRect(Rect.fromLTWH(x - 12, base - columnH, 52, 10), paint);
    }
  }

  void _drawVolcanoes(Canvas canvas, double w, double h, EnvironmentTheme t) {
    _drawMountains(canvas, w, h, t, 0.72, t.midColor);
    final lava = Paint()..color = t.accent.withOpacity(0.85);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.48, h * 0.42)
          ..lineTo(w * 0.52, h * 0.42)
          ..lineTo(w * 0.5, _environmentBaseY(h))
          ..close(),
        lava);
  }

  void _drawPagodas(Canvas canvas, double w, double h, EnvironmentTheme t) {
    final base = _environmentBaseY(h);
    final paint = Paint()..color = t.midColor.withOpacity(0.8);
    for (var i = 0; i < 3; i++) {
      final x = w * (0.2 + i * 0.25) - (_time * 8 % 80);
      for (var j = 0; j < 4; j++) {
        final y = base - 60 - j * 32;
        canvas.drawRect(Rect.fromLTWH(x + j * 5, y, 56 - j * 10, 22), paint);
        canvas.drawPath(
            Path()
              ..moveTo(x - 8 + j * 5, y)
              ..lineTo(x + 28, y - 14)
              ..lineTo(x + 64 - j * 5, y)
              ..close(),
            paint);
      }
    }
  }

  void _drawFactory(Canvas canvas, double w, double h, EnvironmentTheme t) {
    _drawSkyline(canvas, w, h, t, far: false);
    final smoke = Paint()
      ..color = Colors.white.withOpacity(0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (var i = 0; i < 8; i++) {
      canvas.drawCircle(
          Offset((i * 81 + sin(_time + i) * 10) % w, h * 0.26 + (i % 3) * 20),
          24,
          smoke);
    }
  }

  void _drawFloatingIslands(
      Canvas canvas, double w, double h, EnvironmentTheme t,
      {required bool far}) {
    final paint = Paint()
      ..color = (far ? t.farColor : t.midColor).withOpacity(far ? 0.5 : 0.88);
    for (var i = 0; i < 6; i++) {
      final x = ((i * 120 - _time * (far ? 7 : 15)) % (w + 160)) - 80;
      final y = h * (0.34 + (i % 3) * 0.11) + sin(_time + i) * 6;
      canvas.drawOval(Rect.fromLTWH(x, y, 110, 34), paint);
      canvas.drawPath(
          Path()
            ..moveTo(x + 26, y + 24)
            ..lineTo(x + 54, y + 88)
            ..lineTo(x + 84, y + 24)
            ..close(),
          paint);
    }
  }

  void _drawNightmareSpikes(
      Canvas canvas, double w, double h, EnvironmentTheme t) {
    final p = Paint()..color = t.midColor.withOpacity(0.9);
    final base = _environmentBaseY(h);
    for (var i = 0; i < 12; i++) {
      final x = ((i * 55 - _time * 20) % (w + 100)) - 50;
      canvas.drawPath(
          Path()
            ..moveTo(x, base)
            ..lineTo(x + 26, base - 150 - (i % 4) * 28)
            ..lineTo(x + 52, base)
            ..close(),
          p);
    }
  }

  void _drawAurora(Canvas canvas, double w, double h, EnvironmentTheme t) {
    final paint = Paint()
      ..shader = LinearGradient(colors: [
        Colors.transparent,
        t.accent.withOpacity(0.3),
        Colors.transparent
      ]).createShader(Rect.fromLTWH(0, 0, w, h * 0.45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final path = Path()..moveTo(0, h * 0.2);
    for (var x = 0.0; x <= w; x += 24) {
      path.lineTo(x, h * 0.22 + sin(x * 0.02 + _time) * 38);
    }
    path.lineTo(w, h * 0.48);
    path.lineTo(0, h * 0.42);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawWaterRays(Canvas canvas, double w, double h, EnvironmentTheme t) {
    final paint = Paint()
      ..color = t.lightColor.withOpacity(0.1)
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(Offset(w * (0.2 + i * 0.16), 0),
          Offset(w * (0.05 + i * 0.18), h), paint);
    }
  }

  void _drawPlanet(Canvas canvas, Offset center, EnvironmentTheme t) {
    canvas.drawCircle(center, 42, Paint()..color = t.midColor);
    canvas.drawOval(
        Rect.fromCenter(center: center, width: 120, height: 20),
        Paint()
          ..color = t.accent.withOpacity(0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }

  void _drawPlant(Canvas canvas, Offset p, Paint paint, double s) {
    canvas.drawRect(Rect.fromLTWH(p.dx, p.dy - 38 * s, 7 * s, 38 * s), paint);
    canvas.drawCircle(Offset(p.dx - 10 * s, p.dy - 28 * s), 15 * s, paint);
    canvas.drawCircle(Offset(p.dx + 12 * s, p.dy - 42 * s), 18 * s, paint);
  }

  void _drawNeonPole(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawRect(Rect.fromLTWH(p.dx, p.dy - 70 * s, 8 * s, 70 * s),
        Paint()..color = t.foregroundColor);
    canvas.drawRect(Rect.fromLTWH(p.dx - 12 * s, p.dy - 66 * s, 34 * s, 14 * s),
        Paint()..color = t.accent.withOpacity(0.8));
  }

  void _drawCrystal(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx + 12 * s, p.dy - 54 * s)
          ..lineTo(p.dx + 25 * s, p.dy)
          ..close(),
        Paint()..color = t.accent.withOpacity(0.75));
  }

  void _drawCactus(Canvas canvas, Offset p, Paint paint, double s) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx, p.dy - 58 * s, 14 * s, 58 * s),
            Radius.circular(8 * s)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx - 14 * s, p.dy - 42 * s, 12 * s, 30 * s),
            Radius.circular(7 * s)),
        paint);
  }

  void _drawCoral(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    final paint = Paint()
      ..color = t.accent.withOpacity(0.8)
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p, Offset(p.dx, p.dy - 44 * s), paint);
    canvas.drawLine(Offset(p.dx, p.dy - 24 * s),
        Offset(p.dx + 18 * s, p.dy - 38 * s), paint);
    canvas.drawLine(Offset(p.dx, p.dy - 30 * s),
        Offset(p.dx - 16 * s, p.dy - 48 * s), paint);
  }

  void _drawTombstone(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx, p.dy - 45 * s, 32 * s, 45 * s),
            Radius.circular(14 * s)),
        Paint()..color = t.midColor);
  }

  void _drawLollipop(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawRect(Rect.fromLTWH(p.dx + 9 * s, p.dy - 46 * s, 3 * s, 46 * s),
        Paint()..color = Colors.white.withOpacity(0.8));
    canvas.drawCircle(Offset(p.dx + 10 * s, p.dy - 52 * s), 16 * s,
        Paint()..color = t.accent);
  }

  void _drawSpaceDebris(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx, p.dy, 36 * s, 18 * s), Radius.circular(8 * s)),
        Paint()..color = t.midColor);
  }

  void _drawLavaRock(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawCircle(Offset(p.dx, p.dy - 12 * s), 18 * s,
        Paint()..color = t.foregroundColor);
    canvas.drawCircle(Offset(p.dx + 3 * s, p.dy - 16 * s), 6 * s,
        Paint()..color = t.accent.withOpacity(0.8));
  }

  void _drawLantern(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawRect(Rect.fromLTWH(p.dx, p.dy - 55 * s, 4 * s, 55 * s),
        Paint()..color = t.foregroundColor);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx - 10 * s, p.dy - 54 * s, 24 * s, 22 * s),
            Radius.circular(8 * s)),
        Paint()..color = t.lightColor.withOpacity(0.78));
  }

  void _drawGear(Canvas canvas, Offset p, EnvironmentTheme t, double r) {
    final paint = Paint()
      ..color = t.accent.withOpacity(0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(p, r, paint);
    for (var i = 0; i < 8; i++) {
      final a = _time + i * pi / 4;
      canvas.drawLine(p, Offset(p.dx + cos(a) * r, p.dy + sin(a) * r), paint);
    }
  }

  void _drawCloudPuff(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    final paint = Paint()..color = Colors.white.withOpacity(0.86);
    canvas.drawCircle(Offset(p.dx, p.dy - 14 * s), 18 * s, paint);
    canvas.drawCircle(Offset(p.dx + 20 * s, p.dy - 18 * s), 22 * s, paint);
    canvas.drawCircle(Offset(p.dx + 43 * s, p.dy - 12 * s), 17 * s, paint);
  }

  void _drawChainSpike(Canvas canvas, Offset p, EnvironmentTheme t, double s) {
    canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx + 12 * s, p.dy - 62 * s)
          ..lineTo(p.dx + 24 * s, p.dy)
          ..close(),
        Paint()..color = t.accent.withOpacity(0.5));
  }

  void _drawRock(Canvas canvas, Offset p, Paint paint, double s) {
    canvas.drawOval(Rect.fromLTWH(p.dx, p.dy - 22 * s, 42 * s, 22 * s), paint);
  }

  double _weatherBoost(String id) {
    if (id == 'cyber' || id == 'arctic' || id == 'desert') return 2.2;
    if (id == 'volcano' || id == 'nightmare') return 1.7;
    return 1;
  }

  bool _fallsDown(String id) =>
      ['cyber', 'arctic', 'jungle', 'sakura'].contains(id);

  double _particleOpacity(String id) {
    if (id == 'space' || id == 'candy' || id == 'heaven') return 0.75;
    if (id == 'cyber' || id == 'volcano' || id == 'nightmare') return 0.5;
    return 0.36;
  }
}

class _AmbientParticle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double phase;

  _AmbientParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}
