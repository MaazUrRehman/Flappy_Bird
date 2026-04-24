
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame/game.dart';
import 'screens/splash_screen.dart';
import 'game/flappy_bird_game.dart';
import 'screens/game_over_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flappy Bird",
      theme: ThemeData.dark(),
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
          (context, gameRef) => GameOverUI(game: gameRef as FlappyBirdGame, onHomePressed: () {  },),
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