import 'package:flappy_bird/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/flappy_bird_game.dart';
import 'screens/game_over_screen.dart';
import 'screens/pause_screen.dart';

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

    // Create game
    game = FlappyBirdGame();

    // ✅ Register GameOver overlay
    game.overlays.addEntry(
      'GameOver',
      (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: _goToHome,
      ),
    );

    // Register Pause button and menu overlay
    game.overlays.addEntry(
      'PauseButton',
      (context, gameRef) => PauseButtonOverlay(game: gameRef as FlappyBirdGame),
    );
    game.overlays.addEntry(
      'PauseMenu',
      (context, gameRef) => PauseMenuOverlay(
        game: gameRef as FlappyBirdGame,
        onHomePressed: _goToHome,
      ),
    );
    game.overlays.add('PauseButton');
  }

  void _goToHome() {
    // Clean up game before going home
    game.pauseEngine();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHome();
        return false;
      },
      child: Scaffold(
        body: GameWidget(
          game: game,
        ),
      ),
    );
  }
}
