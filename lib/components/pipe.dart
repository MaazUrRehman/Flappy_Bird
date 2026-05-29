// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/flappy_bird_game.dart';
import '../models/environment_theme.dart';

class Pipe extends RectangleComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
  double speed = 200;
  PipeType pipeType;
  bool _scoreGiven = false;
  bool _isMoving = false;
  double _movePhase = 0;
  double _baseY = 0;

  final Color pipeColor;
  final Color rimColor;
  final Color darkColor;
  final EnvironmentTheme envTheme;

  final Paint _paint = Paint();
  final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _blurPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  final Path _path = Path();

  final List<Leaf> _leaves = [];
  final List<MossSpot> _mossSpots = [];

  double _time = 0;
  double _glowIntensity = 0;
  bool _isGlowing = false;

  Pipe({
    required Vector2 position,
    required Vector2 size,
    this.pipeType = PipeType.top,
    Color? customColor,
  })  : envTheme = EnvironmentTheme.current(),
        pipeColor = customColor ?? EnvironmentTheme.current().pipeBase,
        rimColor = EnvironmentTheme.current().pipeRim,
        darkColor = EnvironmentTheme.current().groundBottom,
        super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.transparent,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseY = position.y;

    add(RectangleHitbox(
      size: Vector2(size.x - 4, size.y),
      position: Vector2(2, 0),
    ));

    _generateDecorations();
    if (pipeType == PipeType.bonus) {
      _isGlowing = true;
    }
  }

  void _generateDecorations() {
    final random = Random(pipeType == PipeType.top ? 1 : 2);
    for (var i = 0; i < 9; i++) {
      _leaves.add(Leaf(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        size: 5 + random.nextDouble() * 11,
        angle: random.nextDouble() * pi * 2,
        color: i.isEven ? envTheme.accent : envTheme.lightColor,
      ));
    }
    for (var i = 0; i < 14; i++) {
      _mossSpots.add(MossSpot(
        x: random.nextDouble() * size.x,
        y: random.nextDouble() * size.y,
        radius: 2 + random.nextDouble() * 7,
        opacity: 0.18 + random.nextDouble() * 0.45,
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

    if (gameRef.isCountdownActive) {
      return;
    }

    position.x -= speed * dt;
    if (_isMoving) {
      position.y = _baseY + sin(_time * 2.2 + _movePhase) * 18;
    }

    if (!_scoreGiven &&
        pipeType == PipeType.bottom &&
        gameRef.bird.isAlive &&
        position.x + size.x < gameRef.bird.position.x) {
      _scoreGiven = true;
      gameRef.addScore(5);
      gameRef.incrementPipesPassed();
    }

    _glowIntensity = _isGlowing ? 0.5 + sin(_time * 8) * 0.3 : 0;

    for (final leaf in _leaves) {
      leaf.angle += sin(_time * 2 + leaf.x) * 0.02;
    }

    if (position.x + size.x < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final style = _styleForTheme();
    final body = Rect.fromLTWH(0, 0, size.x, size.y);
    final bodyRRect = RRect.fromRectAndRadius(
      body,
      Radius.circular(style.cornerRadius),
    );

    _renderShadow(canvas, bodyRRect, style);
    if (style.auraOpacity > 0 || _isGlowing) {
      _renderAura(canvas, body, style);
    }

    _paint
      ..style = PaintingStyle.fill
      ..shader = _bodyShader(body, style)
      ..maskFilter = null;
    canvas.drawRRect(bodyRRect, _paint);

    _renderSideDepth(canvas, bodyRRect, style);
    _renderThemeDetails(canvas, style);
    _renderRim(canvas, style);
    _renderSpecular(canvas, style);
  }

  _PipeStyle _styleForTheme() {
    switch (envTheme.id) {
      case 'forest':
        return _PipeStyle(
          base: const Color(0xFF6B4427),
          mid: const Color(0xFF8B5B32),
          dark: const Color(0xFF2A170D),
          rim: const Color(0xFF315822),
          accent: const Color(0xFF78D95A),
          glow: const Color(0xFFE7FF9E),
          cornerRadius: 13,
          rimHeight: 18,
        );
      case 'sunset':
        return _PipeStyle(
          base: const Color(0xFFC6783D),
          mid: const Color(0xFFE29B55),
          dark: const Color(0xFF64301D),
          rim: const Color(0xFF8B4324),
          accent: const Color(0xFFFFD36C),
          glow: const Color(0xFFFFA34D),
          cornerRadius: 10,
          rimHeight: 17,
          auraOpacity: 0.08,
        );
      case 'cyber':
        return _PipeStyle(
          base: const Color(0xFF11182F),
          mid: const Color(0xFF2B315B),
          dark: const Color(0xFF050711),
          rim: const Color(0xFF00D7FF),
          accent: const Color(0xFFFF2BD6),
          glow: const Color(0xFF6EFFF7),
          cornerRadius: 7,
          rimHeight: 16,
          auraOpacity: 0.2,
        );
      case 'arctic':
        return _PipeStyle(
          base: const Color(0xFFBFEAFF),
          mid: const Color(0xFFE9FBFF),
          dark: const Color(0xFF5CAACC),
          rim: const Color(0xFF78FFE8),
          accent: const Color(0xFFFFFFFF),
          glow: const Color(0xFFA7FFE8),
          cornerRadius: 12,
          rimHeight: 17,
          auraOpacity: 0.1,
        );
      case 'desert':
        return _PipeStyle(
          base: const Color(0xFFC8914B),
          mid: const Color(0xFFE1B067),
          dark: const Color(0xFF6E3F22),
          rim: const Color(0xFF806037),
          accent: const Color(0xFFFFD36E),
          glow: const Color(0xFFFFE1A3),
          cornerRadius: 9,
          rimHeight: 18,
        );
      case 'ocean':
        return _PipeStyle(
          base: const Color(0xFF17696E),
          mid: const Color(0xFF3AA8A4),
          dark: const Color(0xFF03202D),
          rim: const Color(0xFF19DAC9),
          accent: const Color(0xFFFF6FAE),
          glow: const Color(0xFF77F7FF),
          cornerRadius: 12,
          rimHeight: 17,
          auraOpacity: 0.12,
        );
      case 'graveyard':
        return _PipeStyle(
          base: const Color(0xFF34333A),
          mid: const Color(0xFF555365),
          dark: const Color(0xFF111116),
          rim: const Color(0xFF8D7CFF),
          accent: const Color(0xFFB9A9FF),
          glow: const Color(0xFFDED6FF),
          cornerRadius: 8,
          rimHeight: 17,
          auraOpacity: 0.16,
        );
      case 'candy':
        return _PipeStyle(
          base: const Color(0xFFFFF0A0),
          mid: const Color(0xFFFF6FB7),
          dark: const Color(0xFF8B4A2A),
          rim: const Color(0xFFFF4FB8),
          accent: const Color(0xFF7BE7FF),
          glow: const Color(0xFFFFFFFF),
          cornerRadius: 16,
          rimHeight: 18,
          auraOpacity: 0.09,
        );
      case 'jungle':
        return _PipeStyle(
          base: const Color(0xFF5A3B1F),
          mid: const Color(0xFF8A6630),
          dark: const Color(0xFF1E160B),
          rim: const Color(0xFF2E6B2F),
          accent: const Color(0xFFFFD45C),
          glow: const Color(0xFFBFFF75),
          cornerRadius: 12,
          rimHeight: 18,
        );
      case 'space':
        return _PipeStyle(
          base: const Color(0xFF202640),
          mid: const Color(0xFF49537D),
          dark: const Color(0xFF050713),
          rim: const Color(0xFF77A7FF),
          accent: const Color(0xFFFF6DF2),
          glow: const Color(0xFF9CB8FF),
          cornerRadius: 9,
          rimHeight: 16,
          auraOpacity: 0.18,
        );
      case 'volcano':
        return _PipeStyle(
          base: const Color(0xFF231511),
          mid: const Color(0xFF4A2118),
          dark: const Color(0xFF070202),
          rim: const Color(0xFFFF4A1C),
          accent: const Color(0xFFFFB13B),
          glow: const Color(0xFFFF4A1C),
          cornerRadius: 9,
          rimHeight: 17,
          auraOpacity: 0.18,
        );
      case 'sakura':
        return _PipeStyle(
          base: const Color(0xFF6D4735),
          mid: const Color(0xFF93664D),
          dark: const Color(0xFF3B2434),
          rim: const Color(0xFFFFA5C1),
          accent: const Color(0xFFFFD0DD),
          glow: const Color(0xFFFFC2A8),
          cornerRadius: 10,
          rimHeight: 17,
          auraOpacity: 0.08,
        );
      case 'steampunk':
        return _PipeStyle(
          base: const Color(0xFF9B6A35),
          mid: const Color(0xFFD49755),
          dark: const Color(0xFF2A170D),
          rim: const Color(0xFFFFB45C),
          accent: const Color(0xFFFFD08A),
          glow: const Color(0xFFFFE0B2),
          cornerRadius: 8,
          rimHeight: 17,
        );
      case 'heaven':
        return _PipeStyle(
          base: const Color(0xFFECEAF0),
          mid: const Color(0xFFFFFFFF),
          dark: const Color(0xFFB8C9DA),
          rim: const Color(0xFFFFC857),
          accent: const Color(0xFFFFE189),
          glow: const Color(0xFFFFFFFF),
          cornerRadius: 13,
          rimHeight: 18,
          auraOpacity: 0.18,
        );
      case 'nightmare':
        return _PipeStyle(
          base: const Color(0xFF21070B),
          mid: const Color(0xFF3C0710),
          dark: const Color(0xFF030101),
          rim: const Color(0xFFFF163D),
          accent: const Color(0xFFFF3157),
          glow: const Color(0xFFFF163D),
          cornerRadius: 14,
          rimHeight: 17,
          auraOpacity: 0.2,
        );
      default:
        return _PipeStyle(
          base: pipeColor,
          mid: pipeColor.lighten(0.18),
          dark: pipeColor.darken(0.28),
          rim: rimColor,
          accent: envTheme.accent,
          glow: envTheme.lightColor,
          cornerRadius: 10,
          rimHeight: 16,
        );
    }
  }

  Shader _bodyShader(Rect rect, _PipeStyle style) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        style.dark,
        style.base,
        style.mid.lighten(0.1 + sin(_time * 2.2) * 0.03),
        style.base,
        style.dark,
      ],
      stops: const [0, 0.18, 0.48, 0.78, 1],
    ).createShader(rect);
  }

  void _renderShadow(Canvas canvas, RRect body, _PipeStyle style) {
    _paint
      ..shader = null
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = Colors.black.withOpacity(0.34);
    canvas.drawRRect(body.shift(const Offset(4, 5)), _paint);
    _paint.maskFilter = null;
  }

  void _renderAura(Canvas canvas, Rect body, _PipeStyle style) {
    _blurPaint.color =
        style.glow.withOpacity(max(style.auraOpacity, _glowIntensity * 0.25));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        body.inflate(8),
        Radius.circular(style.cornerRadius + 8),
      ),
      _blurPaint,
    );
  }

  void _renderSideDepth(Canvas canvas, RRect body, _PipeStyle style) {
    _paint
      ..shader = null
      ..maskFilter = null
      ..color = Colors.black.withOpacity(0.13);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.78, 0, size.x * 0.22, size.y),
        Radius.circular(style.cornerRadius),
      ),
      _paint,
    );
  }

  void _renderThemeDetails(Canvas canvas, _PipeStyle style) {
    switch (envTheme.id) {
      case 'forest':
        _renderWood(canvas, style, dense: false);
        _renderVines(canvas, style, heavy: false);
        _renderMoss(canvas, style);
        break;
      case 'sunset':
        _renderStoneBands(canvas, style, totem: true);
        _renderDust(canvas, style);
        break;
      case 'cyber':
        _renderCyber(canvas, style);
        break;
      case 'arctic':
        _renderIce(canvas, style);
        break;
      case 'desert':
        _renderStoneBands(canvas, style, totem: false);
        _renderDust(canvas, style);
        break;
      case 'ocean':
        _renderOcean(canvas, style);
        break;
      case 'graveyard':
        _renderGraveyard(canvas, style);
        break;
      case 'candy':
        _renderCandy(canvas, style);
        break;
      case 'jungle':
        _renderWood(canvas, style, dense: true);
        _renderVines(canvas, style, heavy: true);
        _renderTempleMarks(canvas, style);
        break;
      case 'space':
        _renderSpace(canvas, style);
        break;
      case 'volcano':
        _renderVolcano(canvas, style);
        break;
      case 'sakura':
        _renderSakura(canvas, style);
        break;
      case 'steampunk':
        _renderSteampunk(canvas, style);
        break;
      case 'heaven':
        _renderHeaven(canvas, style);
        break;
      case 'nightmare':
        _renderNightmare(canvas, style);
        break;
      default:
        _renderStoneBands(canvas, style, totem: false);
    }
  }

  void _renderWood(Canvas canvas, _PipeStyle style, {required bool dense}) {
    _strokePaint
      ..shader = null
      ..strokeWidth = 2
      ..color = style.dark.withOpacity(0.34);
    for (var x = 8.0; x < size.x; x += dense ? 9 : 12) {
      _path
        ..reset()
        ..moveTo(x, 0);
      for (var y = 0.0; y <= size.y; y += 28) {
        _path.lineTo(x + sin(y * 0.04 + _time + x) * (dense ? 7 : 5), y);
      }
      canvas.drawPath(_path, _strokePaint);
    }

    _paint.color = style.dark.withOpacity(0.25);
    for (var y = 24.0; y < size.y; y += 58) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.x * 0.52, y),
          width: size.x * 0.48,
          height: 16,
        ),
        _paint,
      );
    }
  }

  void _renderVines(Canvas canvas, _PipeStyle style, {required bool heavy}) {
    _strokePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = heavy ? 4 : 3
      ..color = style.rim.withOpacity(0.85);
    for (var i = 0; i < (heavy ? 4 : 3); i++) {
      final startX = 8.0 + i * 16;
      _path
        ..reset()
        ..moveTo(startX, 0);
      for (var y = 0.0; y <= size.y; y += 24) {
        _path.lineTo(
          startX + sin(_time * 1.6 + y * 0.045 + i) * 12,
          y,
        );
      }
      canvas.drawPath(_path, _strokePaint);
    }

    for (final leaf in _leaves.take(heavy ? 8 : 5)) {
      _drawLeaf(canvas, leaf, style.rim);
    }
  }

  void _renderMoss(Canvas canvas, _PipeStyle style) {
    for (final moss in _mossSpots) {
      _paint
        ..shader = null
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
        ..color = style.accent.withOpacity(moss.opacity);
      canvas.drawCircle(Offset(moss.x, moss.y), moss.radius, _paint);
    }
    _paint.maskFilter = null;
  }

  void _renderStoneBands(
    Canvas canvas,
    _PipeStyle style, {
    required bool totem,
  }) {
    _strokePaint
      ..shader = null
      ..strokeWidth = 2
      ..color = style.dark.withOpacity(0.26);
    for (var y = 20.0; y < size.y; y += 34) {
      canvas.drawLine(
          Offset(0, y), Offset(size.x, y + sin(_time + y) * 1.2), _strokePaint);
    }

    _paint.color = style.accent.withOpacity(totem ? 0.28 : 0.18);
    for (var y = 36.0; y < size.y; y += 72) {
      if (totem) {
        _path
          ..reset()
          ..moveTo(size.x * 0.5, y)
          ..lineTo(size.x * 0.72, y + 14)
          ..lineTo(size.x * 0.5, y + 28)
          ..lineTo(size.x * 0.28, y + 14)
          ..close();
        canvas.drawPath(_path, _paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(10, y, size.x - 20, 11),
            const Radius.circular(3),
          ),
          _paint,
        );
      }
    }
  }

  void _renderDust(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var i = 0; i < 10; i++) {
      final y = (i * 37 + _time * 34) % max(1.0, size.y);
      final x = (i * 19 + sin(_time + i) * 6) % max(1.0, size.x);
      _paint.color = style.glow.withOpacity(0.16);
      canvas.drawCircle(Offset(x, y), 1.4 + (i % 3), _paint);
    }
  }

  void _renderCyber(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = 16.0; y < size.y; y += 32) {
      final pulse = 0.45 + sin(_time * 5 + y) * 0.2;
      _paint.color = style.glow.withOpacity(pulse);
      canvas.drawRect(Rect.fromLTWH(8, y, size.x - 16, 3), _paint);
      _paint.color = style.accent.withOpacity(0.52);
      canvas.drawRect(Rect.fromLTWH(size.x * 0.18, y + 10, 3, 14), _paint);
      canvas.drawRect(Rect.fromLTWH(size.x * 0.72, y + 6, 3, 18), _paint);
    }

    _strokePaint
      ..strokeWidth = 1.5
      ..color = style.rim.withOpacity(0.9);
    canvas.drawLine(
        Offset(size.x * 0.5, 0), Offset(size.x * 0.5, size.y), _strokePaint);
  }

  void _renderIce(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = 20.0; y < size.y; y += 52) {
      _strokePaint
        ..strokeWidth = 2
        ..color = style.dark.withOpacity(0.5);
      _path
        ..reset()
        ..moveTo(size.x * 0.22, y)
        ..lineTo(size.x * 0.48, y + 18)
        ..lineTo(size.x * 0.38, y + 36)
        ..lineTo(size.x * 0.74, y + 52);
      canvas.drawPath(_path, _strokePaint);
    }
    for (var i = 0; i < 12; i++) {
      final y = (i * 31 + _time * 42) % max(1.0, size.y);
      _paint.color = Colors.white.withOpacity(0.55);
      canvas.drawCircle(Offset((i * 17) % size.x, y), 1.2, _paint);
    }
  }

  void _renderOcean(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = 24.0; y < size.y; y += 46) {
      _paint.color = style.accent.withOpacity(0.6);
      canvas.drawCircle(Offset(size.x * 0.24, y), 5, _paint);
      _paint.color = style.glow.withOpacity(0.38);
      canvas.drawCircle(Offset(size.x * 0.7, y + 18), 4, _paint);
    }

    _strokePaint
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = style.rim.withOpacity(0.75);
    for (var i = 0; i < 4; i++) {
      final x = 9.0 + i * 14;
      canvas.drawLine(Offset(x, size.y),
          Offset(x + sin(_time + i) * 8, size.y - 44), _strokePaint);
    }
    _strokePaint.strokeCap = StrokeCap.butt;
  }

  void _renderGraveyard(Canvas canvas, _PipeStyle style) {
    _strokePaint
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.38);
    for (var y = 24.0; y < size.y; y += 54) {
      _path
        ..reset()
        ..moveTo(size.x * 0.2, y)
        ..lineTo(size.x * 0.6, y + 18)
        ..lineTo(size.x * 0.42, y + 35);
      canvas.drawPath(_path, _strokePaint);
    }

    _strokePaint
      ..strokeWidth = 3
      ..color = style.accent.withOpacity(0.55);
    for (var y = 32.0; y < size.y; y += 76) {
      canvas.drawArc(
          Rect.fromLTWH(8, y, size.x - 16, 18), 0, pi, false, _strokePaint);
      _drawSkull(canvas, Offset(size.x * 0.52, y + 34), style);
    }
  }

  void _renderCandy(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = -size.x; y < size.y; y += 24) {
      _strokePaint
        ..strokeWidth = 9
        ..color = style.rim.withOpacity(0.75);
      canvas.drawLine(
          Offset(-4, y), Offset(size.x + 4, y + size.x + 8), _strokePaint);
      _strokePaint.color = style.accent.withOpacity(0.75);
      canvas.drawLine(Offset(-4, y + 10), Offset(size.x + 4, y + size.x + 18),
          _strokePaint);
    }
    for (var i = 0; i < 18; i++) {
      final x = (i * 17) % size.x;
      final y = (i * 29) % size.y;
      _paint.color = [style.accent, style.glow, Colors.white, style.rim][i % 4]
          .withOpacity(0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 5, 2),
          const Radius.circular(2),
        ),
        _paint,
      );
    }
  }

  void _renderTempleMarks(Canvas canvas, _PipeStyle style) {
    _paint.color = style.accent.withOpacity(0.42);
    for (var y = 30.0; y < size.y; y += 68) {
      canvas.drawRect(Rect.fromLTWH(11, y, size.x - 22, 5), _paint);
      _drawTriangle(canvas, Offset(size.x * 0.5, y + 21), 11, _paint);
    }
  }

  void _renderSpace(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var i = 0; i < 24; i++) {
      final y = ((i * 31 + _time * (7 + i % 3)) % max(1.0, size.y)).toDouble();
      final x = ((i * 13) % max(1.0, size.x)).toDouble();
      _paint.color = Colors.white.withOpacity(0.35 + (i % 4) * 0.1);
      canvas.drawCircle(
          Offset(x, y), 0.9 + ((i % 3) * 0.35).toDouble(), _paint);
    }
    for (var y = 22.0; y < size.y; y += 58) {
      _paint.color = style.accent.withOpacity(0.55 + sin(_time * 4 + y) * 0.2);
      canvas.drawRect(Rect.fromLTWH(8, y, size.x - 16, 4), _paint);
      _paint.color = style.glow.withOpacity(0.32);
      canvas.drawCircle(Offset(size.x * 0.5, y + 18), 8, _paint);
    }
  }

  void _renderVolcano(Canvas canvas, _PipeStyle style) {
    for (var y = 20.0; y < size.y; y += 48) {
      final glow = 0.68 + sin(_time * 6 + y) * 0.2;
      _strokePaint
        ..strokeWidth = 4
        ..color = style.rim.withOpacity(glow);
      _path
        ..reset()
        ..moveTo(size.x * 0.46, y)
        ..lineTo(size.x * 0.62, y + 14)
        ..lineTo(size.x * 0.38, y + 34)
        ..lineTo(size.x * 0.58, y + 48);
      canvas.drawPath(_path, _strokePaint);
    }
    _paint.shader = null;
    for (var i = 0; i < 10; i++) {
      final y = (i * 41 - _time * 46) % max(1.0, size.y);
      _paint.color = style.accent.withOpacity(0.55);
      canvas.drawCircle(Offset((i * 23) % size.x, y), 1.8, _paint);
    }
  }

  void _renderSakura(Canvas canvas, _PipeStyle style) {
    _renderWood(canvas, style, dense: false);
    _paint.shader = null;
    for (var y = 18.0; y < size.y; y += 42) {
      _paint.color = style.rim.withOpacity(0.36);
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, 3), _paint);
    }
    for (var i = 0; i < 10; i++) {
      final y = (i * 35 + _time * 28) % max(1.0, size.y);
      final x = (i * 19 + sin(_time + i) * 8) % max(1.0, size.x);
      _paint.color = style.accent.withOpacity(0.8);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 4), _paint);
    }
  }

  void _renderSteampunk(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = 18.0; y < size.y; y += 30) {
      _paint.color = style.dark.withOpacity(0.28);
      canvas.drawRect(Rect.fromLTWH(0, y, size.x, 2), _paint);
      _paint.color = style.accent.withOpacity(0.68);
      canvas.drawCircle(Offset(size.x * 0.25, y + 8), 3, _paint);
      canvas.drawCircle(Offset(size.x * 0.75, y + 8), 3, _paint);
    }
    for (var y = 45.0; y < size.y; y += 95) {
      _drawGear(canvas, Offset(size.x * 0.5, y), 13, style);
    }
    _paint.color = Colors.white.withOpacity(0.16);
    for (var i = 0; i < 5; i++) {
      final y = (i * 70 - _time * 22) % max(1.0, size.y);
      canvas.drawCircle(Offset(size.x * 0.18, y), 9, _paint);
    }
  }

  void _renderHeaven(Canvas canvas, _PipeStyle style) {
    _strokePaint
      ..strokeWidth = 1.5
      ..color = style.dark.withOpacity(0.2);
    for (var y = 18.0; y < size.y; y += 42) {
      canvas.drawLine(Offset(8, y), Offset(size.x - 8, y + 18), _strokePaint);
    }
    _paint.shader = null;
    _paint.color = Colors.white.withOpacity(0.5);
    for (var y = 46.0; y < size.y; y += 100) {
      canvas.drawCircle(Offset(size.x * 0.28, y), 12, _paint);
      canvas.drawCircle(Offset(size.x * 0.48, y - 5), 16, _paint);
      canvas.drawCircle(Offset(size.x * 0.68, y), 12, _paint);
    }
    _paint.color = style.accent.withOpacity(0.45);
    canvas.drawRect(Rect.fromLTWH(4, 0, 4, size.y), _paint);
    canvas.drawRect(Rect.fromLTWH(size.x - 8, 0, 4, size.y), _paint);
  }

  void _renderNightmare(Canvas canvas, _PipeStyle style) {
    _paint.shader = null;
    for (var y = 16.0; y < size.y; y += 40) {
      final pulse = 0.48 + sin(_time * 5 + y) * 0.22;
      _strokePaint
        ..strokeWidth = 4
        ..color = style.rim.withOpacity(pulse);
      _path
        ..reset()
        ..moveTo(size.x * 0.5, y)
        ..cubicTo(
            size.x * 0.2, y + 12, size.x * 0.82, y + 24, size.x * 0.44, y + 40);
      canvas.drawPath(_path, _strokePaint);
    }
    _blurPaint.color = Colors.black.withOpacity(0.35);
    for (var i = 0; i < 6; i++) {
      final y = (i * 65 - _time * 16) % max(1.0, size.y);
      canvas.drawCircle(
          Offset(size.x * (i.isEven ? 0.2 : 0.8), y), 18, _blurPaint);
    }
  }

  void _renderRim(Canvas canvas, _PipeStyle style) {
    final y = pipeType == PipeType.top ? size.y - style.rimHeight : 0.0;
    final rimRect = Rect.fromLTWH(-5, y, size.x + 10, style.rimHeight);
    _paint
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          style.rim.lighten(0.16),
          style.rim,
          style.rim.darken(0.18),
        ],
      ).createShader(rimRect)
      ..maskFilter = null;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, Radius.circular(style.cornerRadius)),
      _paint,
    );

    _paint
      ..shader = null
      ..color = Colors.white.withOpacity(0.22);
    canvas.drawRect(Rect.fromLTWH(-4, y + 2, size.x + 8, 2), _paint);

    _paint.color = Colors.black.withOpacity(0.26);
    canvas.drawRect(
      Rect.fromLTWH(-4, pipeType == PipeType.top ? y + style.rimHeight - 3 : y,
          size.x + 8, 3),
      _paint,
    );
  }

  void _renderSpecular(Canvas canvas, _PipeStyle style) {
    _paint
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(5, 0, size.x * 0.18, size.y))
      ..maskFilter = null;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 6, size.x * 0.16, size.y - 12),
        const Radius.circular(6),
      ),
      _paint,
    );
  }

  void _drawLeaf(Canvas canvas, Leaf leaf, Color color) {
    final sway = sin(_time * 2 + leaf.x) * 0.35;
    final angle = leaf.angle + sway;
    _paint
      ..shader = null
      ..color = color.withOpacity(0.86);
    _path
      ..reset()
      ..moveTo(leaf.x, leaf.y)
      ..lineTo(leaf.x + cos(angle) * leaf.size, leaf.y + sin(angle) * leaf.size)
      ..lineTo(leaf.x + cos(angle + 0.9) * leaf.size * 0.72,
          leaf.y + sin(angle + 0.9) * leaf.size * 0.72)
      ..close();
    canvas.drawPath(_path, _paint);
  }

  void _drawSkull(Canvas canvas, Offset center, _PipeStyle style) {
    _paint
      ..shader = null
      ..color = style.glow.withOpacity(0.42);
    canvas.drawCircle(center, 7, _paint);
    _paint.color = style.dark.withOpacity(0.78);
    canvas.drawCircle(center + const Offset(-3, -1), 1.5, _paint);
    canvas.drawCircle(center + const Offset(3, -1), 1.5, _paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: center + const Offset(0, 5), width: 7, height: 3),
        _paint);
  }

  void _drawTriangle(Canvas canvas, Offset center, double radius, Paint paint) {
    _path
      ..reset()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy + radius)
      ..close();
    canvas.drawPath(_path, paint);
  }

  void _drawGear(
      Canvas canvas, Offset center, double radius, _PipeStyle style) {
    _strokePaint
      ..strokeWidth = 2.2
      ..color = style.accent.withOpacity(0.75);
    canvas.drawCircle(center, radius, _strokePaint);
    for (var i = 0; i < 8; i++) {
      final a = _time * 1.5 + i * pi / 4;
      canvas.drawLine(
          center, center + Offset(cos(a), sin(a)) * radius, _strokePaint);
    }
  }

  void setSpeed(double newSpeed) {
    speed = newSpeed;
  }

  void resetScoreFlag() {
    _scoreGiven = false;
  }
}

enum PipeType {
  top,
  bottom,
  bonus,
}

class _PipeStyle {
  final Color base;
  final Color mid;
  final Color dark;
  final Color rim;
  final Color accent;
  final Color glow;
  final double cornerRadius;
  final double rimHeight;
  final double auraOpacity;

  const _PipeStyle({
    required this.base,
    required this.mid,
    required this.dark,
    required this.rim,
    required this.accent,
    required this.glow,
    required this.cornerRadius,
    required this.rimHeight,
    this.auraOpacity = 0,
  });
}

extension ColorExtension on Color {
  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
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
