import 'dart:math';

import 'board_generator.dart';
import 'game_config.dart';
import 'scoring.dart';
import 'target_generator.dart';
import '../models/tile_model.dart';

/// Classic ZippySum round state — plain Dart, no Flutter.
///
/// Drive time with [tick]. Pass a single [Random] so [BoardGenerator],
/// [TargetGenerator], and tile re-rolls stay on the same sequence (e.g. seeded
/// daily challenge). Optional [boardGenerator] / [targetGenerator] must use that
/// same [Random] if you pass them explicitly.
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
    _sessionElapsedMs = initialSessionElapsedMs < 0 ? 0 : initialSessionElapsedMs;
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
      _applyNewTarget(
        _targetGenerator.pickTarget(_config, _board, elapsedSeconds),
      );
    } else {
      _bootstrapBoardAndTarget();
    }
  }

  final GameConfig _config;
  late final Random _random;
  late final BoardGenerator _boardGenerator;
  late final TargetGenerator _targetGenerator;

  /// Optional notify hook for UI layers.
  void Function()? onChanged;

  /// Fired after a correct solve with points earned this solve (before [onChanged]).
  void Function(int pointsEarned)? onCorrect;

  /// Fired when selection goes over the target (before [onChanged]).
  void Function()? onMistake;

  late List<int> _board;
  final Set<int> _selected = <int>{};

  /// After sum > target: selections stay until user deselects or [clearSelection].
  bool _mistakeActive = false;

  int _target = 0;
  int _score = 0;

  int _combo = 1;
  int _bestCombo = 1;
  int _solvedCount = 0;
  int _mistakeCount = 0;

  late int _sessionElapsedMs;
  int _targetElapsedMs = 0;

  GameConfig get config => _config;

  /// Floored whole seconds since the classic round started.
  int get elapsedSeconds => _sessionElapsedMs ~/ 1000;

  /// Floored countdown seconds left in the classic round (never negative).
  int get remainingSeconds {
    final r = _config.classicDurationSeconds - elapsedSeconds;
    return r < 0 ? 0 : r;
  }

  /// Fractional seconds since the current target was set.
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

  /// One model per cell: [id], [value], [isSelected], and [state].
  ///
  /// During play: [TileState.normal], [TileState.selected], or [TileState.mistake]
  /// for selected cells while [mistakeActive]. When the round has ended, all tiles
  /// use [TileState.disabled].
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
      );
    });
  }

  void _notify() => onChanged?.call();

  void _bootstrapBoardAndTarget() {
    _board = _boardGenerator.randomFlatBoard(_config);
    _applyNewTarget(
      _targetGenerator.pickTarget(_config, _board, elapsedSeconds),
    );
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

  /// Clears selection and mistake state (sum returns to 0); notifies listeners.
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

    final gained = Scoring.pointsForCorrect(
      config: _config,
      elapsedMsSinceTarget: elapsed,
      comboBeforeSolve: comboBeforeIncrement,
    );

    _score += gained;
    _combo++;
    if (_combo > _bestCombo) {
      _bestCombo = _combo;
    }
    _solvedCount++;
    _mistakeActive = false;

    onCorrect?.call(gained);

    for (final i in List<int>.from(_selected)) {
      _board[i] = _rollTileValue();
    }
    _selected.clear();

    _applyNewTarget(
      _targetGenerator.pickTarget(_config, _board, elapsedSeconds),
    );
    _notify();
  }

  int _rollTileValue() {
    final span = _config.maxTileValue - _config.minTileValue + 1;
    return _config.minTileValue + _random.nextInt(span);
  }
}
