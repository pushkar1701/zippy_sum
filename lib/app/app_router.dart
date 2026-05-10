import 'package:flutter/material.dart';

import '../models/daily_complete_args.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../screens/classic_game_screen.dart';
import '../screens/daily_challenge_screen.dart';
import '../screens/daily_complete_screen.dart';
import '../screens/game_over_screen.dart';
import '../screens/home_screen.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/stats_screen.dart';

/// Named routes for navigation (no external router package).
abstract final class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String classicGame = '/classic';
  static const String gameOver = '/game-over';
  static const String dailyChallenge = '/daily';
  static const String dailyComplete = '/daily-complete';
  static const String stats = '/stats';
  static const String howToPlay = '/how-to-play';
  static const String settings = '/settings';

  static const String initialRoute = splash;

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    classicGame: _classicGameRoute,
    gameOver: _gameOverRoute,
    dailyChallenge: (_) => const DailyChallengeScreen(),
    dailyComplete: _dailyCompleteRoute,
    stats: (_) => const StatsScreen(),
    howToPlay: (_) => const HowToPlayScreen(),
    settings: (_) => const SettingsScreen(),
  };

  static Widget _classicGameRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final mode = args is GameMode ? args : GameMode.classic;
    return ClassicGameScreen(mode: mode);
  }

  static Widget _gameOverRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final result =
        args is GameResult ? args : GameResult.placeholder();
    return GameOverScreen(result: result);
  }

  static Widget _dailyCompleteRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DailyCompleteArgs) {
      return DailyCompleteScreen(args: args);
    }
    return DailyCompleteScreen.fallback();
  }
}
