/// Placeholder for future ad integration. Does not depend on any ad SDK.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// No-op until a real SDK is wired in later.
  Future<void> initialize() async {
    _initialized = true;
  }

  void dispose() {
    _initialized = false;
  }
}
