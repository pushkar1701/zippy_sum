/// Tunable rules for classic ZippySum (4×4, digits 1–9, timed round).
class GameConfig {
  const GameConfig({
    this.gridSize = 4,
    this.minTileValue = 1,
    this.maxTileValue = 9,
    this.classicDurationSeconds = 60,
    this.maxSpeedBonus = 75,

    /// Elapsed ms on current target at which speed bonus hits zero (linear decay).
    this.speedBonusZeroAtMs = 4000,
    this.comboBonusPerTier = 12,
  }) : assert(gridSize > 0),
       assert(minTileValue <= maxTileValue);

  /// Edge length of the square grid (4 → 16 tiles).
  final int gridSize;

  int get tileCount => gridSize * gridSize;

  final int minTileValue;
  final int maxTileValue;

  /// Classic mode countdown length in seconds.
  final int classicDurationSeconds;

  /// Max extra points from answering quickly (see [Scoring.speedBonus]).
  final int maxSpeedBonus;
  final int speedBonusZeroAtMs;

  /// Added to score as `(comboBeforeSolve - 1) * comboBonusPerTier` (first solve → 0).
  final int comboBonusPerTier;
}
