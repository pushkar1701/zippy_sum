import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Test interstitials only; preloads and shows on natural breaks (e.g. classic game over).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  InterstitialAd? _interstitial;

  Future<void> loadInterstitial() async {
    if (!AdIds.adsSupported || AdIds.interstitialAdUnitId.isEmpty) {
      return;
    }
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

  /// Shows a loaded interstitial if one is ready. Never throws; does not block navigation.
  Future<void> showInterstitialIfReady() async {
    if (!AdIds.adsSupported) return;
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
