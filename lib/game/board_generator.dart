import 'dart:math';

import 'game_config.dart';

/// Fills the grid with random digits in `[minTileValue, maxTileValue]`.
///
/// Pass the same [Random] as [TargetGenerator] and [GameController] for
/// reproducible boards (e.g. daily seed).
class BoardGenerator {
  BoardGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Flat row-major board of length `config.tileCount` (16 for default 4×4).
  List<int> randomFlatBoard(GameConfig config) {
    return List<int>.generate(config.tileCount, (_) => _rollTile(config));
  }

  int _rollTile(GameConfig config) {
    final span = config.maxTileValue - config.minTileValue + 1;
    return config.minTileValue + _random.nextInt(span);
  }
}
