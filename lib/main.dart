import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flame/game.dart';
import 'screens/splash_screen.dart';
import 'game/flappy_bird_game.dart';
import 'screens/game_over_screen.dart';
import 'controllers/game_state_controller.dart';
import 'controllers/coin_controller.dart';
import 'controllers/game_config_controller.dart';
import 'controllers/level_controller.dart';
import 'controllers/streak_controller.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize GetX controllers and services
  _initializeServices();

  runApp(const FlappyBirdApp());
}

void _initializeServices() {
  // Initialize GameStateController (persistent storage)
  Get.put(GameStateController(), permanent: true);

  // Initialize CoinController (coin management)
  Get.put(CoinController(), permanent: true);

  // Initialize GameConfigController (bird/environment selection)
  Get.put(GameConfigController(), permanent: true);

  // Initialize StreakController (streak/achievement system)
  Get.put(StreakController(), permanent: true);

  // Initialize LevelController (dynamic level tasks/unlocks)
  Get.put(LevelController(), permanent: true);

  // Initialize AudioManager (sound system)
  Get.put(AudioManager(), permanent: true);
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flappy Bird",
      theme: ThemeData.dark(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
      ],
      home: const SplashScreen(),
    );
  }
}

// ==================== GAME WIDGET SCREEN ====================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FlappyBirdGame game;

  @override
  void initState() {
    super.initState();

    // ✅ CRITICAL: Create game FIRST
    game = FlappyBirdGame();

    // ✅ THEN register the overlay BEFORE adding to widget
    game.overlays.addEntry(
      'GameOver',
      (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
      ),
    );
  }
}
