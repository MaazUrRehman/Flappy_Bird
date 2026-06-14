// ignore_for_file: avoid_print

import 'package:flame_audio/flame_audio.dart';
import 'package:get/get.dart';

/// AudioManager - Handles all game sounds and music
/// Uses FlameAudio for audio playback
class AudioManager extends GetxService {
  // Singleton instance
  static AudioManager get instance => Get.find<AudioManager>();

  // Audio players for different sound types
  final Set<AudioPlayer> _activeSfxPlayers = {};
  int _musicSession = 0;
  int _sfxSession = 0;

  // Mute state
  bool _isMuted = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool get isMuted => _isMuted;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  // Volume levels
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  DateTime _lastClickAt = DateTime.fromMillisecondsSinceEpoch(0);
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  @override
  void onInit() {
    super.onInit();
    FlameAudio.bgm.initialize();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // Pre-cache audio files for better performance
      await FlameAudio.audioCache.load('background.mp3');
      await FlameAudio.audioCache.load('game_over.mp3');
      await FlameAudio.audioCache.load('coin_collect.mp3');
      await FlameAudio.audioCache.load('jump.mp3');
      await FlameAudio.audioCache.load('correct_answer.mp3');
      await FlameAudio.audioCache.load('wrong_answer.mp3');
      await FlameAudio.audioCache.load('streak_complete.mp3');
      await FlameAudio.audioCache.load('button_click.mp3');
    } catch (e) {
      // Audio files may not exist yet - that's okay for now
      print(
          'AudioManager: Some audio files not found (will use generated sounds)');
    }
  }

  // ================= BACKGROUND MUSIC =================

  /// Start background music (loops indefinitely)
  Future<void> playBackgroundMusic() async {
    if (_isMuted || !_musicEnabled) return;

    final session = ++_musicSession;
    try {
      await FlameAudio.bgm.play('background.mp3', volume: _musicVolume);
      if (session != _musicSession || _isMuted || !_musicEnabled) {
        await FlameAudio.bgm.stop();
      }
    } catch (e) {
      print('Background music not available');
    }
  }

  Future<void> playBgMusic() => playBackgroundMusic();

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    _musicSession++;
    await FlameAudio.bgm.stop();
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (_musicEnabled) {
      await FlameAudio.bgm.pause();
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isMuted && _musicEnabled) {
      await FlameAudio.bgm.resume();
    }
  }

  // ================= GAME SOUND EFFECTS =================

  /// Play game over sound
  Future<void> playGameOverSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('game_over.mp3');
    } catch (e) {
      await _playFallbackTone(200, 0.5);
    }
  }

  /// Play coin collection sound
  Future<void> playCoinCollectSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('coin_collect.mp3');
    } catch (e) {
      await _playFallbackTone(800, 0.1);
    }
  }

  /// Play jump sound
  Future<void> playJumpSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('jump.mp3');
    } catch (e) {
      await _playFallbackTone(600, 0.08);
    }
  }

  /// Play button click sound
  Future<void> playButtonClickSound() async {
    if (_isMuted || !_sfxEnabled) return;

    final now = DateTime.now();
    if (now.difference(_lastClickAt).inMilliseconds < 80) return;
    _lastClickAt = now;

    try {
      await _playOneShot('button_click.mp3');
    } catch (e) {
      await _playFallbackTone(500, 0.05);
    }
  }

  Future<void> playSfx(String sound) async {
    if (_isMuted || !_sfxEnabled) return;

    switch (sound) {
      case 'button':
      case 'button_click':
        return playButtonClickSound();
      case 'coin':
      case 'coin_collect':
        return playCoinCollectSound();
      case 'game_over':
        return playGameOverSound();
      case 'wing':
      case 'flap':
      case 'jump':
        return playJumpSound();
      case 'correct':
        return playCorrectAnswerSound();
      case 'wrong':
        return playWrongAnswerSound();
      case 'streak_complete':
        return playStreakCompleteSound();
      default:
        try {
          await _playOneShot(sound);
        } catch (e) {
          print('AudioManager: Missing SFX $sound');
        }
    }
  }

  // ================= WORD GAME SOUNDS =================

  /// Play correct answer sound (positive)
  Future<void> playCorrectAnswerSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('correct_answer.mp3');
    } catch (e) {
      await _playFallbackTone(600, 0.15);
      if (_isMuted || !_sfxEnabled) return;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isMuted || !_sfxEnabled) return;
      await _playFallbackTone(800, 0.15);
    }
  }

  /// Play wrong answer sound (negative)
  Future<void> playWrongAnswerSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('wrong_answer.mp3');
    } catch (e) {
      await _playFallbackTone(400, 0.2);
      if (_isMuted || !_sfxEnabled) return;
      await Future.delayed(const Duration(milliseconds: 150));
      if (_isMuted || !_sfxEnabled) return;
      await _playFallbackTone(200, 0.3);
    }
  }

  /// Play streak complete sound
  Future<void> playStreakCompleteSound() async {
    if (_isMuted || !_sfxEnabled) return;

    try {
      await _playOneShot('streak_complete.mp3');
    } catch (e) {
      await _playFallbackTone(700, 0.1);
      if (_isMuted || !_sfxEnabled) return;
      await Future.delayed(const Duration(milliseconds: 80));
      if (_isMuted || !_sfxEnabled) return;
      await _playFallbackTone(900, 0.1);
      if (_isMuted || !_sfxEnabled) return;
      await Future.delayed(const Duration(milliseconds: 80));
      if (_isMuted || !_sfxEnabled) return;
      await _playFallbackTone(1100, 0.15);
    }
  }

  // ================= VOLUME CONTROLS =================

  /// Set music volume (0.0 to 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (_musicEnabled) {
      FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
    }
  }

  /// Set SFX volume (0.0 to 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      await stopBackgroundMusic();
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    _sfxSession++;
    if (!enabled) {
      await _stopActiveSfx();
    }
  }

  // ================= MUTE CONTROLS =================

  /// Toggle mute state
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stopBackgroundMusic();
      _stopActiveSfx();
    } else {
      playBackgroundMusic();
    }
  }

  /// Set mute state
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stopBackgroundMusic();
      _stopActiveSfx();
    }
  }

  Future<void> _playOneShot(String file) async {
    if (_isMuted || !_sfxEnabled) return;

    final session = _sfxSession;
    final player = await FlameAudio.play(file, volume: _sfxVolume);

    if (session != _sfxSession || _isMuted || !_sfxEnabled) {
      await player.stop();
      await player.dispose();
      return;
    }

    _activeSfxPlayers.add(player);
    player.onPlayerComplete.listen((_) {
      _activeSfxPlayers.remove(player);
      player.dispose();
    });
  }

  Future<void> _stopActiveSfx() async {
    final players = List<AudioPlayer>.from(_activeSfxPlayers);
    _activeSfxPlayers.clear();
    for (final player in players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        // Player may already have completed/disposed.
      }
    }
  }

  // ================= FALLBACK TONES =================

  /// Play a simple fallback tone when audio files aren't available
  Future<void> _playFallbackTone(double frequency, double duration) async {
    print('AudioManager: Playing tone at $frequency Hz for ${duration}s');
  }

  @override
  void onClose() {
    FlameAudio.bgm.dispose();
    _stopActiveSfx();
    super.onClose();
  }
}
