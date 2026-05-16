import 'package:flutter/foundation.dart';

/// Ad unit ID registry for ZippySum.
///
/// Debug / profile builds → Google's public test IDs (safe to run on any device).
/// Release builds        → production IDs (placeholders until real units are created).
///
/// ⚠️  NEVER swap in production IDs for local testing unless your physical device
///     is registered as a test device in the AdMob console.  Using production IDs
///     on unregistered devices can result in invalid-traffic strikes.
///
/// Ad placement rules (enforced in AdBanner / AdsService):
///   • Banners allowed : Home, Game Over, Daily Challenge, Daily Complete.
///   • Interstitial    : after natural breaks only (e.g. classic game over);
///                       frequency-capped, never during active gameplay.
///   • Forbidden zones : active gameplay screen, pause modal, onboarding.
abstract final class AdIds {
  // ---------------------------------------------------------------------------
  // Platform support
  // ---------------------------------------------------------------------------

  static bool get adsSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // ---------------------------------------------------------------------------
  // Test IDs  — Google's official sample units, always safe for development.
  // ---------------------------------------------------------------------------

  static const String _testIosBanner =
      'ca-app-pub-3940256099942544/2435281174'; // Google sample unit
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910'; // Google sample unit

  static const String _testAndroidBanner =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  // ---------------------------------------------------------------------------
  // Production IDs  — replace with real AdMob ad unit IDs before releasing.
  //
  // Steps:
  //   1. Create ad units in the AdMob console (https://admob.google.com).
  //   2. Replace each placeholder string below with the generated ad unit ID.
  //   3. Update app-ads.txt at https://bonafide-losers.vercel.app/app-ads.txt
  //      with your AdMob publisher ID.
  //   4. Submit a new build for review.
  // ---------------------------------------------------------------------------

  // iOS AdMob App ID: ca-app-pub-2810457316491782~5217904365 (set in Info.plist)
  // Expected app-ads.txt: https://bonafide-losers.vercel.app/app-ads.txt
  static const String _prodIosBanner =
      'ca-app-pub-2810457316491782/8392686445';
  static const String _prodIosInterstitial =
      'ca-app-pub-2810457316491782/9292880748';

  static const String _prodAndroidBanner =
      'REPLACE_WITH_ANDROID_BANNER_ID';
  static const String _prodAndroidInterstitial =
      'REPLACE_WITH_ANDROID_INTERSTITIAL_ID';

  // ---------------------------------------------------------------------------
  // Active selectors — automatically choose test vs. production.
  // ---------------------------------------------------------------------------

  static String get bannerAdUnitId {
    final id = switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        kReleaseMode ? _prodIosBanner : _testIosBanner,
      TargetPlatform.android =>
        kReleaseMode ? _prodAndroidBanner : _testAndroidBanner,
      _ => '',
    };
    // Return empty string for unfilled placeholders so ad-loading guards
    // (which check `isEmpty`) skip loading rather than making a bad request.
    return _isPlaceholder(id) ? '' : id;
  }

  static String get interstitialAdUnitId {
    final id = switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        kReleaseMode ? _prodIosInterstitial : _testIosInterstitial,
      TargetPlatform.android =>
        kReleaseMode ? _prodAndroidInterstitial : _testAndroidInterstitial,
      _ => '',
    };
    return _isPlaceholder(id) ? '' : id;
  }

  /// Returns true for the sentinel placeholder strings used before real ad
  /// unit IDs are configured.  Prevents accidental requests with garbage IDs.
  static bool _isPlaceholder(String id) => id.startsWith('REPLACE_WITH_');
}
