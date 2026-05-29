import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_state_controller.dart';
import '../widgets/sound_tap.dart';
import 'game/difficulty_screen.dart';
import 'game/levels_screen.dart';
import 'settings_screen.dart';
import 'shop/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF143849), Color(0xFF17263B), Color(0xFF241D39)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const _FloatingBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 18),
                    const _HeroTitle(),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            title: 'Play',
                            icon: Icons.play_circle_fill,
                            color: const Color(0xFF5CE08A),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DifficultyScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionCard(
                            title: 'Store',
                            icon: Icons.storefront,
                            color: const Color(0xFFFFC857),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShopScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Difficulty Modes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.18,
                      children: [
                        _DifficultyCard(
                          title: 'Easy',
                          subtitle: 'First Flight',
                          icon: Icons.eco,
                          color: const Color(0xFF5CE08A),
                          onTap: () => _openLevels(context, 'easy'),
                        ),
                        _DifficultyCard(
                          title: 'Medium',
                          subtitle: 'Steady Wings',
                          icon: Icons.air,
                          color: const Color(0xFF4DB5FF),
                          onTap: () => _openLevels(context, 'medium'),
                        ),
                        _DifficultyCard(
                          title: 'Hard',
                          subtitle: 'Sharp Turns',
                          icon: Icons.bolt,
                          color: const Color(0xFFFFA63D),
                          onTap: () => _openLevels(context, 'hard'),
                        ),
                        _DifficultyCard(
                          title: 'Extreme',
                          subtitle: 'Storm Run',
                          icon: Icons.local_fire_department,
                          color: const Color(0xFFFF4B6E),
                          onTap: () => _openLevels(context, 'extreme'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final gameState = GameStateController.instance;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.32),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.amber.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  '${gameState.totalCoins.value}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SoundTap(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.24)),
            ),
            child: const Icon(Icons.settings, color: Color(0xFFFFC857)),
          ),
        ),
      ],
    );
  }

  void _openLevels(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelsScreen(difficulty: difficulty),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 126,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 4,
            top: 0,
            child: Transform.rotate(
              angle: -0.18,
              child: CustomPaint(
                size: const Size(74, 58),
                painter: _TinyBirdPainter(),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text(
              'FLAPPY\nBIRD',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 0.92,
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.3,
                shadows: [
                  Shadow(
                    blurRadius: 14,
                    color: Colors.black45,
                    offset: Offset(0, 5),
                  ),
                  Shadow(
                    blurRadius: 18,
                    color: Color(0x665CE08A),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        height: 142,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.11),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),
            Icon(icon, color: color, size: 46),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.42), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBackground extends StatelessWidget {
  const _FloatingBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _FloatTile(top: 18, left: -34, width: 150, height: 120, angle: -0.18),
        _FloatTile(top: 76, right: -42, width: 180, height: 118, angle: 0.16),
        _FloatTile(top: 280, left: -48, width: 150, height: 210, angle: 0.1),
        _FloatTile(top: 365, right: -36, width: 160, height: 150, angle: -0.2),
        _FloatTile(bottom: 80, left: -26, width: 176, height: 136, angle: 0.22),
        _FloatTile(
            bottom: 38, right: -56, width: 210, height: 170, angle: -0.1),
      ],
    );
  }
}

class _FloatTile extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double width;
  final double height;
  final double angle;

  const _FloatTile({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.width,
    required this.height,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyBirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFFFFD34E);
    final wing = Paint()..color = const Color(0xFFFF9F2E);
    final belly = Paint()..color = const Color(0xFFFFF2A8);
    final eye = Paint()..color = Colors.white;
    final pupil = Paint()..color = const Color(0xFF152034);
    final beak = Paint()..color = const Color(0xFFFF7E36);

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.12, size.width * 0.72,
          size.height * 0.68),
      body,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.42, size.width * 0.38,
          size.height * 0.25),
      belly,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.18, size.height * 0.48)
        ..quadraticBezierTo(size.width * 0.34, size.height * 0.22,
            size.width * 0.55, size.height * 0.45)
        ..quadraticBezierTo(size.width * 0.36, size.height * 0.66,
            size.width * 0.18, size.height * 0.58)
        ..close(),
      wing,
    );
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.31), 7, eye);
    canvas.drawCircle(
        Offset(size.width * 0.64, size.height * 0.32), 3.5, pupil);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.78, size.height * 0.34)
        ..lineTo(size.width * 0.98, size.height * 0.43)
        ..lineTo(size.width * 0.78, size.height * 0.5)
        ..close(),
      beak,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
