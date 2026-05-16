import 'dart:math';

import 'game_config.dart';

/// Describes which board cells were used to build the current target (always solvable).
class TargetPick {
  TargetPick({required this.indices, required this.sum})
    : assert(indices.length >= 2);

  /// Distinct cell indices (0-based, row-major), sorted ascending.
  final List<int> indices;

  /// Sum of [board[i]] for i in [indices] — this becomes the round target.
  final int sum;
}

/// Picks distinct tiles and sets the target to their sum (always achievable).
///
/// Difficulty by **elapsed seconds in the classic round** ([elapsedSecondsInRound]):
/// - **0–20 s:** exactly **2** tiles
/// - **21–40 s:** **2 or 3** tiles
/// - **41–60 s:** **3 or 4** tiles
/// - **> 60 s:** same as 41–60 (round usually over; keeps behavior stable)
class TargetGenerator {
  TargetGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Legacy pick — does not guarantee a multiplier tile. Prefer
  /// [pickTargetIncludingMultiplier] for gameplay.
  TargetPick pickTarget(
    GameConfig config,
    List<int> board,
    int elapsedSecondsInRound,
  ) {
    if (board.length != config.tileCount) {
      throw ArgumentError(
        'Board length ${board.length} != ${config.tileCount}',
      );
    }

    final k = _pickK(elapsedSecondsInRound);

    final chosen = <int>{};
    while (chosen.length < k) {
      chosen.add(_random.nextInt(config.tileCount));
    }

    return _indicesToPick(board, chosen);
  }

  /// Builds a target whose solution always includes [multiplierTileId].
  TargetPick pickTargetIncludingMultiplier({
    required GameConfig config,
    required List<int> board,
    required int elapsedSecondsInRound,
    required int multiplierTileId,
  }) {
    if (board.length != config.tileCount) {
      throw ArgumentError(
        'Board length ${board.length} != ${config.tileCount}',
      );
    }
    if (multiplierTileId < 0 || multiplierTileId >= config.tileCount) {
      throw RangeError.range(
        multiplierTileId,
        0,
        config.tileCount - 1,
        'multiplierTileId',
      );
    }

    final k = _pickK(elapsedSecondsInRound);
    final chosen = <int>{multiplierTileId};
    final others = List<int>.generate(config.tileCount, (i) => i)
      ..remove(multiplierTileId);

    while (chosen.length < k && others.isNotEmpty) {
      final pick = _random.nextInt(others.length);
      chosen.add(others.removeAt(pick));
    }

    return _indicesToPick(board, chosen);
  }

  TargetPick _indicesToPick(List<int> board, Set<int> chosen) {
    final indices = chosen.toList()..sort();
    var sum = 0;
    for (final i in indices) {
      sum += board[i];
    }
    return TargetPick(indices: indices, sum: sum);
  }

  int _pickK(int elapsedSeconds) {
    final t = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    if (t <= 20) return 2;
    if (t <= 40) return 2 + _random.nextInt(2);
    return 3 + _random.nextInt(2);
  }
}
