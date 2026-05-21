import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/game_state_controller.dart';
import '../../controllers/game_config_controller.dart';
import '../../services/audio_manager.dart';
import '../../widgets/sound_tap.dart';
import '../../models/environment_theme.dart';

/// ShopScreen - Main shop entry point with navigation to Birds and Environments
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameStateController _gameState = GameStateController.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.flutter_dash), text: 'Birds'),
            Tab(icon: Icon(Icons.landscape), text: 'Environments'),
          ],
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
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Obx(() => Text(
                      '${_gameState.totalCoins.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    )),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BirdsShopPage(),
                EnvironmentsShopPage(),
              ],
            ),
          ),
        ]
            // Coin display

            ),
      ),
    );
  }
}

// ================= BIRDS SHOP PAGE (FIXED) =================

class BirdsShopPage extends StatelessWidget {
  const BirdsShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameStateController.instance;

    const birds = premiumBirdSkins;

    // FIXED: Proper Obx usage with extracted reactive values
    return Obx(() {
      final unlocked = gameState.unlockedBirds.toList();
      final selected = gameState.selectedBird.value;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: birds.length,
        itemBuilder: (context, index) {
          final bird = birds[index];
          final birdId = bird.id;
          final isUnlocked = unlocked.contains(birdId);
          final isSelected = selected == birdId ||
              (selected == 'yellow' && birdId == 'default');
          final price = bird.price;

          return _BirdCard(
            skin: bird,
            price: price,
            isUnlocked: isUnlocked,
            isSelected: isSelected,
            onTap: () => _handleBirdTap(context, birdId, isUnlocked, price),
          );
        },
      );
    });
  }

  void _handleBirdTap(
      BuildContext context, String birdId, bool isUnlocked, int price) {
    final gameState = GameStateController.instance;
    _playClick();

    if (isUnlocked) {
      // Select this bird
      gameState.selectBird(birdId);
      Get.snackbar(
        'Selected',
        'Bird changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      // Try to purchase
      _showPurchaseDialog(context, birdId, price);
    }
  }

  void _playClick() {
    try {
      AudioManager.instance.playButtonClickSound();
    } catch (e) {
      // AudioManager may not be initialized yet.
    }
  }

  void _showPurchaseDialog(BuildContext context, String birdId, int price) {
    final gameState = GameStateController.instance;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title:
            const Text('Purchase Bird', style: TextStyle(color: Colors.white)),
        content: Text(
          'Buy this bird for $price coins?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              playClickSound();
              Get.back();
            },
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              playClickSound();
              // FIXED: Using proper unlock method
              await gameState.unlockBird(birdId, cost: price);
              Get.back();
              if (gameState.unlockedBirds.contains(birdId)) {
                Get.snackbar(
                  'Purchased!',
                  'Bird unlocked successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Not enough coins',
                  'You need $price coins',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text('Buy ($price)',
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _BirdCard extends StatelessWidget {
  final BirdSkin skin;
  final int price;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _BirdCard({
    required this.skin,
    required this.price,
    required this.isUnlocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // Bird preview
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 78,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CustomPaint(
                      painter: _BirdPreviewPainter(skin),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    skin.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Status indicator
            if (!isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        '$price',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Selected indicator
            if (isSelected)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.amber.withOpacity(0.3),
                  child: const Center(
                    child: Text(
                      'SELECTED',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

            // Locked overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white70, size: 32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BirdPreviewPainter extends CustomPainter {
  final BirdSkin skin;

  _BirdPreviewPainter(this.skin);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * 0.12, size.height * 0.16);
    final birdSize = Size(size.width * 0.68, size.height * 0.62);
    _drawBody(canvas, birdSize);
    _drawBelly(canvas, birdSize);
    _drawWing(canvas, birdSize);
    _drawEyeAndBeak(canvas, birdSize);
    _drawTail(canvas, birdSize);
    _drawAccent(canvas, birdSize);
    canvas.restore();
  }

  void _drawBody(Canvas canvas, Size s) {
    final paint = Paint()..color = skin.bodyColor;
    final rect = Rect.fromLTWH(0, 0, s.width, s.height);
    switch (skin.shape) {
      case BirdBodyShape.circle:
        canvas.drawOval(Rect.fromLTWH(4, 0, s.height, s.height), paint);
        break;
      case BirdBodyShape.oval:
        canvas.drawOval(rect, paint);
        break;
      case BirdBodyShape.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(0, s.height * 0.86)
            ..quadraticBezierTo(s.width * 0.22, 0, s.width * 0.82, 0)
            ..lineTo(s.width, s.height * 0.52)
            ..quadraticBezierTo(s.width * 0.52, s.height, 0, s.height * 0.86)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(8)),
          paint,
        );
        break;
      case BirdBodyShape.diamond:
        canvas.drawPath(
          Path()
            ..moveTo(s.width * 0.5, 0)
            ..lineTo(s.width, s.height * 0.5)
            ..lineTo(s.width * 0.5, s.height)
            ..lineTo(0, s.height * 0.5)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.teardrop:
        canvas.drawPath(
          Path()
            ..moveTo(s.width * 0.86, s.height * 0.48)
            ..cubicTo(s.width * 0.72, -4, 5, 0, 4, s.height * 0.48)
            ..cubicTo(3, s.height * 0.95, s.width * 0.6, s.height * 1.08,
                s.width * 0.86, s.height * 0.48)
            ..close(),
          paint,
        );
        break;
      case BirdBodyShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(18)),
          paint,
        );
        break;
    }
    canvas.drawOval(
      Rect.fromLTWH(7, 4, s.width * 0.42, s.height * 0.25),
      Paint()..color = Colors.white.withOpacity(0.16),
    );
  }

  void _drawBelly(Canvas canvas, Size s) {
    canvas.drawOval(
      Rect.fromLTWH(
          s.width * 0.16, s.height * 0.44, s.width * 0.52, s.height * 0.38),
      Paint()..color = skin.bellyColor,
    );
  }

  void _drawWing(Canvas canvas, Size s) {
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.16, s.height * 0.5)
        ..quadraticBezierTo(
            s.width * 0.36, s.height * 0.22, s.width * 0.62, s.height * 0.48)
        ..lineTo(s.width * 0.58, s.height * 0.67)
        ..quadraticBezierTo(
            s.width * 0.34, s.height * 0.74, s.width * 0.16, s.height * 0.6)
        ..close(),
      Paint()..color = skin.wingColor,
    );
  }

  void _drawEyeAndBeak(Canvas canvas, Size s) {
    canvas.drawCircle(
      Offset(s.width * 0.75, s.height * 0.3),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(s.width * 0.77, s.height * 0.31),
      3,
      Paint()..color = Colors.black,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.9, s.height * 0.32)
        ..lineTo(s.width + 10, s.height * 0.4)
        ..lineTo(s.width * 0.9, s.height * 0.48)
        ..close(),
      Paint()..color = skin.accentColor,
    );
  }

  void _drawTail(Canvas canvas, Size s) {
    canvas.drawPath(
      Path()
        ..moveTo(0, s.height * 0.6)
        ..lineTo(-10, s.height * 0.46)
        ..lineTo(-5, s.height * 0.64)
        ..lineTo(-13, s.height * 0.76)
        ..lineTo(0, s.height * 0.68)
        ..close(),
      Paint()..color = skin.wingColor,
    );
  }

  void _drawAccent(Canvas canvas, Size s) {
    final paint = Paint()..color = skin.accentColor;
    if ([BirdType.golden, BirdType.royal].contains(skin.type)) {
      canvas.drawPath(
        Path()
          ..moveTo(s.width * 0.34, -3)
          ..lineTo(s.width * 0.42, -11)
          ..lineTo(s.width * 0.5, -3)
          ..lineTo(s.width * 0.58, -11)
          ..lineTo(s.width * 0.66, -3)
          ..close(),
        paint,
      );
    } else if ([BirdType.demon, BirdType.magma].contains(skin.type)) {
      canvas.drawPath(
        Path()
          ..moveTo(s.width * 0.3, 2)
          ..lineTo(s.width * 0.2, -9)
          ..lineTo(s.width * 0.4, -2)
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(s.width * 0.62, 2)
          ..lineTo(s.width * 0.74, -9)
          ..lineTo(s.width * 0.52, -2)
          ..close(),
        paint,
      );
    } else if (skin.type == BirdType.angel) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * 0.48, -7),
          width: 24,
          height: 8,
        ),
        Paint()
          ..color = skin.accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BirdPreviewPainter oldDelegate) {
    return oldDelegate.skin != skin;
  }
}

// ================= ENVIRONMENTS SHOP PAGE (FIXED) =================

class EnvironmentsShopPage extends StatelessWidget {
  const EnvironmentsShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameStateController.instance;

    const environments = premiumEnvironmentThemes;

    // FIXED: Proper Obx usage with extracted reactive values
    return Obx(() {
      final unlocked = gameState.unlockedEnvironments.toList();
      final selected = gameState.selectedEnvironment.value;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: environments.length,
        itemBuilder: (context, index) {
          final env = environments[index];
          final envId = env.id;
          final isUnlocked = unlocked.contains(envId);
          final isSelected =
              selected == envId || (selected == 'default' && envId == 'forest');

          return _EnvironmentCard(
            theme: env,
            price: 0,
            isUnlocked: isUnlocked,
            isSelected: isSelected,
            onTap: () => _handleEnvTap(context, envId, isUnlocked, 0),
          );
        },
      );
    });
  }

  void _handleEnvTap(
      BuildContext context, String envId, bool isUnlocked, int price) {
    final gameState = GameStateController.instance;
    _playClick();

    if (isUnlocked) {
      gameState.selectEnvironment(envId);
      Get.snackbar(
        'Selected',
        'Environment changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      _showPurchaseDialog(context, envId, price);
    }
  }

  void _playClick() {
    try {
      AudioManager.instance.playButtonClickSound();
    } catch (e) {
      // AudioManager may not be initialized yet.
    }
  }

  void _showPurchaseDialog(BuildContext context, String envId, int price) {
    final gameState = GameStateController.instance;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Purchase Environment',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Buy this environment for $price coins?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              playClickSound();
              Get.back();
            },
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              playClickSound();
              // FIXED: Using proper unlock method
              await gameState.unlockEnvironment(envId, cost: price);
              Get.back();
              if (gameState.unlockedEnvironments.contains(envId)) {
                Get.snackbar(
                  'Purchased!',
                  'Environment unlocked successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Not enough coins',
                  'You need $price coins',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text('Buy ($price)',
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentCard extends StatelessWidget {
  final EnvironmentTheme theme;
  final int price;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnvironmentCard({
    required this.theme,
    required this.price,
    required this.isUnlocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoundTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.previewColors,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // Environment preview
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(theme.icon, size: 48, color: Colors.white70),
                  const SizedBox(height: 12),
                  Text(
                    theme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      theme.ambience,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            if (!isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        '$price',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Selected indicator
            if (isSelected)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.amber.withOpacity(0.3),
                  child: const Center(
                    child: Text(
                      'SELECTED',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

            // Locked overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white70, size: 32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
