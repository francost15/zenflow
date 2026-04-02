import 'package:flutter/services.dart';

/// Unified haptic feedback service for consistent tactile responses.
class HapticService {
  /// Light impact - for UI interactions (toggles, chips, selections)
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for task completion, confirmations
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for destructive actions (delete, sync errors)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for radio/checkbox selections
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Success pattern - double tap for successful completion
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error pattern - double heavy tap for errors
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate - general purpose vibration
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
