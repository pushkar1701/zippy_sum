import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy_sum/app/app_router.dart';
import 'package:zippy_sum/game/game_config.dart';
import 'package:zippy_sum/game/game_controller.dart';
import 'package:zippy_sum/models/game_result.dart';
import 'package:zippy_sum/screens/onboarding_screen.dart';
import 'package:zippy_sum/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 10 settings & onboarding', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final p = await SharedPreferences.getInstance();
      await p.clear();
    });

    test('1. haptics default on; respects saved false', () async {
      expect(await LocalStorageService.instance.getHapticsEnabled(), isTrue);

      await LocalStorageService.instance.setHapticsEnabled(false);
      expect(await LocalStorageService.instance.getHapticsEnabled(), isFalse);

      SharedPreferences.setMockInitialValues({
        LocalStorageService.keyHapticsEnabled: false,
      });
      expect(await LocalStorageService.instance.getHapticsEnabled(), isFalse);
    });

    test('2. can save hapticsEnabled false', () async {
      await LocalStorageService.instance.setHapticsEnabled(false);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(LocalStorageService.keyHapticsEnabled), isFalse);
    });

    test('3. can save hapticsEnabled true', () async {
      await LocalStorageService.instance.setHapticsEnabled(false);
      await LocalStorageService.instance.setHapticsEnabled(true);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(LocalStorageService.keyHapticsEnabled), isTrue);
    });

    test('4. hasSeenOnboarding defaults to false', () async {
      expect(await LocalStorageService.instance.getHasSeenOnboarding(), isFalse);
    });

    testWidgets('5. Skip onboarding saves hasSeenOnboarding true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          routes: {
            AppRouter.onboarding: (_) => const OnboardingScreen(),
            AppRouter.home: (_) =>
                const Scaffold(body: Text('HOME_AFTER_ONBOARDING')),
          },
          initialRoute: AppRouter.onboarding,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final p = await SharedPreferences.getInstance();
      expect(p.getBool(LocalStorageService.keyHasSeenOnboarding), isTrue);
      expect(find.text('HOME_AFTER_ONBOARDING'), findsOneWidget);
    });

    test('6. resetStats does not reset hasSeenOnboarding', () async {
      await LocalStorageService.instance.setHasSeenOnboarding(true);
      await LocalStorageService.instance.recordClassicResult(
        GameResult(
          score: 50,
          targetsSolved: 3,
          mistakes: 1,
          bestCombo: 2,
          accuracy: 0.75,
          durationSeconds: 60,
          playedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await LocalStorageService.instance.resetStats();

      expect(await LocalStorageService.instance.getHasSeenOnboarding(), isTrue);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(LocalStorageService.keyHasSeenOnboarding), isTrue);
    });

    test('7. resetStats clears Classic stats', () async {
      await LocalStorageService.instance.recordClassicResult(
        GameResult(
          score: 99,
          targetsSolved: 10,
          mistakes: 2,
          bestCombo: 4,
          accuracy: 0.8,
          durationSeconds: 60,
          playedAt: DateTime.utc(2026, 6, 1),
        ),
      );
      await LocalStorageService.instance.resetStats();
      final s = await LocalStorageService.instance.loadStats();
      expect(s.bestClassicScore, 0);
      expect(s.totalGamesPlayed, 0);
      expect(s.totalTargetsSolved, 0);
      expect(s.totalMistakes, 0);
    });

    test('8. resetStats clears Daily stats', () async {
      await LocalStorageService.instance.recordDailyResult(
        GameResult(
          score: 40,
          targetsSolved: 2,
          mistakes: 0,
          bestCombo: 2,
          accuracy: 1,
          durationSeconds: 60,
          playedAt: DateTime.utc(2026, 6, 2),
        ),
        DateTime.utc(2026, 6, 2),
      );
      var s = await LocalStorageService.instance.loadStats();
      expect(s.bestDailyScore, greaterThan(0));

      await LocalStorageService.instance.resetStats();
      s = await LocalStorageService.instance.loadStats();
      expect(s.bestDailyScore, 0);
      expect(s.todayDailyBestScore, 0);
      expect(s.dailyStreak, 0);
      expect(s.lastDailyDateString, isNull);
    });
  });

  group('Step 10 game timer behavior', () {
    test('9. session time does not advance after round has ended', () {
      final game = GameController(
        config: const GameConfig(classicDurationSeconds: 2),
        random: Random(42),
      );
      game.tick(1000);
      game.tick(1000);
      expect(game.isRoundEnded, isTrue);
      expect(game.remainingSeconds, 0);

      final elapsedBefore = game.elapsedSeconds;
      game.tick(60_000);
      expect(game.elapsedSeconds, elapsedBefore);
      expect(game.remainingSeconds, 0);
    });

    test('10. rescheduling periodic timer cancels prior (no duplicate ticks)', () async {
      Timer? timer;
      var ticks = 0;
      void arm() {
        timer?.cancel();
        timer = Timer.periodic(const Duration(milliseconds: 40), (_) => ticks++);
      }

      arm();
      arm();
      await Future<void>.delayed(const Duration(milliseconds: 190));
      timer?.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Single timer ~190/40 ≈ 4–5 ticks; stacked timers would roughly double.
      expect(ticks, lessThan(8));
      expect(ticks, greaterThan(1));
    });
  });
}
