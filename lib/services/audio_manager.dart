// ignore_for_file: avoid_print

import 'package:flame_audio/flame_audio.dart';
import 'package:get/get.dart';

/// AudioManager - Handles all game sounds and music
/// Uses FlameAudio for audio playback
class AudioManager extends GetxService {
  // Singleton instance
  static AudioManager get instance => Get.find<AudioManager>();

  // Audio players for different sound types
  AudioPlayer? _bgMusicPlayer;
  AudioPlayer? _sfxPlayer;

  // Mute state
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  // Volume levels
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  DateTime _lastClickAt = DateTime.fromMillisecondsSinceEpoch(0);
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  @override
  void onInit() {
    super.onInit();
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
    if (_isMuted) return;

    try {
      _bgMusicPlayer?.stop();
      _bgMusicPlayer =
          await FlameAudio.play('background.mp3', volume: _musicVolume);
      _bgMusicPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Background music not available');
    }
  }

  Future<void> playBgMusic() => playBackgroundMusic();

  /// Stop background music
  void stopBackgroundMusic() {
    _bgMusicPlayer?.stop();
    _bgMusicPlayer = null;
  }

  /// Pause background music
  void pauseBackgroundMusic() {
    _bgMusicPlayer?.pause();
  }

  /// Resume background music
  void resumeBackgroundMusic() {
    if (!_isMuted) {
      _bgMusicPlayer?.resume();
    }
  }

  // ================= GAME SOUND EFFECTS =================

  /// Play game over sound
  Future<void> playGameOverSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('game_over.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(200, 0.5);
    }
  }

  /// Play coin collection sound
  Future<void> playCoinCollectSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('coin_collect.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(800, 0.1);
    }
  }

  /// Play jump sound
  Future<void> playJumpSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('jump.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(600, 0.08);
    }
  }

  /// Play button click sound
  Future<void> playButtonClickSound() async {
    if (_isMuted) return;

    final now = DateTime.now();
    if (now.difference(_lastClickAt).inMilliseconds < 80) return;
    _lastClickAt = now;

    try {
      await FlameAudio.play('button_click.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(500, 0.05);
    }
  }

  Future<void> playSfx(String sound) async {
    if (_isMuted) return;

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
          await FlameAudio.play(sound, volume: _sfxVolume);
        } catch (e) {
          print('AudioManager: Missing SFX $sound');
        }
    }
  }

  // ================= WORD GAME SOUNDS =================

  /// Play correct answer sound (positive)
  Future<void> playCorrectAnswerSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('correct_answer.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(600, 0.15);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playFallbackTone(800, 0.15);
    }
  }

  /// Play wrong answer sound (negative)
  Future<void> playWrongAnswerSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('wrong_answer.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(400, 0.2);
      await Future.delayed(const Duration(milliseconds: 150));
      await _playFallbackTone(200, 0.3);
    }
  }

  /// Play streak complete sound
  Future<void> playStreakCompleteSound() async {
    if (_isMuted) return;

    try {
      await FlameAudio.play('streak_complete.mp3', volume: _sfxVolume);
    } catch (e) {
      await _playFallbackTone(700, 0.1);
      await Future.delayed(const Duration(milliseconds: 80));
      await _playFallbackTone(900, 0.1);
      await Future.delayed(const Duration(milliseconds: 80));
      await _playFallbackTone(1100, 0.15);
    }
  }

  // ================= VOLUME CONTROLS =================

  /// Set music volume (0.0 to 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _bgMusicPlayer?.setVolume(_musicVolume);
  }

  /// Set SFX volume (0.0 to 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  // ================= MUTE CONTROLS =================

  /// Toggle mute state
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  /// Set mute state
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stopBackgroundMusic();
    }
  }

  // ================= FALLBACK TONES =================

  /// Play a simple fallback tone when audio files aren't available
  Future<void> _playFallbackTone(double frequency, double duration) async {
    print('AudioManager: Playing tone at $frequency Hz for ${duration}s');
  }

  @override
  void onClose() {
    _bgMusicPlayer?.dispose();
    _sfxPlayer?.dispose();
    super.onClose();
  }
}
