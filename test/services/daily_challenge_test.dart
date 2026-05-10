import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy_sum/game/daily_seed.dart';
import 'package:zippy_sum/models/game_result.dart';
import 'package:zippy_sum/services/daily_streak_logic.dart';
import 'package:zippy_sum/services/local_storage_service.dart';

GameResult _result({
  int score = 10,
  int targetsSolved = 1,
  int mistakes = 0,
  int bestCombo = 2,
  DateTime? playedAt,
}) {
  final t = playedAt ?? DateTime.utc(2026, 5, 10, 15);
  return GameResult(
    score: score,
    targetsSolved: targetsSolved,
    mistakes: mistakes,
    bestCombo: bestCombo,
    accuracy: GameResult.computeAccuracy(
      targetsSolved: targetsSolved,
      mistakes: mistakes,
    ),
    durationSeconds: 60,
    playedAt: t,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailySeed', () {
    test('date key and random seed match YYYYMMDD', () {
      expect(DailySeed.dateKey(DateTime(2026, 5, 10)), '20260510');
      expect(DailySeed.randomSeed(DateTime(2026, 5, 10)), 20260510);
    });
  });

  group('computeNextDailyStreak', () {
    final may10 = DateTime(2026, 5, 10);
    final may9Key = DailySeed.dateKey(DateTime(2026, 5, 9));
    final may10Key = DailySeed.dateKey(may10);

    test('starts at 1 on first daily play', () {
      expect(
        computeNextDailyStreak(
          completionDate: may10,
          lastDailyDateString: null,
          previousStreak: 0,
        ),
        1,
      );
      expect(
        computeNextDailyStreak(
          completionDate: may10,
          lastDailyDateString: '',
          previousStreak: 5,
        ),
        1,
      );
    });

    test('does not increment twice on the same day', () {
      expect(
        computeNextDailyStreak(
          completionDate: may10,
          lastDailyDateString: may10Key,
          previousStreak: 3,
        ),
        3,
      );
    });

    test('increments when previous daily was yesterday', () {
      expect(
        computeNextDailyStreak(
          completionDate: may10,
          lastDailyDateString: may9Key,
          previousStreak: 4,
        ),
        5,
      );
    });

    test('resets to 1 when previous daily was older than yesterday', () {
      expect(
        computeNextDailyStreak(
          completionDate: may10,
          lastDailyDateString: '20260501',
          previousStreak: 9,
        ),
        1,
      );
    });
  });

  group('LocalStorageService.recordDailyResult', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final p = await SharedPreferences.getInstance();
      await p.clear();
    });

    final dayA = DateTime(2026, 6, 1);

    test('todayDailyBestScore updates for a higher score', () async {
      await LocalStorageService.instance.recordDailyResult(_result(score: 20), dayA);
      var s = await LocalStorageService.instance.loadStats();
      expect(s.todayDailyBestScore, 20);

      await LocalStorageService.instance.recordDailyResult(_result(score: 45), dayA);
      s = await LocalStorageService.instance.loadStats();
      expect(s.todayDailyBestScore, 45);
    });

    test('todayDailyBestScore does not decrease after a lower replay', () async {
      await LocalStorageService.instance.recordDailyResult(_result(score: 50), dayA);
      await LocalStorageService.instance.recordDailyResult(_result(score: 12), dayA);
      final s = await LocalStorageService.instance.loadStats();
      expect(s.todayDailyBestScore, 50);
    });

    test('bestDailyScore updates correctly', () async {
      await LocalStorageService.instance.recordDailyResult(_result(score: 30), dayA);
      var s = await LocalStorageService.instance.loadStats();
      expect(s.bestDailyScore, 30);

      await LocalStorageService.instance
          .recordDailyResult(_result(score: 55), DateTime(2026, 6, 2));
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestDailyScore, 55);
    });

    test('Classic best score and Daily best score remain separate', () async {
      await LocalStorageService.instance.recordClassicResult(_result(score: 999));
      await LocalStorageService.instance.recordDailyResult(_result(score: 42), dayA);

      final s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 999);
      expect(s.bestDailyScore, 42);
      expect(s.totalGamesPlayed, 1);
    });

    test('daily streak stays same on two completions the same day', () async {
      final d = DateTime(2026, 8, 1);
      await LocalStorageService.instance.recordDailyResult(_result(score: 5), d);
      var s = await LocalStorageService.instance.loadStats();
      final streakAfterFirst = s.dailyStreak;

      await LocalStorageService.instance.recordDailyResult(_result(score: 8), d);
      s = await LocalStorageService.instance.loadStats();
      expect(s.dailyStreak, streakAfterFirst);
    });

    test('daily streak increments across consecutive calendar days', () async {
      await LocalStorageService.instance
          .recordDailyResult(_result(score: 1), DateTime(2026, 9, 1));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.dailyStreak, 1);

      await LocalStorageService.instance
          .recordDailyResult(_result(score: 2), DateTime(2026, 9, 2));
      s = await LocalStorageService.instance.loadStats();
      expect(s.dailyStreak, 2);
    });
  });
}
