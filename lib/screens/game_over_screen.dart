import 'package:flutter/material.dart';
import '../game/flappy_bird_game.dart';
import '../widgets/sound_tap.dart';
import 'mini_games/word_game_modal.dart'; // Import the new word game

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
  bool _showWordGame = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: _showWordGame ? _buildWordGameModal() : _buildMainUI(),
      ),
    );
  }

  // ================= MAIN UI (SAME AS BEFORE) =================
  Widget _buildMainUI() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 3),
      ),
      child: Column(
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

          // Buttons Row (Exactly same as before - functionality preserved)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // HOME button - Goes to Home Screen
              _circleButton(Icons.home, Colors.green, _goHome),

              // RESTART button - Restarts game immediately
              _circleButton(Icons.refresh, Colors.orange, _restart),

              // CONTINUE button - Opens word guessing game
              _circleButton(Icons.play_arrow, Colors.blue, _showWordGameModal),
            ],
          )
        ],
      ),
    );
  }

  // ================= WORD GAME MODAL =================
  Widget _buildWordGameModal() {
    return WordGameModal(
      game: widget.game,
      onCancel: _cancelWordGame, // Cancel = back to Game Over screen
      onSuccess: _onWordGameSuccess, // Success = resume game
    );
  }

  // ================= HELPER WIDGETS (SAME AS BEFORE) =================
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
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
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
    return SoundTap(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // ================= BUTTON ACTIONS (PRESERVED ORIGINAL LOGIC) =================

  /// RESTART - Complete game restart (same as before)
  void _restart() {
    widget.game.overlays.remove('GameOver');
    widget.game.resumeEngine();
    widget.game.reset();
  }

  /// HOME - Navigate to home screen (same as before)
  void _goHome() {
    widget.game.overlays.remove('GameOver');
    widget.game.pauseEngine();
    widget.onHomePressed();
  }

  /// Show Word Game Modal
  void _showWordGameModal() {
    setState(() {
      _showWordGame = true;
    });
  }

  /// Cancel word game - Go back to Game Over UI
  void _cancelWordGame() {
    setState(() {
      _showWordGame = false;
    });
  }

  /// Successfully guessed word - Resume the flappy bird game
  void _onWordGameSuccess() {
    widget.game.overlays.remove('GameOver');
    widget.game.resumeEngine();
    widget.game.reviveBird(); // Your existing revive method
  }
}
