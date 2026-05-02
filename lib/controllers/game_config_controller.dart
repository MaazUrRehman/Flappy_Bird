import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state_controller.dart';

// ✅ Define enums BEFORE using them
enum BirdType { blue, red, yellow, green, purple, orange, pink, golden }

enum EnvironmentType { sunny, night, sunset, forest, winter, desert, space, rainbow }

class GameConfigController extends GetxController {
  static const String _selectedBirdKey = 'selected_bird';
  static const String _selectedEnvironmentKey = 'selected_environment';

  final Rx<BirdType> selectedBird = BirdType.blue.obs;
  final Rx<EnvironmentType> selectedEnvironment = EnvironmentType.sunny.obs;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSelections();
    _syncFromGameState();
  }

  void _loadSelections() {
    final birdIndex = _prefs.getInt(_selectedBirdKey) ?? 0;
    final envIndex = _prefs.getInt(_selectedEnvironmentKey) ?? 0;

    selectedBird.value =
        BirdType.values[birdIndex.clamp(0, BirdType.values.length - 1).toInt()];
    selectedEnvironment.value = EnvironmentType
        .values[envIndex.clamp(0, EnvironmentType.values.length - 1).toInt()];
  }

  void _syncFromGameState() {
    if (!Get.isRegistered<GameStateController>()) return;

    final gameState = GameStateController.instance;
    _applyBirdId(gameState.selectedBird.value);
    _applyEnvironmentId(gameState.selectedEnvironment.value);
    ever<String>(gameState.selectedBird, _applyBirdId);
    ever<String>(gameState.selectedEnvironment, _applyEnvironmentId);
  }

  void _applyBirdId(String birdId) {
    selectedBird.value = birdFromId(birdId);
    _prefs.setInt(_selectedBirdKey, selectedBird.value.index);
  }

  void _applyEnvironmentId(String envId) {
    selectedEnvironment.value = environmentFromId(envId);
    _prefs.setInt(_selectedEnvironmentKey, selectedEnvironment.value.index);
  }

  /// Set selected bird and persist
  void setBird(BirdType bird) {
    selectedBird.value = bird;
    _prefs.setInt(_selectedBirdKey, bird.index);
  }

  /// Set selected environment and persist
  void setEnvironment(EnvironmentType env) {
    selectedEnvironment.value = env;
    _prefs.setInt(_selectedEnvironmentKey, env.index);
  }

  /// Get bird asset path based on selection
  String getBirdAssetPath() {
    switch (selectedBird.value) {
      case BirdType.blue:
        return 'blue_bird.png';
      case BirdType.red:
        return 'red_bird.png';
      case BirdType.yellow:
        return 'yellow_bird.png';
      case BirdType.green:
        return 'green_bird.png';
      case BirdType.purple:
      case BirdType.orange:
      case BirdType.pink:
      case BirdType.golden:
        return 'white_bird.png';
    }
  }

  static BirdType birdFromId(String id) {
    switch (id) {
      case 'red':
        return BirdType.red;
      case 'yellow':
      case 'default':
        return BirdType.yellow;
      case 'green':
        return BirdType.green;
      case 'purple':
        return BirdType.purple;
      case 'orange':
        return BirdType.orange;
      case 'pink':
        return BirdType.pink;
      case 'gold':
      case 'golden':
        return BirdType.golden;
      case 'blue':
      default:
        return BirdType.blue;
    }
  }

  static EnvironmentType environmentFromId(String id) {
    switch (id) {
      case 'night':
        return EnvironmentType.night;
      case 'sunset':
        return EnvironmentType.sunset;
      case 'forest':
        return EnvironmentType.forest;
      case 'snow':
      case 'winter':
        return EnvironmentType.winter;
      case 'desert':
        return EnvironmentType.desert;
      case 'space':
        return EnvironmentType.space;
      case 'rainbow':
        return EnvironmentType.rainbow;
      case 'default':
      case 'sunny':
      default:
        return EnvironmentType.sunny;
    }
  }

  /// Get gradient for environment
  Gradient getEnvironmentGradient() {
    switch (selectedEnvironment.value) {
      case EnvironmentType.sunny:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky Blue
            Color(0xFFE0F6FF), // Light Cyan
            Color(0xFFFFE4B5), // Warm Peach at bottom
          ],
          stops: [0.0, 0.6, 1.0],
        );

      case EnvironmentType.night:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B0C10), // Dark Blue/Black
            Color(0xFF1A1A2E), // Deep Navy
            Color(0xFF16213E), // Dark Blue
          ],
        );

      case EnvironmentType.sunset:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6B35), // Orange
            Color(0xFFF7931E), // Orange-Yellow
            Color(0xFFFFD700), // Gold
            Color(0xFFFFECB3), // Light Yellow
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );

      case EnvironmentType.forest:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D5A27), // Deep Forest Green
            Color(0xFF4A7C3F), // Medium Green
            Color(0xFF6B8E5E), // Light Green
            Color(0xFF8BA888), // Pale Green
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        );

      case EnvironmentType.winter:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB0D4E3), // Ice Blue
            Color(0xFFD4EAF7), // Light Ice
            Color(0xFFF0F8FF), // Almost White
            Color(0xFFE0E8F0), // Winter Sky
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      case EnvironmentType.desert:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD37A),
            Color(0xFFE8A94F),
            Color(0xFFC88735),
          ],
        );
      case EnvironmentType.space:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF090B1A),
            Color(0xFF16163A),
            Color(0xFF30265F),
          ],
        );
      case EnvironmentType.rainbow:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFFD93D),
            Color(0xFF6BCB77),
            Color(0xFF4D96FF),
          ],
        );
    }
  }

  /// Check if bird is owned (for shop system)
  bool isBirdOwned(BirdType bird) {
    // TODO: Implement shop system
    return true;
  }

  /// Check if environment is owned
  bool isEnvironmentOwned(EnvironmentType env) {
    // TODO: Implement shop system
    return true;
  }
}
