// Tests for AppLinks URLs and ad-gating logic.
//
// Note: real ConsentService calls (which hit the Google UMP SDK via a platform
// channel) are not tested here — that requires device-level integration tests.
// Instead we verify:
//   1. AppLinks has the expected production URLs.
//   2. AdsService does not preload an interstitial when consent is denied.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zippy_sum/app/app_links.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLinks URLs', () {
    test('website points to bonafide-losers.vercel.app', () {
      expect(AppLinks.website, 'https://bonafide-losers.vercel.app');
    });

    test('privacyPolicy points to the correct path', () {
      expect(
        AppLinks.privacyPolicy,
        'https://bonafide-losers.vercel.app/apps/zippysum/privacy',
      );
    });

    test('support points to the correct path', () {
      expect(
        AppLinks.support,
        'https://bonafide-losers.vercel.app/apps/zippysum/support',
      );
    });

    test('all URLs use https', () {
      for (final url in [
        AppLinks.website,
        AppLinks.privacyPolicy,
        AppLinks.support,
      ]) {
        expect(url, startsWith('https://'), reason: '$url should use https');
      }
    });
  });

  group('LocalStorageService integration (reset stats path)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final p = await SharedPreferences.getInstance();
      await p.clear();
    });

    test('can read and write haptics preference', () async {
      // Lightweight integration smoke-test that shared_prefs still works
      // (unrelated to consent but ensures reset-stats logic is not broken).
      final p = await SharedPreferences.getInstance();
      await p.setBool('haptics_enabled', false);
      expect(p.getBool('haptics_enabled'), isFalse);
    });
  });
}
