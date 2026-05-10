import 'dart:math' show max;

import 'package:shared_preferences/shared_preferences.dart';

import '../game/daily_seed.dart';
import '../models/game_result.dart';
import '../models/player_stats.dart';
import 'daily_streak_logic.dart';

/// Local persistence via [SharedPreferences] (stats + legacy keys).
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  /// JSON blob for [PlayerStats] (preferred).
  static const String keyPlayerStats = 'player_stats_v1';

  /// Legacy keys — migrated into [PlayerStats] on first load; still updated for compatibility.
  static const String keyBestClassicScore = 'best_classic_score';
  static const String keyGamesPlayed = 'games_played';

  /// Mirrors [PlayerStats.dailyStreak] for older readers.
  static const String keyDailyStreak = 'daily_streak';

  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyHapticsEnabled = 'haptics_enabled';
  static const String keySoundEffectsEnabled = 'sound_effects_enabled';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final p = await _prefs();
    return p.getInt(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    final p = await _prefs();
    await p.setInt(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final p = await _prefs();
    return p.getBool(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    final p = await _prefs();
    await p.setBool(key, value);
  }

  Future<bool> getHasSeenOnboarding() async =>
      getBool(keyHasSeenOnboarding, defaultValue: false);

  Future<void> setHasSeenOnboarding(bool value) async =>
      setBool(keyHasSeenOnboarding, value);

  /// Default on — players expect tactile feedback on phones.
  Future<bool> getHapticsEnabled() async =>
      getBool(keyHapticsEnabled, defaultValue: true);

  Future<void> setHapticsEnabled(bool value) async =>
      setBool(keyHapticsEnabled, value);

  Future<bool> getSoundEffectsEnabled() async =>
      getBool(keySoundEffectsEnabled, defaultValue: false);

  Future<void> setSoundEffectsEnabled(bool value) async =>
      setBool(keySoundEffectsEnabled, value);

  Future<PlayerStats> loadStats() async {
    final p = await _prefs();
    final raw = p.getString(keyPlayerStats);
    if (raw != null && raw.isNotEmpty) {
      try {
        return PlayerStats.fromJsonString(raw);
      } catch (_) {
        // fall through to legacy / empty
      }
    }
    final best = p.getInt(keyBestClassicScore) ?? 0;
    final played = p.getInt(keyGamesPlayed) ?? 0;
    final streak = p.getInt(keyDailyStreak) ?? 0;
    if (best == 0 && played == 0 && streak == 0) {
      return PlayerStats.empty();
    }
    return PlayerStats.empty().copyWith(
      bestClassicScore: best,
      totalGamesPlayed: played,
      dailyStreak: streak,
    );
  }

  Future<void> saveStats(PlayerStats stats) async {
    final p = await _prefs();
    await p.setString(keyPlayerStats, stats.toJsonString());
    await p.setInt(keyBestClassicScore, stats.bestClassicScore);
    await p.setInt(keyGamesPlayed, stats.totalGamesPlayed);
    await p.setInt(keyDailyStreak, stats.dailyStreak);
  }

  Future<void> resetStats() async {
    final p = await _prefs();
    await p.remove(keyPlayerStats);
    await p.setInt(keyBestClassicScore, 0);
    await p.setInt(keyGamesPlayed, 0);
    await p.setInt(keyDailyStreak, 0);
  }

  /// Updates persisted stats from one finished Classic round and returns enriched [GameResult].
  Future<({PlayerStats stats, GameResult result})> recordClassicResult(
    GameResult result,
  ) async {
    final existing = await loadStats();
    final isNewBest = result.score > existing.bestClassicScore;

    final updatedBestClassic = max(existing.bestClassicScore, result.score);
    final updatedBestCombo = max(existing.bestCombo, result.bestCombo);

    final newStats = existing.copyWith(
      bestClassicScore: updatedBestClassic,
      totalGamesPlayed: existing.totalGamesPlayed + 1,
      totalTargetsSolved: existing.totalTargetsSolved + result.targetsSolved,
      totalMistakes: existing.totalMistakes + result.mistakes,
      bestCombo: updatedBestCombo,
      lastPlayedAt: result.playedAt,
    );

    await saveStats(newStats);

    final enriched = result.copyWith(
      isNewBestScore: isNewBest,
      bestScore: updatedBestClassic,
    );

    return (stats: newStats, result: enriched);
  }

  /// Updates daily-only fields; does not change classic aggregates.
  Future<({PlayerStats stats, GameResult result})> recordDailyResult(
    GameResult result,
    DateTime date,
  ) async {
    final existing = await loadStats();
    final todayKey = DailySeed.dateKey(date);

    final newStreak = computeNextDailyStreak(
      completionDate: date,
      lastDailyDateString: existing.lastDailyDateString,
      previousStreak: existing.dailyStreak,
    );

    final todayBaseline = existing.lastDailyDateString == todayKey
        ? existing.todayDailyBestScore
        : 0;
    final newTodayBest = max(todayBaseline, result.score);
    final newBestDaily = max(existing.bestDailyScore, result.score);

    final newStats = existing.copyWith(
      lastDailyDateString: todayKey,
      dailyStreak: newStreak,
      todayDailyBestScore: newTodayBest,
      bestDailyScore: newBestDaily,
      lastPlayedAt: result.playedAt,
    );

    await saveStats(newStats);

    final enriched = result.copyWith(
      bestScore: newBestDaily,
      isNewBestScore: false,
    );

    return (stats: newStats, result: enriched);
  }
}
