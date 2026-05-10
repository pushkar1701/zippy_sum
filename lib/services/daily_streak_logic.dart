import '../game/daily_seed.dart';

/// Pure streak rules for Daily Challenge (testable without prefs).
int computeNextDailyStreak({
  required DateTime completionDate,
  required String? lastDailyDateString,
  required int previousStreak,
}) {
  if (lastDailyDateString == null || lastDailyDateString.isEmpty) {
    return 1;
  }
  final todayKey = DailySeed.dateKey(completionDate);
  if (lastDailyDateString == todayKey) {
    return previousStreak;
  }
  final yesterday = DateTime(
    completionDate.year,
    completionDate.month,
    completionDate.day,
  ).subtract(const Duration(days: 1));
  final yesterdayKey = DailySeed.dateKey(yesterday);
  if (lastDailyDateString == yesterdayKey) {
    return previousStreak + 1;
  }
  return 1;
}
