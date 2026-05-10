import 'game_result.dart';
import 'player_stats.dart';

/// Arguments for [DailyCompleteScreen] after a daily round ends.
class DailyCompleteArgs {
  const DailyCompleteArgs({
    required this.result,
    required this.stats,
  });

  final GameResult result;
  final PlayerStats stats;
}
