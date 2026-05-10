import 'package:flutter/foundation.dart';

/// Google sample / test ad unit IDs only — not for production.
abstract final class AdIds {
  static bool get adsSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get bannerAdUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/9214589741';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2435281174';
      default:
        return '';
    }
  }

  static String get interstitialAdUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/4411468910';
      default:
        return '';
    }
  }
}
