import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/app.dart';
import 'services/ads_service.dart';
import 'services/consent_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the AdMob SDK first (required before any UMP call).
  await MobileAds.instance.initialize();

  // Request / refresh consent, then show the form if required.
  // ConsentService never throws — app always continues regardless of outcome.
  await ConsentService.instance.initialize();

  // Preload an interstitial only after consent is resolved.
  // AdsService.loadInterstitial() gates internally on canRequestAds().
  unawaited(AdsService.instance.loadInterstitial());

  runApp(const ZippySumApp());
}
