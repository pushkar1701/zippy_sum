import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_ids.dart';

/// Bottom banner using Google test ad units; hidden until loaded or if load fails.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    if (!AdIds.adsSupported || AdIds.bannerAdUnitId.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load() async {
    if (!mounted) return;
    if (!AdIds.adsSupported || AdIds.bannerAdUnitId.isEmpty) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    AdSize size;
    try {
      final adaptive = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      size = adaptive ?? AdSize.banner;
    } catch (_) {
      size = AdSize.banner;
    }

    final banner = BannerAd(
      adUnitId: AdIds.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          final b = ad as BannerAd;
          setState(() {
            _banner = b;
            _height = size.height.toDouble();
          });
          unawaited(_refreshHeight(b));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    try {
      await banner.load();
    } catch (_) {
      await banner.dispose();
    }
  }

  Future<void> _refreshHeight(BannerAd ad) async {
    try {
      final platformSize = await ad.getPlatformAdSize();
      if (!mounted || platformSize == null) return;
      setState(() {
        _height = platformSize.height.toDouble();
      });
    } catch (_) {
      // Keep adaptive height from request.
    }
  }

  @override
  void dispose() {
    final b = _banner;
    _banner = null;
    if (b != null) {
      unawaited(b.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _banner;
    if (ad == null || _height <= 0) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: _height,
        color: Colors.transparent,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
