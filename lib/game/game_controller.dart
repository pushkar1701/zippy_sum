import 'dart:math';

import 'board_generator.dart';
import 'game_config.dart';
import 'scoring.dart';
import 'target_generator.dart';
import '../models/tile_model.dart';

/// Classic ZippySum round state — plain Dart, no Flutter.
///
/// Each **target round** has exactly one score-multiplier tile:
/// multiplier = [solvedCount] + 2 (first target → 2×, second → 3×, …).
class GameController {
  GameController({
    GameConfig config = const GameConfig(),
    Random? random,
    BoardGenerator? boardGenerator,
    TargetGenerator? targetGenerator,
    this.onChanged,
    this.onCorrect,
    this.onMistake,
    List<int>? debugInitialBoard,
    int initialSessionElapsedMs = 0,
  }) : _config = config {
    final rng = random ?? Random();
    _random = rng;
    _sessionElapsedMs = initialSessionElapsedMs < 0
        ? 0
        : initialSessionElapsedMs;
    _boardGenerator = boardGenerator ?? BoardGenerator(random: rng);
    _targetGenerator = targetGenerator ?? TargetGenerator(random: rng);

    if (debugInitialBoard != null) {
      if (debugInitialBoard.length != config.tileCount) {
        throw ArgumentError(
          'debugInitialBoard length ${debugInitialBoard.length} '
          'must equal tileCount ${config.tileCount}',
        );
      }
      _board = List<int>.from(debugInitialBoard);
      _beginNewTargetRound();
    } else {
      _bootstrapBoardAndTarget();
    }
  }

  final GameConfig _config;
  late final Random _random;
  late final BoardGenerator _boardGenerator;
  late final TargetGenerator _targetGenerator;

  void Function()? onChanged;

  /// [scoreMultiplierApplied] is set when the solve included the multiplier tile.
  void Function(int pointsEarned, {int? scoreMultiplierApplied})? onCorrect;

  void Function()? onMistake;

  late List<int> _board;
  final Set<int> _selected = <int>{};

  bool _mistakeActive = false;

  int _target = 0;
  int _score = 0;

  int _combo = 1;
  int _bestCombo = 1;
  int _solvedCount = 0;
  int _mistakeCount = 0;

  late int _sessionElapsedMs;
  int _targetElapsedMs = 0;

  /// Index of the only multiplier tile for the current target round.
  int _multiplierTileId = 0;

  GameConfig get config => _config;

  /// Target round number within the session (1-based): [solvedCount] + 1.
  int get currentRoundNumber => _solvedCount + 1;

  /// Score multiplier for the current target round: [solvedCount] + 2.
  int get currentMultiplier => _solvedCount + 2;

  int get multiplierTileId => _multiplierTileId;

  int get elapsedSeconds => _sessionElapsedMs ~/ 1000;

  int get remainingSeconds {
    final r = _config.classicDurationSeconds - elapsedSeconds;
    return r < 0 ? 0 : r;
  }

  double get secondsOnCurrentTarget => _targetElapsedMs / 1000.0;

  bool get isRoundEnded => remainingSeconds <= 0;

  bool get mistakeActive => _mistakeActive;

  List<int> get board => List.unmodifiable(_board);

  Set<int> get selectedIndices => Set.unmodifiable(_selected);

  int get target => _target;
  int get score => _score;
  int get combo => _combo;
  int get bestCombo => _bestCombo;
  int get solvedCount => _solvedCount;
  int get mistakeCount => _mistakeCount;

  int get currentSum => Scoring.sumSelected(_board, _selected);

  void tick(int deltaMilliseconds) {
    if (deltaMilliseconds <= 0) return;
    if (isRoundEnded) {
      _notify();
      return;
    }
    _sessionElapsedMs += deltaMilliseconds;
    _targetElapsedMs += deltaMilliseconds;
    _notify();
  }

  List<TileModel> tileModels() {
    return List<TileModel>.generate(_config.tileCount, (i) {
      final selected = _selected.contains(i);
      final TileState state;
      if (isRoundEnded) {
        state = TileState.disabled;
      } else if (_mistakeActive && selected) {
        state = TileState.mistake;
      } else if (selected) {
        state = TileState.selected;
      } else {
        state = TileState.normal;
      }
      return TileModel(
        id: i,
        value: _board[i],
        isSelected: selected,
        state: state,
        scoreMultiplier: i == _multiplierTileId ? currentMultiplier : 1,
      );
    });
  }

  void _notify() => onChanged?.call();

  void _bootstrapBoardAndTarget() {
    _board = _boardGenerator.randomFlatBoard(_config);
    _beginNewTargetRound();
  }

  void _beginNewTargetRound() {
    _multiplierTileId = _random.nextInt(_config.tileCount);
    final pick = _targetGenerator.pickTargetIncludingMultiplier(
      config: _config,
      board: _board,
      elapsedSecondsInRound: elapsedSeconds,
      multiplierTileId: _multiplierTileId,
    );
    _applyNewTarget(pick);
  }

  void _applyNewTarget(TargetPick pick) {
    _target = pick.sum;
    _targetElapsedMs = 0;
  }

  void resetSession() {
    _score = 0;
    _combo = 1;
    _bestCombo = 1;
    _solvedCount = 0;
    _mistakeCount = 0;
    _sessionElapsedMs = 0;
    _targetElapsedMs = 0;
    _selected.clear();
    _mistakeActive = false;
    _bootstrapBoardAndTarget();
    _notify();
  }

  void newRoundKeepProgress() {
    _selected.clear();
    _mistakeActive = false;
    _bootstrapBoardAndTarget();
    _notify();
  }

  void clearSelection() {
    _mistakeActive = false;
    _selected.clear();
    _notify();
  }

  void toggleTile(int index) {
    if (index < 0 || index >= _config.tileCount) {
      throw RangeError.range(index, 0, _config.tileCount - 1, 'index');
    }
    if (isRoundEnded) return;

    if (_mistakeActive) {
      if (!_selected.contains(index)) {
        return;
      }
      _selected.remove(index);
      final sum = currentSum;
      if (sum == _target) {
        _mistakeActive = false;
        _handleCorrect();
        return;
      }
      if (sum < _target) {
        _mistakeActive = false;
      }
      _notify();
      return;
    }

    if (_selected.contains(index)) {
      _selected.remove(index);
      _notify();
      return;
    }

    _selected.add(index);
    final sum = currentSum;

    if (sum > _target) {
      _mistakeActive = true;
      _mistakeCount++;
      _combo = 1;
      onMistake?.call();
      _notify();
      return;
    }

    if (sum == _target) {
      _handleCorrect();
      return;
    }

    _notify();
  }

  void _handleCorrect() {
    final elapsed = _targetElapsedMs;
    final comboBeforeIncrement = _combo;
    final selected = List<int>.from(_selected);
    final usedMultiplier = selected.contains(_multiplierTileId);
    final scoreMult = currentMultiplier;

    final normalPoints = Scoring.pointsForCorrect(
      config: _config,
      elapsedMsSinceTarget: elapsed,
      comboBeforeSolve: comboBeforeIncrement,
    );
    final gained = Scoring.applyScoreMultiplier(
      normalPoints: normalPoints,
      scoreMultiplier: scoreMult,
      usedMultiplierTile: usedMultiplier,
    );

    _score += gained;
    _combo++;
    if (_combo > _bestCombo) {
      _bestCombo = _combo;
    }
    _solvedCount++;
    _mistakeActive = false;

    onCorrect?.call(
      gained,
      scoreMultiplierApplied: usedMultiplier ? scoreMult : null,
    );

    for (final i in selected) {
      _board[i] = _rollTileValue();
    }
    _selected.clear();

    _beginNewTargetRound();
    _notify();
  }

  int _rollTileValue() {
    final span = _config.maxTileValue - _config.minTileValue + 1;
    return _config.minTileValue + _random.nextInt(span);
  }
}
