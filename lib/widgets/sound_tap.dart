import 'package:flutter/material.dart';

import '../services/audio_manager.dart';

class SoundTap extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final HitTestBehavior behavior;

  const SoundTap({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: enabled && onTap != null
          ? () {
              playClickSound();
              onTap!();
            }
          : null,
      child: child,
    );
  }
}

void playClickSound() {
  try {
    AudioManager.instance.playButtonClickSound();
  } catch (e) {
    // AudioManager may not be initialized in tests or early startup.
  }
}
