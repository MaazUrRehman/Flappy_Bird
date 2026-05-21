import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../game/flappy_bird_game.dart';
import '../widgets/sound_tap.dart';
import '../controllers/streak_controller.dart';

class PauseButtonOverlay extends StatelessWidget {
  final FlappyBirdGame game;

  const PauseButtonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              if (game.overlays.isActive('PauseMenu')) return;
              game.pauseGame();
              game.overlays.add('PauseMenu');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.pause,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PauseMenuOverlay extends StatefulWidget {
  final FlappyBirdGame game;
  final VoidCallback onHomePressed;

  const PauseMenuOverlay(
      {super.key, required this.game, required this.onHomePressed});

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _scaleAnimation,
                child: _buildModal(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModal() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 3),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "PAUSED",
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
                // HOME button - Goes to Home Screen
                _circleButton(Icons.home, Colors.green, _goHome),
                // RESTART button - Restarts current streak
                _circleButton(Icons.refresh, Colors.orange, _restartStreak),
                // RESUME button - Resume gameplay
                _circleButton(Icons.play_arrow, Colors.blue, _resume),
              ],
            )
          ],
        ),
      ),
    );
  }

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

  void _goHome() {
    widget.game.overlays.remove('PauseMenu');
    widget.game.pauseEngine();
    widget.onHomePressed();
  }

  void _restartStreak() {
    // Restart current streak - reset progress but keep streak active
    final streakController = Get.find<StreakController>();
    if (streakController.activeStreak.value != null) {
      streakController.startStreak(streakController.activeStreak.value!);
    }
    widget.game.overlays.remove('PauseMenu');
    widget.game.reset();
  }

  void _resume() {
    widget.game.overlays.remove('PauseMenu');
    widget.game.resumeGame();
  }
}
