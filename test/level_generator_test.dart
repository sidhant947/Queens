import 'package:flutter_test/flutter_test.dart';

import 'package:queens/domain/models/game_level.dart';
import 'package:queens/domain/use_cases/level_generator.dart';

/// Validates the queen placement encoded by [solutionCols]: exactly one queen
/// per row, no shared columns, and no 8-way-adjacent queens.
bool isValidSolution(List<int> cols, int n) {
  if (cols.length != n) return false;
  for (int r = 0; r < n; r++) {
    if (cols[r] < 0 || cols[r] >= n) return false;
    for (int p = 0; p < r; p++) {
      if (cols[p] == cols[r]) return false; // same column
      if ((r - p) == 1 && (cols[r] - cols[p]).abs() <= 1) {
        return false; // touching (adjacent rows)
      }
    }
  }
  return true;
}

/// Each colour region must be a single 4-connected component.
bool regionsAreConnected(GameLevel level) {
  final n = level.gridSize;
  final seen = List.generate(n, (_) => List<bool>.filled(n, false));

  for (int region = 0; region < n; region++) {
    // Find first cell of this region.
    int sr = -1, sc = -1;
    for (int r = 0; r < n && sr == -1; r++) {
      for (int c = 0; c < n; c++) {
        if (level.colorRegions[r][c] == region) {
          sr = r;
          sc = c;
          break;
        }
      }
    }
    if (sr == -1) return false; // region missing entirely

    // Flood fill.
    final stack = [
      [sr, sc]
    ];
    int count = 0;
    while (stack.isNotEmpty) {
      final cell = stack.removeLast();
      final r = cell[0], c = cell[1];
      if (r < 0 || r >= n || c < 0 || c >= n) continue;
      if (seen[r][c]) continue;
      if (level.colorRegions[r][c] != region) continue;
      seen[r][c] = true;
      count++;
      stack.add([r - 1, c]);
      stack.add([r + 1, c]);
      stack.add([r, c - 1]);
      stack.add([r, c + 1]);
    }

    // Total cells of this region across the whole grid.
    int total = 0;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (level.colorRegions[r][c] == region) total++;
      }
    }
    if (count != total || total == 0) return false;
  }
  return true;
}

void main() {
  final generator = LevelGenerator();

  test('generated levels are deterministic per level number', () {
    final a = generator.generate(7);
    final b = generator.generate(7);
    expect(a.gridSize, b.gridSize);
    expect(a.solutionCols, b.solutionCols);
    expect(a.colorRegions, b.colorRegions);
  });

  test('every generated level has a valid solution and connected regions', () {
    for (int level = 1; level <= 160; level++) {
      final game = generator.generate(level);
      final n = game.gridSize;

      expect(game.solutionCols.length, n, reason: 'level $level queen count');
      expect(isValidSolution(game.solutionCols, n), isTrue,
          reason: 'level $level solution validity');

      // Exactly one queen per colour region (queen at (r, solutionCols[r])).
      final regionsHit = <int>{};
      for (int r = 0; r < n; r++) {
        regionsHit.add(game.colorRegions[r][game.solutionCols[r]]);
      }
      expect(regionsHit.length, n, reason: 'level $level one queen per region');

      expect(regionsAreConnected(game), isTrue,
          reason: 'level $level region connectivity');
      expect(game.regionColors.length, n, reason: 'level $level colour count');
    }
  });

  test('grid size scales with level number', () {
    expect(generator.generate(1).gridSize, 5);
    expect(generator.generate(6).gridSize, 6);
    expect(generator.generate(150).gridSize, 16);
  });

  test('random levels honour requested grid size', () {
    final game = generator.generateRandom(gridSize: 8, seed: 42);
    expect(game.gridSize, 8);
    expect(isValidSolution(game.solutionCols, 8), isTrue);
  });
}
