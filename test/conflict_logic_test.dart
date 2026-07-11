import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:queens/domain/models/game_level.dart';
import 'package:queens/domain/use_cases/cell_rules.dart';
import 'package:queens/domain/use_cases/level_generator.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';

/// Reference implementation: the original O(N^4) full-board conflict scan.
/// CellRules.computeConflicts must agree with this on every board.
List<List<bool>> referenceConflicts(
  List<List<CellState>> board,
  GameLevel level,
) {
  final n = level.gridSize;
  final conflicts = List.generate(n, (_) => List<bool>.filled(n, false));

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (board[i][j] == CellState.queen) {
        // Row
        for (int col = 0; col < n; col++) {
          if (col != j && board[i][col] == CellState.queen) {
            conflicts[i][j] = true;
            conflicts[i][col] = true;
          }
        }
        // Column
        for (int row = 0; row < n; row++) {
          if (row != i && board[row][j] == CellState.queen) {
            conflicts[i][j] = true;
            conflicts[row][j] = true;
          }
        }
        // Region
        final myRegion = level.colorRegions[i][j];
        for (int row = 0; row < n; row++) {
          for (int col = 0; col < n; col++) {
            if ((row != i || col != j) &&
                board[row][col] == CellState.queen &&
                level.colorRegions[row][col] == myRegion) {
              conflicts[i][j] = true;
              conflicts[row][col] = true;
            }
          }
        }
        // 8-way adjacency
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = i + dr;
            final nc = j + dc;
            if (nr >= 0 && nr < n && nc >= 0 && nc < n) {
              if (board[nr][nc] == CellState.queen) {
                conflicts[i][j] = true;
                conflicts[nr][nc] = true;
              }
            }
          }
        }
      }
    }
  }
  return conflicts;
}

void main() {
  final generator = LevelGenerator();

  test('computeConflicts matches the reference scan on random boards', () {
    final rng = Random(123);

    for (int levelNum = 1; levelNum <= 40; levelNum++) {
      final level = generator.generate(levelNum);
      final n = level.gridSize;

      // Try several random board fillings per level.
      for (int trial = 0; trial < 25; trial++) {
        final board = List.generate(
          n,
          (_) => List.generate(n, (_) {
            final r = rng.nextInt(5);
            // Bias toward queens so conflicts actually arise.
            return r == 0 ? CellState.queen : (r == 1 ? CellState.x : CellState.empty);
          }),
        );

        final expected = referenceConflicts(board, level);
        final actual = CellRules.computeConflicts(board, level);
        expect(actual, expected,
            reason: 'level $levelNum trial $trial mismatch');
      }
    }
  });

  test('the generator solution is conflict-free and complete', () {
    for (int levelNum = 1; levelNum <= 30; levelNum++) {
      final level = generator.generate(levelNum);
      final n = level.gridSize;
      final board = List.generate(
        n,
        (_) => List<CellState>.filled(n, CellState.empty),
      );
      for (int r = 0; r < n; r++) {
        board[r][level.solutionCols[r]] = CellState.queen;
      }

      final conflicts = CellRules.computeConflicts(board, level);
      for (final row in conflicts) {
        for (final cell in row) {
          expect(cell, isFalse, reason: 'level $levelNum has a conflict');
        }
      }
      expect(CellRules.isComplete(board, level), isTrue,
          reason: 'level $levelNum solution should be complete');
    }
  });

  test('suggestHint always returns a legal, unplaced cell on a fresh board', () {
    for (int levelNum = 1; levelNum <= 20; levelNum++) {
      final level = generator.generate(levelNum);
      final n = level.gridSize;
      final board = List.generate(
        n,
        (_) => List<CellState>.filled(n, CellState.empty),
      );
      final hint = CellRules.suggestHint(board, level);
      expect(hint, isNotNull, reason: 'level $levelNum hint');
      final r = hint![0];
      final c = hint[1];
      expect(board[r][c], CellState.empty);
      expect(r, inInclusiveRange(0, n - 1));
      expect(c, inInclusiveRange(0, n - 1));
    }
  });
}
