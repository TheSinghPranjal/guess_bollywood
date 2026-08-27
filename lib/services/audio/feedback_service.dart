import 'package:flutter/services.dart';

class FeedbackService {
  const FeedbackService();

  Future<void> correct({required bool sound, required bool haptics}) async {
    if (haptics) await HapticFeedback.lightImpact();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> wrong({required bool sound, required bool haptics}) async {
    if (haptics) await HapticFeedback.mediumImpact();
    if (sound) await SystemSound.play(SystemSoundType.alert);
  }

  Future<void> hint({required bool sound, required bool haptics}) async {
    if (haptics) await HapticFeedback.selectionClick();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> win({required bool sound, required bool haptics}) async {
    if (haptics) await HapticFeedback.heavyImpact();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> lose({required bool sound, required bool haptics}) async {
    if (haptics) await HapticFeedback.heavyImpact();
    if (sound) await SystemSound.play(SystemSoundType.alert);
  }
}
