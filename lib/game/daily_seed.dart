import 'dart:math';

/// Deterministic daily challenge seed from calendar date (local).
abstract final class DailySeed {
  /// `YYYYMMDD`, e.g. 2026-05-10 → `20260510`.
  static String dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// Integer seed for [Random], same digits as [dateKey].
  static int randomSeed(DateTime date) => int.parse(dateKey(date));

  static Random randomForDate(DateTime date) => Random(randomSeed(date));
}
