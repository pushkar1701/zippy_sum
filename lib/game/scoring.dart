import 'game_config.dart';

/// Pure helpers for sums and points (no game state).
abstract final class Scoring {
  /// Sum of board values at the given indices.
  static int sumSelected(List<int> board, Iterable<int> indices) {
    var s = 0;
    for (final i in indices) {
      s += board[i];
    }
    return s;
  }

  /// Linear speed bonus: full [maxSpeedBonus] at t=0, 0 at `speedBonusZeroAtMs`.
  static int speedBonus(GameConfig config, int elapsedMsSinceTarget) {
    if (config.maxSpeedBonus <= 0 || config.speedBonusZeroAtMs <= 0) {
      return 0;
    }
    final t = elapsedMsSinceTarget.clamp(0, config.speedBonusZeroAtMs);
    final ratio = 1.0 - (t / config.speedBonusZeroAtMs);
    return (config.maxSpeedBonus * ratio).round();
  }

  /// **points = 100 + speedBonus + comboBonus**
  ///
  /// [comboBeforeSolve] is the combo multiplier *before* this correct answer
  /// (starts at 1). Combo bonus is `(comboBeforeSolve - 1) * comboBonusPerTier`.
  static int pointsForCorrect({
    required GameConfig config,
    required int elapsedMsSinceTarget,
    required int comboBeforeSolve,
  }) {
    const base = 100;
    final speed = speedBonus(config, elapsedMsSinceTarget);
    final comboExtra = (comboBeforeSolve - 1).clamp(0, 999) * config.comboBonusPerTier;
    return base + speed + comboExtra;
  }
}
