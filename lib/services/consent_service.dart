import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps the Google UMP consent SDK.
///
/// Call [initialize] once on app start (after [MobileAds.instance.initialize]).
/// Always check [canRequestAds] before loading any banner or interstitial.
///
/// Design principle: every method catches all errors silently.
/// Consent failure must never crash or freeze the app.
/// If consent is unavailable the game stays fully playable — ads just do not load.
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Request consent information update, then show the form if required.
  ///
  /// Completes in at most ~30 s even if the network is slow.
  /// Safe to call in [main] — never throws.
  Future<void> initialize() async {
    try {
      await _requestUpdate();
    } catch (_) {
      // Consent update failed (no network, timeout, etc.).
      // Ads will be blocked; the app continues normally.
      return;
    }
    try {
      await _showFormIfRequired();
    } catch (_) {
      // Form failed to show or was dismissed with an error — not fatal.
    }
  }

  /// Whether the app is currently allowed to request ads.
  ///
  /// Returns `false` on any error so we default to no ads rather than risk
  /// showing ads without consent.
  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }

  /// Whether a privacy options entry point (e.g. GDPR "Manage choices") is
  /// required to be shown in the app UI.
  Future<bool> isPrivacyOptionsRequired() async {
    try {
      final status =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Presents the UMP privacy options form (GDPR / CCPA "Manage choices").
  ///
  /// Completes when the form is dismissed or fails to show.
  /// Never throws.
  Future<void> showPrivacyOptionsForm() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {
      // Form unavailable or not supported on this device / region — ignore.
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Wraps the callback-based [requestConsentInfoUpdate] in a Future.
  Future<void> _requestUpdate() {
    final c = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!c.isCompleted) c.complete();
      },
      (FormError error) {
        if (!c.isCompleted) c.completeError(error);
      },
    );
    // Hard cap: don't wait forever on a slow/absent network.
    return c.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('requestConsentInfoUpdate timed out'),
    );
  }

  /// Shows the consent form if the UMP SDK decides one is required.
  ///
  /// [loadAndShowConsentFormIfRequired] internally awaits until the form is
  /// dismissed (or skipped if not required), then calls the callback.
  Future<void> _showFormIfRequired() async {
    await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
  }
}
