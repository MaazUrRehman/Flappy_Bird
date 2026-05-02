import 'package:flutter/material.dart';
import '../../widgets/sound_tap.dart';
import 'levels_screen.dart';

/// DifficultyScreen - Select difficulty level (Easy, Medium, Hard, Extreme)
class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT DIFFICULTY'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            playClickSound();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // ✅ FIXED: Added SingleChildScrollView to handle overflow
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Your Challenge',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Difficulty buttons
                  _DifficultyButton(
                    difficulty: 'Easy',
                    color: Colors.green,
                    icon: Icons.sentiment_satisfied,
                    description: 'Perfect for beginners',
                    onTap: () => _navigateToLevels(context, 'easy'),
                  ),
                  const SizedBox(height: 16),
                  _DifficultyButton(
                    difficulty: 'Medium',
                    color: Colors.blue,
                    icon: Icons.sentiment_neutral,
                    description: 'A balanced challenge',
                    onTap: () => _navigateToLevels(context, 'medium'),
                  ),
                  const SizedBox(height: 16),
                  _DifficultyButton(
                    difficulty: 'Hard',
                    color: Colors.orange,
                    icon: Icons.sentiment_dissatisfied,
                    description: 'For skilled players',
                    onTap: () => _navigateToLevels(context, 'hard'),
                  ),
                  const SizedBox(height: 16),
                  _DifficultyButton(
                    difficulty: 'Extreme',
                    color: Colors.red,
                    icon: Icons.whatshot,
                    description: 'Only for the brave',
                    onTap: () => _navigateToLevels(context, 'extreme'),
                  ),
                  
                  const SizedBox(height: 20), // Extra bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLevels(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelsScreen(difficulty: difficulty),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String difficulty;
  final Color color;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.color,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // ✅ Reduced vertical padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 45, // ✅ Slightly reduced from 50
              height: 45, // ✅ Slightly reduced from 50
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24), // ✅ Reduced from 28
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 18, // ✅ Reduced from 20
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2), // ✅ Reduced from 4
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11, // ✅ Reduced from 12
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16), // ✅ Added size
          ],
        ),
      ),
    );
  }
}
