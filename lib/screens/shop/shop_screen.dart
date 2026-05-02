import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/game_state_controller.dart';
import '../../services/audio_manager.dart';
import '../../widgets/sound_tap.dart';

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
        child: Column(
          children: [
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

    // Bird data - all FREE initially
    final birds = [
      {
        'id': 'default',
        'name': 'Classic Bird',
        'color': Colors.yellow,
        'price': 0
      },
      {'id': 'blue', 'name': 'Blue Bird', 'color': Colors.blue, 'price': 0},
      {'id': 'red', 'name': 'Red Bird', 'color': Colors.red, 'price': 0},
      {
        'id': 'green',
        'name': 'Green Bird',
        'color': Colors.green,
        'price': 100
      },
      {
        'id': 'purple',
        'name': 'Purple Bird',
        'color': Colors.purple,
        'price': 200
      },
      {
        'id': 'orange',
        'name': 'Orange Bird',
        'color': Colors.orange,
        'price': 300
      },
      {'id': 'pink', 'name': 'Pink Bird', 'color': Colors.pink, 'price': 500},
      {'id': 'gold', 'name': 'Gold Bird', 'color': Colors.amber, 'price': 1000},
    ];

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
            final birdId = bird['id'] as String;
            final isUnlocked = unlocked.contains(birdId);
            final isSelected = selected == birdId;
            final price = bird['price'] as int;

            return _BirdCard(
              name: bird['name'] as String,
              color: bird['color'] as Color,
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
  final String name;
  final Color color;
  final int price;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _BirdCard({
    required this.name,
    required this.color,
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
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

// ================= ENVIRONMENTS SHOP PAGE (FIXED) =================

class EnvironmentsShopPage extends StatelessWidget {
  const EnvironmentsShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = GameStateController.instance;

    // Environment data - all FREE initially
    final environments = [
      {
        'id': 'default',
        'name': 'Classic Sky',
        'colors': [Colors.lightBlue, Colors.blue],
        'price': 0
      },
      {
        'id': 'sunset',
        'name': 'Sunset',
        'colors': [Colors.orange, Colors.deepOrange],
        'price': 0
      },
      {
        'id': 'night',
        'name': 'Night Sky',
        'colors': [Colors.indigo, Colors.black],
        'price': 100
      },
      {
        'id': 'forest',
        'name': 'Forest',
        'colors': [Colors.green, Colors.tealAccent],
        'price': 200
      },
      {
        'id': 'desert',
        'name': 'Desert',
        'colors': [Colors.amber, Colors.orange],
        'price': 300
      },
      {
        'id': 'snow',
        'name': 'Snow',
        'colors': [Colors.white, Colors.lightBlue],
        'price': 500
      },
      {
        'id': 'space',
        'name': 'Space',
        'colors': [Colors.deepPurple, Colors.black],
        'price': 750
      },
      {
        'id': 'rainbow',
        'name': 'Rainbow',
        'colors': [Colors.pink, Colors.purple],
        'price': 1000
      },
    ];

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
            final envId = env['id'] as String;
            final isUnlocked = unlocked.contains(envId);
            final isSelected = selected == envId;
            final price = env['price'] as int;
            final colors = env['colors'] as List<Color>;

            return _EnvironmentCard(
              name: env['name'] as String,
              colors: colors,
              price: price,
              isUnlocked: isUnlocked,
              isSelected: isSelected,
              onTap: () => _handleEnvTap(context, envId, isUnlocked, price),
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
  final String name;
  final List<Color> colors;
  final int price;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnvironmentCard({
    required this.name,
    required this.colors,
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
            colors: colors,
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
                  const Icon(Icons.landscape, size: 48, color: Colors.white70),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
