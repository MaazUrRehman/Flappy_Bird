import 'package:flutter/material.dart';

import '../../widgets/sound_tap.dart';
import 'levels_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _ScreenHeader(
                title: 'Choose Your Challenge',
                onBack: () {
                  playClickSound();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
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
                    ],
                  ),
                ),
              ),
            ],
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

class _ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 10),
      child: Row(
        children: [
          SoundTap(
            onTap: onBack,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
