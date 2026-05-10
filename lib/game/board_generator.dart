import 'dart:math';

import 'game_config.dart';

/// Builds random boards (placeholder implementation).
class BoardGenerator {
  BoardGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<List<int>> randomGrid(GameConfig config) {
    return List.generate(
      config.gridRows,
      (_) => List.generate(
        config.gridColumns,
        (_) => config.minTileValue +
            _random.nextInt(config.maxTileValue - config.minTileValue + 1),
      ),
    );
  }
}
