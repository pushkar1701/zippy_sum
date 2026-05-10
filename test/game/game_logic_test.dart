import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zippy_sum/game/board_generator.dart';
import 'package:zippy_sum/game/game_config.dart';
import 'package:zippy_sum/game/game_controller.dart';
import 'package:zippy_sum/game/scoring.dart';
import 'package:zippy_sum/game/target_generator.dart';
import 'package:zippy_sum/models/tile_model.dart';

const GameConfig _config = GameConfig();

/// Finds some 2–4 indices whose values sum to [target].
List<int>? findSubsetSummingTo(List<int> board, int target) {
  List<int>? result;
  void search(int i, List<int> acc, int sum) {
    if (result != null) return;
    final len = acc.length;
    if (len >= 2 && len <= 4 && sum == target) {
      result = List<int>.from(acc);
      return;
    }
    if (len >= 4 || i >= board.length) return;
    search(i + 1, acc, sum);
    acc.add(i);
    search(i + 1, acc, sum + board[i]);
    acc.removeLast();
  }

  search(0, <int>[], 0);
  return result;
}

void main() {
  group('BoardGenerator', () {
    test('creates exactly 16 tiles', () {
      final gen = BoardGenerator(random: Random(0));
      for (var seed = 0; seed < 10; seed++) {
        final board = gen.randomFlatBoard(_config);
        expect(board.length, _config.tileCount);
        expect(board.length, 16);
      }
    });

    test('tile values are always between 1 and 9', () {
      final gen = BoardGenerator(random: Random(42));
      for (var i = 0; i < 30; i++) {
        final board = gen.randomFlatBoard(_config);
        for (final v in board) {
          expect(v, inInclusiveRange(_config.minTileValue, _config.maxTileValue));
        }
      }
    });
  });

  group('TargetGenerator', () {
    test('always returns a target that can be made from the board', () {
      final gen = TargetGenerator(random: Random(7));
      final boardGen = BoardGenerator(random: Random(99));
      for (final elapsed in [0, 10, 25, 35, 55, 90]) {
        for (var i = 0; i < 20; i++) {
          final board = boardGen.randomFlatBoard(_config);
          final pick = gen.pickTarget(_config, board, elapsed);
          if (elapsed <= 20) {
            expect(pick.indices.length, 2);
          } else if (elapsed <= 40) {
            expect(pick.indices.length, anyOf(2, 3));
          } else {
            expect(pick.indices.length, anyOf(3, 4));
          }
          expect(pick.indices.toSet().length, pick.indices.length);
          var manual = 0;
          for (final idx in pick.indices) {
            manual += board[idx];
          }
          expect(pick.sum, manual);
          final subset = findSubsetSummingTo(board, pick.sum);
          expect(subset, isNotNull);
        }
      }
    });
  });

  group('Scoring', () {
    test('points = 100 + speedBonus + comboBonus', () {
      const config = GameConfig(
        maxSpeedBonus: 50,
        speedBonusZeroAtMs: 2000,
        comboBonusPerTier: 10,
      );
      expect(
        Scoring.pointsForCorrect(
          config: config,
          elapsedMsSinceTarget: 0,
          comboBeforeSolve: 1,
        ),
        100 + 50 + 0,
      );
      expect(
        Scoring.pointsForCorrect(
          config: config,
          elapsedMsSinceTarget: 2000,
          comboBeforeSolve: 1,
        ),
        100 + 0 + 0,
      );
      expect(
        Scoring.pointsForCorrect(
          config: config,
          elapsedMsSinceTarget: 0,
          comboBeforeSolve: 3,
        ),
        100 + 50 + (3 - 1) * 10,
      );
    });
  });

  group('GameController', () {
    test('tapping a tile updates current sum', () {
      final board = List<int>.filled(16, 9);
      final c = GameController(
        random: Random(0),
        debugInitialBoard: board,
      );
      expect(c.currentSum, 0);
      c.toggleTile(0);
      expect(c.currentSum, 9);
    });

    test('tapping a selected tile deselects it', () {
      final board = List<int>.filled(16, 3);
      final c = GameController(
        random: Random(0),
        debugInitialBoard: board,
      );
      c.toggleTile(2);
      expect(c.selectedIndices, contains(2));
      c.toggleTile(2);
      expect(c.selectedIndices, isEmpty);
      expect(c.currentSum, 0);
    });

    test('correct answer increases score', () {
      final board = List<int>.generate(16, (i) => 1 + (i % 5));
      final c = GameController(
        random: Random(11),
        debugInitialBoard: board,
      );
      final scoreBefore = c.score;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.score, greaterThan(scoreBefore));
    });

    test('correct answer increases solved count', () {
      final board = List<int>.generate(16, (i) => 2);
      final c = GameController(
        random: Random(3),
        debugInitialBoard: board,
      );
      final solvedBefore = c.solvedCount;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.solvedCount, solvedBefore + 1);
    });

    test('correct answer increases combo', () {
      final board = List<int>.generate(16, (i) => 2);
      final c = GameController(
        random: Random(3),
        debugInitialBoard: board,
      );
      final comboBefore = c.combo;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.combo, greaterThan(comboBefore));
    });

    test('too-high sum resets combo and marks mistake state', () {
      var found = false;
      for (var seed = 0; seed < 400; seed++) {
        final board = List<int>.generate(16, (i) => 4 + (i % 6));
        final c = GameController(random: Random(seed), debugInitialBoard: board);
        final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
        for (final i in subset) {
          c.toggleTile(i);
        }
        if (c.combo <= 1) continue;

        final t = c.target;
        int? heavy;
        for (var i = 0; i < 16; i++) {
          if (c.board[i] > t) {
            heavy = i;
            break;
          }
        }
        if (heavy == null) continue;

        expect(c.combo, greaterThan(1));
        c.toggleTile(heavy);
        expect(c.mistakeCount, greaterThanOrEqualTo(1));
        expect(c.combo, 1);
        expect(c.selectedIndices.isNotEmpty, isTrue);
        expect(c.mistakeActive, isTrue);
        final models = c.tileModels();
        for (final i in c.selectedIndices) {
          expect(models[i].state, TileState.mistake);
        }
        found = true;
        break;
      }
      expect(found, isTrue, reason: 'need seed where tile exceeds target after one solve');
    });

    test('clear deselects all selected tiles', () {
      GameController? c;
      for (var seed = 0; seed < 400; seed++) {
        final board = List<int>.filled(16, 1);
        final g = GameController(
          random: Random(seed),
          debugInitialBoard: board,
          initialSessionElapsedMs: 45000,
        );
        if (g.target != 4) continue;
        g.toggleTile(10);
        g.toggleTile(11);
        g.toggleTile(12);
        if (g.solvedCount != 0 || g.currentSum != 3) continue;
        c = g;
        break;
      }
      expect(c, isNotNull, reason: 'need target 4 on all-1s board');
      c!.clearSelection();
      expect(c.selectedIndices, isEmpty);
      expect(c.currentSum, 0);
      expect(c.mistakeActive, isFalse);
    });

    test('tick advances elapsed and remaining time', () {
      final c = GameController(random: Random(0), debugInitialBoard: List.filled(16, 5));
      expect(c.elapsedSeconds, 0);
      expect(c.remainingSeconds, 60);
      c.tick(5000);
      expect(c.elapsedSeconds, 5);
      expect(c.remainingSeconds, 55);
    });
  });
}
