import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'consent_service.dart';

/// Manages interstitial ads. All methods are consent-gated and fail silently.
///
/// Load/show interstitials only on natural breaks (classic game-over, etc.).
/// Never during active gameplay, pause, or onboarding.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  InterstitialAd? _interstitial;

  /// Preloads an interstitial ad if consent allows.
  Future<void> loadInterstitial() async {
    if (!AdIds.adsSupported || AdIds.interstitialAdUnitId.isEmpty) return;

    // Consent gate — never load without user permission.
    if (!await ConsentService.instance.canRequestAds()) return;

    final previous = _interstitial;
    _interstitial = null;
    if (previous != null) {
      await previous.dispose();
    }

    await InterstitialAd.load(
      adUnitId: AdIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              // Reload only if consent still allows ads.
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadInterstitial();
            },
          );
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
        },
      ),
    );
  }

  /// Shows a loaded interstitial if one is ready and consent allows.
  ///
  /// Never throws; does not block navigation.
  Future<void> showInterstitialIfReady() async {
    if (!AdIds.adsSupported) return;

    // Re-check consent at show time — user may have changed choices.
    if (!await ConsentService.instance.canRequestAds()) return;

    final ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    try {
      await ad.show();
    } catch (_) {
      await ad.dispose();
      await loadInterstitial();
    }
  }

  Future<void> dispose() async {
    final ad = _interstitial;
    _interstitial = null;
    if (ad != null) {
      await ad.dispose();
    }
  }
}
