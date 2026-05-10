import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy_sum/models/game_result.dart';
import 'package:zippy_sum/models/player_stats.dart';
import 'package:zippy_sum/services/local_storage_service.dart';

GameResult _classicResult({
  int score = 10,
  int targetsSolved = 2,
  int mistakes = 1,
  int bestCombo = 3,
  DateTime? playedAt,
}) {
  final t = playedAt ?? DateTime.utc(2026, 5, 10, 12);
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    await p.clear();
  });

  group('PlayerStats', () {
    test('1. default values are zero/null as expected', () {
      final s = PlayerStats.empty();
      expect(s.bestClassicScore, 0);
      expect(s.totalGamesPlayed, 0);
      expect(s.totalTargetsSolved, 0);
      expect(s.totalMistakes, 0);
      expect(s.bestCombo, 0);
      expect(s.lastPlayedAt, isNull);
      expect(s.lastDailyDateString, isNull);
      expect(s.dailyStreak, 0);
      expect(s.todayDailyBestScore, 0);
      expect(s.bestDailyScore, 0);
    });

    test('2. averageAccuracy returns 0 when there are no attempts', () {
      expect(PlayerStats.empty().averageAccuracy, 0);
      expect(
        const PlayerStats(
          totalTargetsSolved: 0,
          totalMistakes: 0,
        ).averageAccuracy,
        0,
      );
    });

    test('3. averageAccuracy calculates correctly when solved and mistakes exist', () {
      const s = PlayerStats(
        totalTargetsSolved: 3,
        totalMistakes: 1,
      );
      expect(s.averageAccuracy, 0.75);
    });
  });

  group('LocalStorageService.recordClassicResult', () {
    test('4. increments totalGamesPlayed', () async {
      await LocalStorageService.instance.recordClassicResult(_classicResult());
      var s = await LocalStorageService.instance.loadStats();
      expect(s.totalGamesPlayed, 1);

      await LocalStorageService.instance.recordClassicResult(_classicResult());
      s = await LocalStorageService.instance.loadStats();
      expect(s.totalGamesPlayed, 2);
    });

    test('5. updates totalTargetsSolved', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(targetsSolved: 5));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.totalTargetsSolved, 5);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(targetsSolved: 3));
      s = await LocalStorageService.instance.loadStats();
      expect(s.totalTargetsSolved, 8);
    });

    test('6. updates totalMistakes', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(mistakes: 2));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.totalMistakes, 2);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(mistakes: 4));
      s = await LocalStorageService.instance.loadStats();
      expect(s.totalMistakes, 6);
    });

    test('7. updates bestCombo to max of stored and result', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(bestCombo: 4));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.bestCombo, 4);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(bestCombo: 2));
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestCombo, 4);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(bestCombo: 7));
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestCombo, 7);
    });

    test('8. updates bestClassicScore when score is higher', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 50));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 50);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 120));
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 120);
    });

    test('9. does not lower bestClassicScore when score is lower', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 100));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 100);

      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 40));
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 100);
    });

    test('10. marks isNewBestScore true for a new best', () async {
      final first = await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 10));
      expect(first.result.isNewBestScore, isTrue);
      expect(first.result.bestScore, 10);

      final second = await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 25));
      expect(second.result.isNewBestScore, isTrue);
      expect(second.result.bestScore, 25);
    });

    test('11. marks isNewBestScore false when not a new best', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 100));

      final lower = await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 30));
      expect(lower.result.isNewBestScore, isFalse);
      expect(lower.result.bestScore, 100);

      final tie = await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 100));
      expect(tie.result.isNewBestScore, isFalse);
      expect(tie.result.bestScore, 100);
    });
  });

  group('LocalStorageService.resetStats', () {
    test('12. clears stats', () async {
      await LocalStorageService.instance
          .recordClassicResult(_classicResult(score: 42, targetsSolved: 8));
      var s = await LocalStorageService.instance.loadStats();
      expect(s.totalGamesPlayed, greaterThan(0));

      await LocalStorageService.instance.resetStats();
      s = await LocalStorageService.instance.loadStats();

      expect(s.bestClassicScore, 0);
      expect(s.totalGamesPlayed, 0);
      expect(s.totalTargetsSolved, 0);
      expect(s.totalMistakes, 0);
      expect(s.bestCombo, 0);
      expect(s.lastPlayedAt, isNull);
      expect(s.lastDailyDateString, isNull);
      expect(s.dailyStreak, 0);
      expect(s.todayDailyBestScore, 0);
      expect(s.bestDailyScore, 0);

      final p = await SharedPreferences.getInstance();
      expect(p.getString(LocalStorageService.keyPlayerStats), isNull);
      expect(p.getInt(LocalStorageService.keyBestClassicScore), 0);
      expect(p.getInt(LocalStorageService.keyGamesPlayed), 0);
    });
  });
}
