import 'package:flutter/services.dart';

/// Centralized haptic feedback calls.
class HapticsService {
  HapticsService._();
  static final HapticsService instance = HapticsService._();

  void lightImpact() {
    HapticFeedback.lightImpact();
  }

  void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
