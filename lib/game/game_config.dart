/// Tunable rules for boards and rounds.
class GameConfig {
  const GameConfig({
    this.gridRows = 4,
    this.gridColumns = 4,
    this.minTileValue = 1,
    this.maxTileValue = 9,
  });

  final int gridRows;
  final int gridColumns;
  final int minTileValue;
  final int maxTileValue;
}
