import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state_controller.dart';

// ✅ Define enums BEFORE using them
enum BirdBodyShape {
  rounded,
  circle,
  oval,
  triangle,
  square,
  diamond,
  teardrop
}

enum BirdType {
  blue,
  red,
  yellow,
  green,
  purple,
  orange,
  pink,
  golden,
  ember,
  frost,
  forest,
  cyber,
  shadow,
  candy,
  royal,
  ninja,
  crystal,
  samurai,
  angel,
  demon,
  aqua,
  desert,
  thunder,
  ghost,
  magma,
}

class BirdSkin {
  final String id;
  final String name;
  final BirdType type;
  final BirdBodyShape shape;
  final Color bodyColor;
  final Color wingColor;
  final Color bellyColor;
  final Color accentColor;
  final int price;

  const BirdSkin({
    required this.id,
    required this.name,
    required this.type,
    required this.shape,
    required this.bodyColor,
    required this.wingColor,
    required this.bellyColor,
    required this.accentColor,
    required this.price,
  });
}

const List<BirdSkin> premiumBirdSkins = [
  BirdSkin(
      id: 'default',
      name: 'Classic Chick',
      type: BirdType.yellow,
      shape: BirdBodyShape.rounded,
      bodyColor: Color(0xFFF1C40F),
      wingColor: Color(0xFFD4AC0D),
      bellyColor: Color(0xFFF9E79F),
      accentColor: Color(0xFFFF9800),
      price: 0),
  BirdSkin(
      id: 'blue',
      name: 'Sky Round',
      type: BirdType.blue,
      shape: BirdBodyShape.circle,
      bodyColor: Color(0xFF4A90E2),
      wingColor: Color(0xFF2C6FB7),
      bellyColor: Color(0xFF85C1E9),
      accentColor: Color(0xFFFF9800),
      price: 0),
  BirdSkin(
      id: 'red',
      name: 'Scarlet Dash',
      type: BirdType.red,
      shape: BirdBodyShape.triangle,
      bodyColor: Color(0xFFE74C3C),
      wingColor: Color(0xFFC0392B),
      bellyColor: Color(0xFFF1948A),
      accentColor: Color(0xFFFFB347),
      price: 0),
  BirdSkin(
      id: 'green',
      name: 'Leaf Oval',
      type: BirdType.green,
      shape: BirdBodyShape.oval,
      bodyColor: Color(0xFF2ECC71),
      wingColor: Color(0xFF27AE60),
      bellyColor: Color(0xFF82E0AA),
      accentColor: Color(0xFFFFD54F),
      price: 120),
  BirdSkin(
      id: 'purple',
      name: 'Violet Box',
      type: BirdType.purple,
      shape: BirdBodyShape.square,
      bodyColor: Color(0xFF8E44AD),
      wingColor: Color(0xFF6C3483),
      bellyColor: Color(0xFFD2B4DE),
      accentColor: Color(0xFFFFC107),
      price: 180),
  BirdSkin(
      id: 'orange',
      name: 'Amber Oval',
      type: BirdType.orange,
      shape: BirdBodyShape.oval,
      bodyColor: Color(0xFFE67E22),
      wingColor: Color(0xFFD35400),
      bellyColor: Color(0xFFF5B041),
      accentColor: Color(0xFFFFD180),
      price: 240),
  BirdSkin(
      id: 'pink',
      name: 'Rose Puff',
      type: BirdType.pink,
      shape: BirdBodyShape.circle,
      bodyColor: Color(0xFFE91E63),
      wingColor: Color(0xFFC2185B),
      bellyColor: Color(0xFFF8BBD0),
      accentColor: Color(0xFFFFE082),
      price: 320),
  BirdSkin(
      id: 'gold',
      name: 'Golden Crown',
      type: BirdType.golden,
      shape: BirdBodyShape.rounded,
      bodyColor: Color(0xFFFFD700),
      wingColor: Color(0xFFF39C12),
      bellyColor: Color(0xFFF7DC6F),
      accentColor: Color(0xFFFFFFFF),
      price: 500),
  BirdSkin(
      id: 'ember',
      name: 'Ember Fang',
      type: BirdType.ember,
      shape: BirdBodyShape.triangle,
      bodyColor: Color(0xFFFF4A1C),
      wingColor: Color(0xFF9C1F12),
      bellyColor: Color(0xFFFFAB70),
      accentColor: Color(0xFFFFE082),
      price: 650),
  BirdSkin(
      id: 'frost',
      name: 'Frost Drop',
      type: BirdType.frost,
      shape: BirdBodyShape.teardrop,
      bodyColor: Color(0xFFBDEFFF),
      wingColor: Color(0xFF58AFCB),
      bellyColor: Color(0xFFE8FBFF),
      accentColor: Color(0xFF6DFFFF),
      price: 800),
  BirdSkin(
      id: 'forest_bird',
      name: 'Moss Beak',
      type: BirdType.forest,
      shape: BirdBodyShape.oval,
      bodyColor: Color(0xFF2F7D32),
      wingColor: Color(0xFF1B5E20),
      bellyColor: Color(0xFFA5D6A7),
      accentColor: Color(0xFFFFD54F),
      price: 950),
  BirdSkin(
      id: 'cyber_bird',
      name: 'Neon Bolt',
      type: BirdType.cyber,
      shape: BirdBodyShape.diamond,
      bodyColor: Color(0xFF1D2444),
      wingColor: Color(0xFF00D7FF),
      bellyColor: Color(0xFF8BFFF6),
      accentColor: Color(0xFFFF2BD6),
      price: 1100),
  BirdSkin(
      id: 'shadow',
      name: 'Shadow Cube',
      type: BirdType.shadow,
      shape: BirdBodyShape.square,
      bodyColor: Color(0xFF22202C),
      wingColor: Color(0xFF111016),
      bellyColor: Color(0xFF7E7A91),
      accentColor: Color(0xFFB9A9FF),
      price: 1250),
  BirdSkin(
      id: 'candy_bird',
      name: 'Sugar Pop',
      type: BirdType.candy,
      shape: BirdBodyShape.circle,
      bodyColor: Color(0xFFFF70B7),
      wingColor: Color(0xFFFFB347),
      bellyColor: Color(0xFFFFF0A0),
      accentColor: Color(0xFF7BE7FF),
      price: 1400),
  BirdSkin(
      id: 'royal',
      name: 'Royal Crest',
      type: BirdType.royal,
      shape: BirdBodyShape.rounded,
      bodyColor: Color(0xFF3F51B5),
      wingColor: Color(0xFF283593),
      bellyColor: Color(0xFFC5CAE9),
      accentColor: Color(0xFFFFD700),
      price: 1600),
  BirdSkin(
      id: 'ninja',
      name: 'Ninja Wing',
      type: BirdType.ninja,
      shape: BirdBodyShape.oval,
      bodyColor: Color(0xFF111111),
      wingColor: Color(0xFF424242),
      bellyColor: Color(0xFFBDBDBD),
      accentColor: Color(0xFFE53935),
      price: 1800),
  BirdSkin(
      id: 'crystal',
      name: 'Crystal Finch',
      type: BirdType.crystal,
      shape: BirdBodyShape.diamond,
      bodyColor: Color(0xFF80DEEA),
      wingColor: Color(0xFF26C6DA),
      bellyColor: Color(0xFFE0F7FA),
      accentColor: Color(0xFFFFFFFF),
      price: 2000),
  BirdSkin(
      id: 'samurai',
      name: 'Sakura Guard',
      type: BirdType.samurai,
      shape: BirdBodyShape.square,
      bodyColor: Color(0xFF6D4735),
      wingColor: Color(0xFF3E2723),
      bellyColor: Color(0xFFFFCDD2),
      accentColor: Color(0xFFFF8FAB),
      price: 2200),
  BirdSkin(
      id: 'angel',
      name: 'Halo Dove',
      type: BirdType.angel,
      shape: BirdBodyShape.teardrop,
      bodyColor: Color(0xFFFDFDFD),
      wingColor: Color(0xFFE3F2FD),
      bellyColor: Color(0xFFFFF8E1),
      accentColor: Color(0xFFFFD54F),
      price: 2500),
  BirdSkin(
      id: 'demon',
      name: 'Crimson Horn',
      type: BirdType.demon,
      shape: BirdBodyShape.triangle,
      bodyColor: Color(0xFF7A0016),
      wingColor: Color(0xFF21070B),
      bellyColor: Color(0xFFFF6B6B),
      accentColor: Color(0xFFFF163D),
      price: 2800),
  BirdSkin(
      id: 'aqua',
      name: 'Aqua Bubble',
      type: BirdType.aqua,
      shape: BirdBodyShape.circle,
      bodyColor: Color(0xFF00ACC1),
      wingColor: Color(0xFF007C91),
      bellyColor: Color(0xFFB2EBF2),
      accentColor: Color(0xFF5CFFF1),
      price: 3100),
  BirdSkin(
      id: 'desert_bird',
      name: 'Dune Scout',
      type: BirdType.desert,
      shape: BirdBodyShape.oval,
      bodyColor: Color(0xFFC8914B),
      wingColor: Color(0xFF806037),
      bellyColor: Color(0xFFFFE0A3),
      accentColor: Color(0xFFFFC857),
      price: 3400),
  BirdSkin(
      id: 'thunder',
      name: 'Thunder Kite',
      type: BirdType.thunder,
      shape: BirdBodyShape.diamond,
      bodyColor: Color(0xFF455A64),
      wingColor: Color(0xFF263238),
      bellyColor: Color(0xFFCFD8DC),
      accentColor: Color(0xFFFFEB3B),
      price: 3800),
  BirdSkin(
      id: 'ghost',
      name: 'Ghost Wisp',
      type: BirdType.ghost,
      shape: BirdBodyShape.teardrop,
      bodyColor: Color(0xFFE8EAF6),
      wingColor: Color(0xFF9FA8DA),
      bellyColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFB9A9FF),
      price: 4200),
  BirdSkin(
      id: 'magma',
      name: 'Magma Core',
      type: BirdType.magma,
      shape: BirdBodyShape.square,
      bodyColor: Color(0xFF2B1A16),
      wingColor: Color(0xFFFF4A1C),
      bellyColor: Color(0xFFFFAB70),
      accentColor: Color(0xFFFFD180),
      price: 5000),
];

enum EnvironmentType {
  forest,
  sunset,
  cyber,
  arctic,
  desert,
  ocean,
  graveyard,
  candy,
  jungle,
  space,
  volcano,
  sakura,
  steampunk,
  heaven,
  nightmare,
}

class GameConfigController extends GetxController {
  static const String _selectedBirdKey = 'selected_bird';
  static const String _selectedEnvironmentKey = 'selected_environment';

  final Rx<BirdType> selectedBird = BirdType.blue.obs;
  final Rx<EnvironmentType> selectedEnvironment = EnvironmentType.forest.obs;

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
    return 'white_bird.png';
  }

  static BirdType birdFromId(String id) {
    return skinFromId(id).type;
  }

  static BirdSkin skinFromId(String id) {
    final normalizedId = id == 'yellow' ? 'default' : id;
    return premiumBirdSkins.firstWhere(
      (skin) => skin.id == normalizedId || skin.type.name == normalizedId,
      orElse: () => premiumBirdSkins.first,
    );
  }

  static BirdSkin skinFromType(BirdType type) {
    return premiumBirdSkins.firstWhere(
      (skin) => skin.type == type,
      orElse: () => premiumBirdSkins.first,
    );
  }

  static EnvironmentType environmentFromId(String id) {
    switch (id) {
      case 'night':
        return EnvironmentType.graveyard;
      case 'sunset':
        return EnvironmentType.sunset;
      case 'forest':
      case 'default':
      case 'sunny':
        return EnvironmentType.forest;
      case 'cyber':
        return EnvironmentType.cyber;
      case 'arctic':
      case 'snow':
      case 'winter':
        return EnvironmentType.arctic;
      case 'desert':
        return EnvironmentType.desert;
      case 'ocean':
      case 'atlantis':
        return EnvironmentType.ocean;
      case 'graveyard':
        return EnvironmentType.graveyard;
      case 'candy':
        return EnvironmentType.candy;
      case 'jungle':
        return EnvironmentType.jungle;
      case 'space':
        return EnvironmentType.space;
      case 'volcano':
        return EnvironmentType.volcano;
      case 'sakura':
        return EnvironmentType.sakura;
      case 'steampunk':
        return EnvironmentType.steampunk;
      case 'heaven':
        return EnvironmentType.heaven;
      case 'nightmare':
        return EnvironmentType.nightmare;
      default:
        return EnvironmentType.forest;
    }
  }

  /// Get gradient for environment
  Gradient getEnvironmentGradient() {
    switch (selectedEnvironment.value) {
      case EnvironmentType.forest:
        return const LinearGradient(
            colors: [Color(0xFF071D18), Color(0xFF8CCB86)]);
      case EnvironmentType.sunset:
        return const LinearGradient(
            colors: [Color(0xFF481A56), Color(0xFFFFC76B)]);
      case EnvironmentType.cyber:
        return const LinearGradient(
            colors: [Color(0xFF040712), Color(0xFF2E0F46)]);
      case EnvironmentType.arctic:
        return const LinearGradient(
            colors: [Color(0xFF07152C), Color(0xFFE2FAFF)]);
      case EnvironmentType.desert:
        return const LinearGradient(
            colors: [Color(0xFF6E3F28), Color(0xFFFFD886)]);
      case EnvironmentType.ocean:
        return const LinearGradient(
            colors: [Color(0xFF020B24), Color(0xFF1AA6B8)]);
      case EnvironmentType.graveyard:
        return const LinearGradient(
            colors: [Color(0xFF05050B), Color(0xFF424356)]);
      case EnvironmentType.candy:
        return const LinearGradient(
            colors: [Color(0xFFFF91C8), Color(0xFF8DEBFF)]);
      case EnvironmentType.jungle:
        return const LinearGradient(
            colors: [Color(0xFF08311F), Color(0xFF93D98B)]);
      case EnvironmentType.space:
        return const LinearGradient(
            colors: [Color(0xFF01020B), Color(0xFF5F2D84)]);
      case EnvironmentType.volcano:
        return const LinearGradient(
            colors: [Color(0xFF160306), Color(0xFFFF5A1F)]);
      case EnvironmentType.sakura:
        return const LinearGradient(
            colors: [Color(0xFF59325E), Color(0xFFFFE5C6)]);
      case EnvironmentType.steampunk:
        return const LinearGradient(
            colors: [Color(0xFF25160D), Color(0xFFD49755)]);
      case EnvironmentType.heaven:
        return const LinearGradient(
            colors: [Color(0xFF5BA8FF), Color(0xFFFFE6A6)]);
      case EnvironmentType.nightmare:
        return const LinearGradient(
            colors: [Color(0xFF020103), Color(0xFF720015)]);
    }
  }

  /// Check if bird is owned (for shop system)
  bool isBirdOwned(BirdType bird) {
    return true;
  }

  /// Check if environment is owned
  bool isEnvironmentOwned(EnvironmentType env) {
    return true;
  }
}
