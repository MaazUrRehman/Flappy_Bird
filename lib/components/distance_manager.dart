// ignore_for_file: unnecessary_null_comparison

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DistanceManager extends TextComponent {

  double distanceCovered = 0;
  double birdSpeed = 100;

  // Visual enhancements
  late Paint _backgroundPaint;
  late Paint _glowPaint;

  // Animation properties
  double _pulseIntensity = 0;
  double _time = 0;

  // Distance milestones
  int _lastMilestone = 0;
  final List<int> _milestones = [100, 250, 500, 1000, 2500, 5000];

  // Unit system
  DistanceUnit _unit = DistanceUnit.meters;

  // Best distance tracking
  double _bestDistance = 0;

  // Medal system
  MedalType _currentMedal = MedalType.none;

  // Color scheme based on distance
  Color _currentColor = Colors.white;

  // Background panel
  late RectangleComponent _backgroundPanel;
  bool _showPanel = true;

  DistanceManager({
    bool showBackground = true,
    DistanceUnit unit = DistanceUnit.meters,
  }) : super() {
    _showPanel = showBackground;
    _unit = unit;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup position (top left corner)
    position = Vector2(15, 90);

    // Setup initial text
    text = _getFormattedDistance();

    // Setup text style
    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
    );

    // Setup visual effects
    _setupPaints();

    // Load best distance
    await _loadBestDistance();

    // Add background panel if enabled
    if (_showPanel) {
      await _addBackgroundPanel();
    }
  }

  void _setupPaints() {
    // Background panel gradient
    _backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 180, 40));

    // Shadow for text

    // Glow effect
    _glowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  }

  Future<void> _addBackgroundPanel() async {
    _backgroundPanel = RectangleComponent(
      size: Vector2(190, 45),
      position: Vector2(-10, -12),
      paint: _backgroundPaint,
    );

    // Add border to panel

    _backgroundPanel.paint = _backgroundPaint;
    add(_backgroundPanel);
  }

  Future<void> _loadBestDistance() async {
    // In production, load from SharedPreferences
    _bestDistance = 0;
  }

  Future<void> _saveBestDistance() async {
    // In production, save to SharedPreferences
    if (distanceCovered > _bestDistance) {
      _bestDistance = distanceCovered;
    }
  }

  String _getFormattedDistance() {
    double displayDistance = distanceCovered;
    String unitText = '';

    switch (_unit) {
      case DistanceUnit.meters:
        unitText = 'm';
        break;
      case DistanceUnit.kilometers:
        displayDistance = distanceCovered / 1000;
        unitText = 'km';
        break;
      case DistanceUnit.feet:
        displayDistance = distanceCovered * 3.28084;
        unitText = 'ft';
        break;
    }

    // Add medal emoji if earned
    String medalEmoji = _getMedalEmoji();
    String medalSpace = medalEmoji.isEmpty ? '' : ' ';

    return '📏 DISTANCE$medalSpace$medalEmoji: ${displayDistance.toStringAsFixed(displayDistance > 1000 ? 0 : 1)} $unitText';
  }

  String _getMedalEmoji() {
    switch (_currentMedal) {
      case MedalType.bronze:
        return '🥉';
      case MedalType.silver:
        return '🥈';
      case MedalType.gold:
        return '🥇';
      case MedalType.platinum:
        return '💎';
      default:
        return '';
    }
  }

  void _updateMedal() {
    if (distanceCovered >= 5000) {
      _currentMedal = MedalType.platinum;
    } else if (distanceCovered >= 2500) {
      _currentMedal = MedalType.gold;
    } else if (distanceCovered >= 1000) {
      _currentMedal = MedalType.silver;
    } else if (distanceCovered >= 500) {
      _currentMedal = MedalType.bronze;
    } else {
      _currentMedal = MedalType.none;
    }
  }

  void _checkMilestone() {
    for (var milestone in _milestones) {
      if (distanceCovered >= milestone && _lastMilestone < milestone) {
        _lastMilestone = milestone;
        _onMilestoneReached(milestone);
      }
    }
  }

  void _onMilestoneReached(int milestone) {
    // Trigger milestone effect
    _pulseIntensity = 1.0;

    // Change color based on milestone
    if (milestone >= 1000) {
      _currentColor = const Color(0xFFFFD700); // Gold
    } else if (milestone >= 500) {
      _currentColor = const Color(0xFFC0C0C0); // Silver
    } else if (milestone >= 100) {
      _currentColor = const Color(0xFFCD7F32); // Bronze
    }

  }

  void _updateTextStyle() {
    // Dynamic color based on distance
    Color textColor;
    if (distanceCovered >= 1000) {
      textColor = const Color(0xFFFFD700); // Gold
    } else if (distanceCovered >= 500) {
      textColor = const Color(0xFFC0C0C0); // Silver
    } else if (distanceCovered >= 100) {
      textColor = const Color(0xFFCD7F32); // Bronze
    } else {
      textColor = Colors.white;
    }

    // Add pulse effect for milestones
    double fontSize = 22 + _pulseIntensity * 4;

    textRenderer = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
          Shadow(
            color: textColor.withOpacity(0.3),
            offset: Offset.zero,
            blurRadius: _pulseIntensity * 8,
          ),
        ],
      ),
    );
  }

  void setUnit(DistanceUnit unit) {
    _unit = unit;
    text = _getFormattedDistance();
  }

  void toggleUnit() {
    switch (_unit) {
      case DistanceUnit.meters:
        _unit = DistanceUnit.kilometers;
        break;
      case DistanceUnit.kilometers:
        _unit = DistanceUnit.feet;
        break;
      case DistanceUnit.feet:
        _unit = DistanceUnit.meters;
        break;
    }
    text = _getFormattedDistance();
  }

  void setBirdSpeed(double speed) {
    birdSpeed = speed;
  }

  double getDistanceInMeters() => distanceCovered;

  double getBestDistance() => _bestDistance;

  MedalType getCurrentMedal() => _currentMedal;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // Update distance
    distanceCovered += birdSpeed * dt;

    // Update best distance
    if (distanceCovered > _bestDistance) {
      _bestDistance = distanceCovered;
      _saveBestDistance();
    }

    // Update medal
    _updateMedal();

    // Check milestones
    _checkMilestone();

    // Update text
    text = _getFormattedDistance();

    // Pulse animation decay
    if (_pulseIntensity > 0) {
      _pulseIntensity -= dt * 3;
      if (_pulseIntensity < 0) _pulseIntensity = 0;
    }

    // Update text style with animation
    _updateTextStyle();

    // Gentle floating animation for panel
    if (_backgroundPanel != null) {
      _backgroundPanel.position.y = -12 + sin(_time * 2) * 1;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw glow effect behind text
    if (_pulseIntensity > 0) {
      _glowPaint.color = _currentColor.withOpacity(0.3 * _pulseIntensity);
      canvas.drawRect(
        Rect.fromLTWH(position.x - 10, position.y - 15, 200, 45),
        _glowPaint,
      );
    }

    super.render(canvas);
  }

  void reset() {
    distanceCovered = 0;
    _lastMilestone = 0;
    _pulseIntensity = 0;
    _currentMedal = MedalType.none;
    _currentColor = Colors.white;
    text = _getFormattedDistance();
    _updateTextStyle();
  }

  // New feature: Get distance rank
  String getDistanceRank() {
    if (distanceCovered >= 5000) return "LEGENDARY";
    if (distanceCovered >= 2500) return "MASTER";
    if (distanceCovered >= 1000) return "EXPERT";
    if (distanceCovered >= 500) return "ADVANCED";
    if (distanceCovered >= 100) return "INTERMEDIATE";
    return "BEGINNER";
  }

  // New feature: Get next milestone
  int getNextMilestone() {
    for (var milestone in _milestones) {
      if (distanceCovered < milestone) {
        return milestone;
      }
    }
    return _milestones.last;
  }

  // New feature: Progress to next milestone (0-1)
  double getProgressToNextMilestone() {
    int next = getNextMilestone();
    int previous = _getPreviousMilestone();
    return (distanceCovered - previous) / (next - previous);
  }

  int _getPreviousMilestone() {
    int previous = 0;
    for (var milestone in _milestones) {
      if (distanceCovered >= milestone) {
        previous = milestone;
      } else {
        break;
      }
    }
    return previous;
  }
}

enum DistanceUnit {
  meters,
  kilometers,
  feet,
}

enum MedalType {
  none,
  bronze,
  silver,
  gold,
  platinum,
}

// Extension for medal colors
extension MedalColor on MedalType {
  Color getColor() {
    switch (this) {
      case MedalType.bronze:
        return const Color(0xFFCD7F32);
      case MedalType.silver:
        return const Color(0xFFC0C0C0);
      case MedalType.gold:
        return const Color(0xFFFFD700);
      case MedalType.platinum:
        return const Color(0xFFE5E4E2);
      default:
        return Colors.white;
    }
  }
}