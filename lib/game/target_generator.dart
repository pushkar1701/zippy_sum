import 'game_config.dart';

/// Picks a target sum for a board (placeholder).
class TargetGenerator {
  const TargetGenerator();

  int randomTarget(GameConfig config, List<List<int>> grid) {
    final flat = grid.expand((row) => row).toList();
    final avg = flat.isEmpty
        ? config.minTileValue
        : flat.reduce((a, b) => a + b) ~/ flat.length;
    final minSum = config.minTileValue * 2;
    final maxSum = config.maxTileValue * 2;
    return (avg * 2).clamp(minSum, maxSum);
  }
}
