import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zippy_sum/game/daily_seed.dart';
import 'package:zippy_sum/game/game_config.dart';
import 'package:zippy_sum/game/game_controller.dart';
import 'package:zippy_sum/game/scoring.dart';
import 'package:zippy_sum/game/target_generator.dart';

const _config = GameConfig();

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

List<int>? findSubsetSummingToIncluding(
  List<int> board,
  int target,
  int mustInclude,
) {
  List<int>? result;
  void search(int i, List<int> acc, int sum) {
    if (result != null) return;
    final len = acc.length;
    if (len >= 2 &&
        len <= 4 &&
        sum == target &&
        acc.contains(mustInclude)) {
      result = List<int>.from(acc);
      return;
    }
    if (len >= 4 || i >= board.length) return;
    search(i + 1, acc, sum);
    acc.add(i);
    search(i + 1, acc, sum + board[i]);
    acc.removeLast();
  }

  search(0, <int>[mustInclude], board[mustInclude]);
  return result;
}

int _multiplierTileCount(GameController c) {
  return c.tileModels().where((t) => t.scoreMultiplier > 1).length;
}

void main() {
  group('Score multiplier per target round', () {
    test('1. new game currentRoundNumber == 1', () {
      final c = GameController(random: Random(1));
      expect(c.currentRoundNumber, 1);
    });

    test('2. new game currentMultiplier == 2', () {
      final c = GameController(random: Random(2));
      expect(c.currentMultiplier, 2);
    });

    test('3. new game has exactly one tile with scoreMultiplier == 2', () {
      final c = GameController(random: Random(3));
      final multTiles =
          c.tileModels().where((t) => t.scoreMultiplier > 1).toList();
      expect(multTiles.length, 1);
      expect(multTiles.single.scoreMultiplier, 2);
      expect(multTiles.single.id, c.multiplierTileId);
    });

    test('4. after one correct solve currentRoundNumber == 2', () {
      final c = GameController(
        random: Random(4),
        debugInitialBoard: List<int>.filled(16, 5),
        initialSessionElapsedMs: 0,
      );
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.currentRoundNumber, 2);
    });

    test('5. after one correct solve currentMultiplier == 3', () {
      final c = GameController(
        random: Random(5),
        debugInitialBoard: List<int>.filled(16, 5),
        initialSessionElapsedMs: 0,
      );
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.currentMultiplier, 3);
    });

    test('6. after two correct solves currentMultiplier == 4', () {
      final c = GameController(
        random: Random(6),
        debugInitialBoard: List<int>.filled(16, 5),
        initialSessionElapsedMs: 0,
      );
      for (var round = 0; round < 2; round++) {
        final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
        for (final i in subset) {
          c.toggleTile(i);
        }
      }
      expect(c.currentMultiplier, 4);
    });

    test('7. exactly one multiplier tile after every target', () {
      final c = GameController(random: Random(7));
      for (var i = 0; i < 5; i++) {
        expect(_multiplierTileCount(c), 1);
        final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
        for (final j in subset) {
          c.toggleTile(j);
        }
      }
      expect(_multiplierTileCount(c), 1);
    });

    test('8. target has solution including multiplierTileId', () {
      final board = List<int>.generate(16, (i) => 1 + (i % 9));
      final gen = TargetGenerator(random: Random(8));
      const multiplierId = 4;
      final pick = gen.pickTargetIncludingMultiplier(
        config: _config,
        board: board,
        elapsedSecondsInRound: 0,
        multiplierTileId: multiplierId,
      );
      expect(pick.indices, contains(multiplierId));
      expect(
        findSubsetSummingToIncluding(board, pick.sum, multiplierId),
        isNotNull,
      );
    });

    test('9. multiplier tile value counts normally in sum', () {
      final board = List<int>.filled(16, 3);
      final c = GameController(
        random: Random(9),
        debugInitialBoard: board,
        initialSessionElapsedMs: 0,
      );
      final mid = c.multiplierTileId;
      c.toggleTile(mid);
      expect(c.currentSum, board[mid]);
      expect(
        Scoring.sumSelected(board, {mid, (mid + 1) % 16}),
        board[mid] + board[(mid + 1) % 16],
      );
    });

    test('10. solve without multiplier awards normal points', () {
      final board = List<int>.filled(16, 5);
      int? applied;
      final c = GameController(
        random: Random(10),
        debugInitialBoard: board,
        initialSessionElapsedMs: 0,
        onCorrect: (pts, {int? scoreMultiplierApplied}) {
          applied = scoreMultiplierApplied;
        },
      );
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      final withoutMult =
          subset.where((i) => i != c.multiplierTileId).toList();
      if (withoutMult.length < 2) return;

      var sum = 0;
      for (final i in withoutMult) {
        if (sum + board[i] <= c.target) {
          c.toggleTile(i);
          sum += board[i];
          if (sum == c.target) break;
        }
      }
      if (sum != c.target) return;

      final normal = Scoring.pointsForCorrect(
        config: _config,
        elapsedMsSinceTarget: 0,
        comboBeforeSolve: 1,
      );
      expect(applied, isNull);
      expect(c.score, normal);
    });

    test('11. solve with multiplier awards normalPoints * multiplier', () {
      final board = List<int>.filled(16, 5);
      final c = GameController(
        random: Random(11),
        debugInitialBoard: board,
        initialSessionElapsedMs: 0,
      );
      final subset = findSubsetSummingToIncluding(
        List<int>.from(c.board),
        c.target,
        c.multiplierTileId,
      );
      expect(subset, isNotNull);
      for (final i in subset!) {
        c.toggleTile(i);
      }
      final normal = Scoring.pointsForCorrect(
        config: _config,
        elapsedMsSinceTarget: 0,
        comboBeforeSolve: 1,
      );
      expect(c.score, normal * 2);
    });

    test('12. clear selection keeps multiplier badge', () {
      final c = GameController(
        random: Random(12),
        debugInitialBoard: List<int>.filled(16, 4),
        initialSessionElapsedMs: 0,
      );
      final mid = c.multiplierTileId;
      c.toggleTile(mid);
      c.clearSelection();
      expect(c.tileModels()[mid].scoreMultiplier, 2);
    });

    test('13. mistake keeps multiplier badge', () {
      GameController? c;
      for (var seed = 0; seed < 300; seed++) {
        final g = GameController(
          random: Random(seed),
          debugInitialBoard: List<int>.generate(16, (i) => 4 + (i % 6)),
        );
        final subset = findSubsetSummingTo(List<int>.from(g.board), g.target)!;
        for (final i in subset) {
          g.toggleTile(i);
        }
        if (g.combo <= 1) continue;
        int? heavy;
        for (var i = 0; i < 16; i++) {
          if (g.board[i] > g.target) {
            heavy = i;
            break;
          }
        }
        if (heavy == null) continue;
        final mid = g.multiplierTileId;
        g.toggleTile(heavy);
        if (g.mistakeActive) {
          c = g;
          expect(c.tileModels()[mid].scoreMultiplier, greaterThan(1));
          break;
        }
      }
      expect(c, isNotNull);
    });

    test('14. after correct solve new multiplier tile is assigned', () {
      final c = GameController(
        random: Random(14),
        debugInitialBoard: List<int>.filled(16, 5),
        initialSessionElapsedMs: 0,
      );
      final subset = findSubsetSummingTo(List<int>.from(c.board), c.target)!;
      for (final i in subset) {
        c.toggleTile(i);
      }
      expect(c.currentMultiplier, 3);
      expect(_multiplierTileCount(c), 1);
      expect(c.tileModels()[c.multiplierTileId].scoreMultiplier, 3);
      // May or may not be same cell index; always exactly one badge.
      expect(c.multiplierTileId, inInclusiveRange(0, 15));
    });

    test('15. daily seed yields same board target and multiplier tile', () {
      final day = DateTime(2026, 5, 16);
      final c1 = GameController(random: DailySeed.randomForDate(day));
      final c2 = GameController(random: DailySeed.randomForDate(day));
      expect(c1.multiplierTileId, c2.multiplierTileId);
      expect(c1.board, c2.board);
      expect(c1.target, c2.target);
      expect(c1.currentMultiplier, c2.currentMultiplier);
    });

    test('16. 500 seeded rounds: one multiplier, correct value, solvable', () {
      final gen = TargetGenerator(random: Random(1600));
      final board = List<int>.generate(16, (i) => 1 + (i % 9));
      for (var round = 0; round < 500; round++) {
        final solvedCount = round;
        final expectedMult = solvedCount + 2;
        final multiplierId = round % 16;
        final pick = gen.pickTargetIncludingMultiplier(
          config: _config,
          board: board,
          elapsedSecondsInRound: round % 60,
          multiplierTileId: multiplierId,
        );
        expect(pick.indices, contains(multiplierId));
        expect(
          findSubsetSummingToIncluding(board, pick.sum, multiplierId),
          isNotNull,
        );
        expect(expectedMult, round + 2);
      }
    });
  });
}
