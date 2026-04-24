import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../game/flappy_bird_game.dart';

// ==================== GAME OVER UI (OVERLAY) ====================

class GameOverUI extends StatefulWidget {
  final FlappyBirdGame game;
  final VoidCallback onHomePressed;

  const GameOverUI({
    super.key,
    required this.game,
    required this.onHomePressed,
  });

  @override
  State<GameOverUI> createState() => _GameOverUIState();
}

class _GameOverUIState extends State<GameOverUI> {

  // Mini game state
  String word = "BIRD";
  String input = "";
  bool showMiniGame = false;
  String message = "";

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.black.withOpacity(0.6),

      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green, width: 3),
          ),

          child: showMiniGame ? _miniGameUI() : _mainUI(),
        ),
      ),
    );
  }

  // ================= MAIN UI =================
  Widget _mainUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        const Text(
          "GAME OVER",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        _statRow("🪙", "COINS", widget.game.collectedCoins),
        _divider(),

        _statRow("⭐", "SCORE", widget.game.score),
        _divider(),

        _statRow("🚩", "DISTANCE", widget.game.distance.toInt()),

        const SizedBox(height: 25),

        // Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            _circleButton(Icons.home, Colors.green, _goHome),

            _circleButton(Icons.refresh, Colors.orange, _restart),

            _circleButton(Icons.play_arrow, Colors.blue, _continueGame),
          ],
        )
      ],
    );
  }

  // ================= MINI GAME =================
  Widget _miniGameUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        const Text(
          "Guess the word",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),

        const SizedBox(height: 10),

        Text(
          word.replaceAll(RegExp(r"."), "_ "),
          style: const TextStyle(color: Colors.yellow, fontSize: 24),
        ),

        TextField(
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => input = val.toUpperCase(),
          decoration: const InputDecoration(
            hintText: "Enter word",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),

        const SizedBox(height: 10),

        Text(message, style: const TextStyle(color: Colors.red)),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            ElevatedButton(
              onPressed: _checkWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),

            ElevatedButton(
              onPressed: _cancelToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  // ================= HELPERS =================

  Widget _statRow(String icon, String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.white24, height: 1);

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // ================= BUTTON ACTIONS =================

  void _restart() {
    widget.game.overlays.remove('GameOver');
    widget.game.resumeEngine();
    widget.game.reset();
  }

  void _goHome() {
    widget.game.overlays.remove('GameOver');
    widget.game.pauseEngine();
    widget.onHomePressed();
  }

  void _continueGame() {
    setState(() {
      showMiniGame = true;
      message = "";
      input = "";
    });
  }

  void _checkWord() {
    if (input.toUpperCase() == word) {
      widget.game.overlays.remove('GameOver');
      widget.game.resumeEngine();
      widget.game.reviveBird();
    } else {
      setState(() {
        message = "Wrong! Try again";
        input = "";
      });
    }
  }

  void _cancelToHome() {
    widget.game.overlays.remove('GameOver');
    widget.onHomePressed();
  }
}