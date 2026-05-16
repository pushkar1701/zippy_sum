import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zippy_sum/game/board_generator.dart';
import 'package:zippy_sum/game/game_config.dart';
import 'package:zippy_sum/game/game_controller.dart';
import 'package:zippy_sum/game/target_generator.dart';
import 'package:zippy_sum/models/tile_model.dart';

const GameConfig _config = GameConfig();

/// Finds 2–4 indices whose values sum to [target].
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

/// Controller right after a too-high mistake (combo was > 1 before tap).
GameController? _controllerAfterMistakeOverTarget() {
  for (var seed = 0; seed < 500; seed++) {
    final board = List<int>.generate(16, (i) => 4 + (i % 6));
    final c = GameController(random: Random(seed), debugInitialBoard: board);
    final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
    for (final i in subset) {
      c.toggleTile(i);
    }
    if (c.combo <= 1) continue;

    int? heavy;
    for (var i = 0; i < 16; i++) {
      if (c.board[i] > c.target) {
        heavy = i;
        break;
      }
    }
    if (heavy == null) continue;

    c.toggleTile(heavy);
    if (c.mistakeActive && c.selectedIndices.isNotEmpty && c.combo == 1) {
      return c;
    }
  }
  return null;
}

void main() {
  group('BoardGenerator', () {
    test('1. creates exactly 16 tiles', () {
      final gen = BoardGenerator(random: Random(1));
      for (var i = 0; i < 15; i++) {
        final board = gen.randomFlatBoard(_config);
        expect(board.length, 16);
        expect(board.length, _config.tileCount);
      }
    });

    test('2. every generated tile value is between 1 and 9', () {
      final gen = BoardGenerator(random: Random(2));
      for (var i = 0; i < 40; i++) {
        final board = gen.randomFlatBoard(_config);
        for (final v in board) {
          expect(v, inInclusiveRange(1, 9));
        }
      }
    });
  });

  group('TargetGenerator', () {
    test('3. always returns a target achievable from board values', () {
      final gen = TargetGenerator(random: Random(3));
      final boardGen = BoardGenerator(random: Random(4));
      for (final elapsed in [0, 15, 30, 50, 59]) {
        for (var i = 0; i < 25; i++) {
          final board = boardGen.randomFlatBoard(_config);
          final pick = gen.pickTarget(_config, board, elapsed);
          var manual = 0;
          for (final idx in pick.indices) {
            manual += board[idx];
          }
          expect(pick.sum, manual);
          expect(findSubsetSummingTo(board, pick.sum), isNotNull);
        }
      }
    });

    test('4. uses 2 tiles during early difficulty (0–20 s)', () {
      final gen = TargetGenerator(random: Random(5));
      final board = List<int>.filled(16, 5);
      for (final elapsed in [0, 5, 12, 20]) {
        for (var i = 0; i < 20; i++) {
          final pick = gen.pickTarget(_config, board, elapsed);
          expect(pick.indices.length, 2);
        }
      }
    });

    test('5. uses 2 or 3 tiles during middle difficulty (21–40 s)', () {
      final gen = TargetGenerator(random: Random(6));
      final board = List<int>.filled(16, 3);
      final seen = <int>{};
      for (final elapsed in [21, 30, 40]) {
        for (var i = 0; i < 40; i++) {
          final pick = gen.pickTarget(_config, board, elapsed);
          expect(pick.indices.length, isIn([2, 3]));
          seen.add(pick.indices.length);
        }
      }
      expect(seen.contains(2) || seen.contains(3), isTrue);
    });

    test('6. uses 3 or 4 tiles during late difficulty (41–60 s)', () {
      final gen = TargetGenerator(random: Random(7));
      final board = List<int>.filled(16, 2);
      final seen = <int>{};
      for (final elapsed in [41, 50, 60]) {
        for (var i = 0; i < 40; i++) {
          final pick = gen.pickTarget(_config, board, elapsed);
          expect(pick.indices.length, isIn([3, 4]));
          seen.add(pick.indices.length);
        }
      }
      expect(seen.contains(3) || seen.contains(4), isTrue);
    });
  });

  group('GameController', () {
    test('7. starts with valid board and valid target', () {
      final c = GameController(random: Random(100));
      expect(c.board.length, 16);
      for (final v in c.board) {
        expect(v, inInclusiveRange(1, 9));
      }
      expect(findSubsetSummingTo(List<int>.from(c.board), c.target), isNotNull);
      expect(c.target, greaterThanOrEqualTo(2));
    });

    test('8. tapping a tile selects it and updates currentSum', () {
      final c = GameController(
        random: Random(8),
        debugInitialBoard: List<int>.filled(16, 9),
      );
      expect(c.currentSum, 0);
      expect(c.selectedIndices, isEmpty);
      c.toggleTile(3);
      expect(c.selectedIndices, {3});
      expect(c.currentSum, 9);
    });

    test('9. tapping a selected tile deselects it and updates currentSum', () {
      GameController? c;
      for (var seed = 0; seed < 400; seed++) {
        final g = GameController(
          random: Random(seed),
          debugInitialBoard: List.filled(16, 1),
          initialSessionElapsedMs: 45000,
        );
        if (g.target != 4) continue;
        g.toggleTile(0);
        g.toggleTile(1);
        g.toggleTile(2);
        if (g.currentSum != 3 || g.solvedCount != 0) continue;
        c = g;
        break;
      }
      expect(c, isNotNull);
      c!.toggleTile(0);
      expect(c.selectedIndices, {1, 2});
      expect(c.currentSum, 2);
      c.toggleTile(1);
      expect(c.selectedIndices, {2});
      expect(c.currentSum, 1);
      c.toggleTile(2);
      expect(c.currentSum, 0);
    });

    test('10. clear deselects all tiles and clears mistake state', () {
      GameController? c;
      for (var seed = 0; seed < 400; seed++) {
        final g = GameController(
          random: Random(seed),
          debugInitialBoard: List.filled(16, 1),
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
      expect(c, isNotNull);
      c!.clearSelection();
      expect(c.selectedIndices, isEmpty);
      expect(c.currentSum, 0);
      expect(c.mistakeActive, isFalse);
    });

    test('11. correct answer increases score', () {
      final c = GameController(
        random: Random(11),
        debugInitialBoard: List<int>.generate(16, (i) => 1 + (i % 5)),
      );
      final before = c.score;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.score, greaterThan(before));
    });

    test('12. correct answer increases solved count', () {
      final c = GameController(
        random: Random(12),
        debugInitialBoard: List<int>.generate(16, (i) => 2),
      );
      final before = c.solvedCount;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.solvedCount, before + 1);
    });

    test('13. correct answer increases combo', () {
      final c = GameController(
        random: Random(13),
        debugInitialBoard: List<int>.generate(16, (i) => 2),
      );
      final before = c.combo;
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.combo, greaterThan(before));
    });

    test('14. correct answer replaces selected tiles with new values', () {
      var ok = false;
      for (var seed = 0; seed < 200; seed++) {
        final c = GameController(
          random: Random(seed),
          debugInitialBoard: List<int>.generate(16, (i) => 2),
        );
        final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
        final beforeVals = {for (final i in subset) i: c.board[i]};
        for (final i in subset) {
          c.toggleTile(i);
        }
        expect(c.solvedCount, 1);
        var anyDifferent = false;
        for (final i in subset) {
          if (c.board[i] != beforeVals[i]!) anyDifferent = true;
        }
        if (anyDifferent) {
          ok = true;
          break;
        }
      }
      expect(ok, isTrue, reason: 'RNG should change at least one cell (try more seeds if flaky)');
    });

    test('15. too-high sum resets combo to 1', () {
      final c = _controllerAfterMistakeOverTarget();
      expect(c, isNotNull);
      expect(c!.combo, 1);
    });

    test('16. too-high sum increments mistake count', () {
      final c = _controllerAfterMistakeOverTarget();
      expect(c, isNotNull);
      expect(c!.mistakeCount, greaterThanOrEqualTo(1));
    });

    test('17. too-high sum marks selected tiles as mistake state', () {
      final c = _controllerAfterMistakeOverTarget();
      expect(c, isNotNull);
      final models = c!.tileModels();
      for (final i in c.selectedIndices) {
        expect(models[i].state, TileState.mistake);
      }
    });

    test('18. too-high sum does not immediately clear selected tiles', () {
      final c = _controllerAfterMistakeOverTarget();
      expect(c, isNotNull);
      expect(c!.selectedIndices, isNotEmpty);
      expect(c.mistakeActive, isTrue);
    });

  });
}
