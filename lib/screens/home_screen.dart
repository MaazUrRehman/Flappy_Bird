import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flame/game.dart';

import '../game/flappy_bird_game.dart';
import '../screens/game_over_screen.dart'; // Import GameOverUI

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int highScore = 0;

  void _startGame() {
    final game = FlappyBirdGame();

    // ✅ Register GameOver overlay BEFORE showing game
    game.overlays.addEntry(
      'GameOver',
          (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () {
          // Go back to home screen
          Navigator.of(context).pop();
        },
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GameWidget(
            game: game,
          ),
        ),
      ),
    );
  }

  void _startGameWithDifficulty(String difficulty) {
    final game = FlappyBirdGame();

    // Set difficulty (add this method to your FlappyBirdGame class)
    // game.setDifficulty(difficulty);

    // ✅ Register GameOver overlay BEFORE showing game
    game.overlays.addEntry(
      'GameOver',
          (context, gameRef) => GameOverUI(
        game: gameRef as FlappyBirdGame,
        onHomePressed: () {
          Navigator.of(context).pop();
        },
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GameWidget(
            game: game,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A2A3A),
              Color(0xFF2A3A4A),
              Color(0xFF3A4A5A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundShapes(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "FLAPPY BIRD",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _bigCard(
                              title: "Play",
                              icon: Icons.play_arrow,
                              color: Colors.green,
                              onTap: _startGame, // ✅ Use fixed method
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _bigCard(
                              title: "Store",
                              icon: Icons.shopping_bag,
                              border: true,
                              onTap: () {
                                // Store functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Store coming soon!')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Text(
                            "Difficulty Modes",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 1.2,
                            children: [
                              _difficultyCard(
                                "Easy",
                                "No time limit",
                                Icons.local_cafe,
                                Colors.green,
                                onTap: () => _startGameWithDifficulty("easy"),
                              ),
                              _difficultyCard(
                                "Normal",
                                "100 sec",
                                Icons.timer,
                                Colors.orange,
                                onTap: () => _startGameWithDifficulty("normal"),
                              ),
                              _difficultyCard(
                                "Hard",
                                "50 sec",
                                Icons.fitness_center,
                                Colors.red,
                                onTap: () => _startGameWithDifficulty("hard"),
                              ),
                              _difficultyCard(
                                "Regret",
                                "20 sec",
                                Icons.local_fire_department,
                                Colors.purple,
                                onTap: () => _startGameWithDifficulty("regret"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: -20,
          right: -50,
          child: Container(
            width: 220,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.blue.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          left: -60,
          top: 180,
          child: Container(
            width: 140,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.purple.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          right: -40,
          top: 280,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.pink.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -30,
          child: Container(
            width: 160,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.orange.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: -60,
          child: Container(
            width: 200,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              color: Colors.teal.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.yellow.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: 20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.cyan.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bigCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.transparent,
    bool border = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: border
              ? LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              color.withOpacity(0.6),
              color.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: border
              ? Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyCard(
      String title,
      String subtitle,
      IconData icon,
      Color accentColor, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}