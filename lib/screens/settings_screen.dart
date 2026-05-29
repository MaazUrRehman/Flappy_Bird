import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/game_state_controller.dart';
import '../services/audio_manager.dart';
import '../widgets/sound_tap.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _musicVolumeKey = 'settings_music_volume';
  static const _sfxVolumeKey = 'settings_sfx_volume';
  static const _rotationKey = 'settings_rotation_enabled';
  static const _reducedMotionKey = 'settings_reduced_motion';
  static const _highContrastKey = 'settings_high_contrast';

  double _musicVolume = 0.7;
  double _sfxVolume = 0.85;
  bool _rotationEnabled = true;
  bool _reducedMotion = false;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _musicVolume = prefs.getDouble(_musicVolumeKey) ?? 0.7;
      _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 0.85;
      _rotationEnabled = prefs.getBool(_rotationKey) ?? true;
      _reducedMotion = prefs.getBool(_reducedMotionKey) ?? false;
      _highContrast = prefs.getBool(_highContrastKey) ?? false;
    });
    AudioManager.instance.setMusicVolume(_musicVolume);
    AudioManager.instance.setSfxVolume(_sfxVolume);
    _applyRotation();
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  void _applyRotation() {
    if (_rotationEnabled) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameStateController.instance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF102D3D), Color(0xFF142033), Color(0xFF211B35)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => Navigator.pop(context)),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  children: [
                    const Text(
                      'Game Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tune your flight feel',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 22),
                    Obx(
                      () => _SwitchTile(
                        icon: Icons.music_note,
                        title: 'Music',
                        subtitle: 'Background soundtrack',
                        color: Colors.amber,
                        value: gameState.musicEnabled.value,
                        onChanged: (_) => gameState.toggleMusic(),
                      ),
                    ),
                    Obx(
                      () => _SwitchTile(
                        icon: Icons.graphic_eq,
                        title: 'Sound FX',
                        subtitle: 'Jumps, coins and taps',
                        color: Colors.cyanAccent,
                        value: gameState.sfxEnabled.value,
                        onChanged: (_) => gameState.toggleSfx(),
                      ),
                    ),
                    _SliderTile(
                      icon: Icons.volume_up,
                      title: 'Music Volume',
                      color: Colors.amber,
                      value: _musicVolume,
                      onChanged: (value) {
                        setState(() => _musicVolume = value);
                        AudioManager.instance.setMusicVolume(value);
                        _saveDouble(_musicVolumeKey, value);
                      },
                    ),
                    _SliderTile(
                      icon: Icons.surround_sound,
                      title: 'SFX Volume',
                      color: Colors.lightGreenAccent,
                      value: _sfxVolume,
                      onChanged: (value) {
                        setState(() => _sfxVolume = value);
                        AudioManager.instance.setSfxVolume(value);
                        _saveDouble(_sfxVolumeKey, value);
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.screen_rotation,
                      title: 'Screen Rotation',
                      subtitle: 'Allow portrait and landscape',
                      color: Colors.pinkAccent,
                      value: _rotationEnabled,
                      onChanged: (value) {
                        setState(() => _rotationEnabled = value);
                        _saveBool(_rotationKey, value);
                        _applyRotation();
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.blur_on,
                      title: 'Reduced Motion',
                      subtitle: 'Calmer menus and effects',
                      color: Colors.deepPurpleAccent,
                      value: _reducedMotion,
                      onChanged: (value) {
                        setState(() => _reducedMotion = value);
                        _saveBool(_reducedMotionKey, value);
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.contrast,
                      title: 'High Contrast UI',
                      subtitle: 'Stronger menu readability',
                      color: Colors.orangeAccent,
                      value: _highContrast,
                      onChanged: (value) {
                        setState(() => _highContrast = value);
                        _saveBool(_highContrastKey, value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 18, 6),
      child: Row(
        children: [
          SoundTap(
            onTap: onBack,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            ),
          ),
          const Spacer(),
          const Icon(Icons.tune, color: Colors.amber, size: 26),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      trailing: Switch(
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      icon: icon,
      title: title,
      subtitle: '${(value * 100).round()}%',
      color: color,
      trailing: SizedBox(
        width: 136,
        child: Slider(
          value: value,
          activeColor: color,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SettingShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget trailing;

  const _SettingShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
