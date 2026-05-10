import 'package:flutter/services.dart';

import 'local_storage_service.dart';

/// Game haptics; respects [LocalStorageService] haptics toggle.
class HapticsService {
  HapticsService._();
  static final HapticsService instance = HapticsService._();

  bool? _cachedEnabled;

  void invalidateSettings() {
    _cachedEnabled = null;
  }

  Future<bool> _enabled() async {
    _cachedEnabled ??= await LocalStorageService.instance.getHapticsEnabled();
    return _cachedEnabled!;
  }

  Future<void> tileTap() async {
    if (!await _enabled()) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> correct() async {
    if (!await _enabled()) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> mistake() async {
    if (!await _enabled()) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> gameOver() async {
    if (!await _enabled()) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> newBestScore() async {
    if (!await _enabled()) return;
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await HapticFeedback.mediumImpact();
  }
}
