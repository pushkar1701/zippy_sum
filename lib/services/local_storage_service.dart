import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for app settings and stats keys.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String keyBestClassicScore = 'best_classic_score';
  static const String keyGamesPlayed = 'games_played';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final p = await _prefs();
    return p.getInt(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    final p = await _prefs();
    await p.setInt(key, value);
  }
}
