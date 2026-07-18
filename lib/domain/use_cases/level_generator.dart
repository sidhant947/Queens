import 'dart:math';
import 'package:material_ui/material_ui.dart';

import 'package:queens/domain/models/game_level.dart';
import 'package:queens/ui/core/theme/app_colors.dart';

class LevelGenerator {
  GameLevel generate(int levelNumber) {
    final random = Random(levelNumber);
    final gridSize = _getGridSize(levelNumber);
    return _generateLevelWithSeed(levelNumber, gridSize, random);
  }

  GameLevel generateRandom({required int gridSize, required int seed}) {
    final random = Random(seed);
    return _generateLevelWithSeed(-1, gridSize, random);
  }

  int _getGridSize(int level) {
    if (level <= 5) return 5;
    if (level <= 15) return 6;
    if (level <= 30) return 7;
    if (level <= 45) return 8;
    if (level <= 60) return 9;
    if (level <= 75) return 10;
    if (level <= 90) return 11;
    if (level <= 105) return 12;
    if (level <= 120) return 13;
    if (level <= 135) return 14;
    if (level <= 149) return 15;
    return 16;
  }

  GameLevel _generateLevelWithSeed(int levelNumber, int gridSize, Random random) {
    var queenCols = List<int>.filled(gridSize, -1);
    var colorRegions = List.generate(gridSize, (_) => List<int>.filled(gridSize, -1));
    var finalColors = <Color>[];

    int attempt = 0;
    while (true) {
      attempt++;
      // Generate a deterministic sub-random seed per attempt for campaign levels,
      // and a normal random seed for random mode levels.
      final subSeed = levelNumber >= 0
          ? (levelNumber * 1000 + attempt)
          : random.nextInt(1000000);
      final subRandom = Random(subSeed);

      // 1. Solve N-queens placement
      queenCols = List<int>.filled(gridSize, -1);
      final solved = _solveQueens(0, gridSize, queenCols, subRandom);
      if (!solved) continue;

      // 2. Clear and set initial region cells containing the queens
      colorRegions = List.generate(gridSize, (_) => List<int>.filled(gridSize, -1));
      for (int r = 0; r < gridSize; r++) {
        colorRegions[r][queenCols[r]] = r;
      }

      final regionSizes = List<int>.filled(gridSize, 1);

      // 3. Grow connected color regions
      while (true) {
        final candidates = <_GrowthCandidate>[];
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            if (colorRegions[r][c] == -1) {
              final neighbors = [
                Point(r - 1, c),
                Point(r + 1, c),
                Point(r, c - 1),
                Point(r, c + 1),
              ];
              final adjacentRegions = <int>{};
              for (final p in neighbors) {
                if (p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize) {
                  final reg = colorRegions[p.x][p.y];
                  if (reg != -1) {
                    adjacentRegions.add(reg);
                  }
                }
              }
              for (final reg in adjacentRegions) {
                candidates.add(_GrowthCandidate(r, c, reg));
              }
            }
          }
        }

        if (candidates.isEmpty) break;

        candidates.shuffle(subRandom);
        candidates.sort((a, b) => regionSizes[a.region].compareTo(regionSizes[b.region]));

        final choice = candidates.first;
        colorRegions[choice.r][choice.c] = choice.region;
        regionSizes[choice.region]++;
      }

      // 4. Mutate partition to eliminate alternative solutions
      bool success = false;
      int mutations = 0;
      while (mutations < 150) {
        final altSolution = _findAlternativeSolution(gridSize, colorRegions, queenCols);
        if (altSolution == null) {
          success = true;
          break;
        }

        final diffCells = <Point<int>>[];
        for (int r = 0; r < gridSize; r++) {
          if (altSolution[r] != queenCols[r]) {
            diffCells.add(Point(r, altSolution[r]));
          }
        }

        diffCells.shuffle(subRandom);
        bool mutated = false;

        for (final cell in diffCells) {
          final r = cell.x;
          final c = cell.y;
          final currentRegion = colorRegions[r][c];

          // Cannot reassign the cell containing the target solution's queen
          if (queenCols[currentRegion] == c && currentRegion == r) {
            continue;
          }

          if (!_isRegionConnectedWithoutCell(gridSize, colorRegions, currentRegion, r, c, queenCols)) {
            continue;
          }

          final neighbors = [
            Point(r - 1, c),
            Point(r + 1, c),
            Point(r, c - 1),
            Point(r, c + 1),
          ];
          neighbors.shuffle(subRandom);

          for (final n in neighbors) {
            if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize) {
              final neighborRegion = colorRegions[n.x][n.y];
              if (neighborRegion != currentRegion) {
                colorRegions[r][c] = neighborRegion;
                mutations++;
                mutated = true;
                break;
              }
            }
          }
          if (mutated) break;
        }

        if (!mutated) {
          break;
        }
      }

      if (success) {
        finalColors = _pickColors(gridSize, subRandom);
        break;
      }
    }

    return GameLevel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      colorRegions: colorRegions,
      regionColors: finalColors,
      solutionCols: List<int>.unmodifiable(queenCols),
    );
  }

  bool _isRegionConnectedWithoutCell(
    int gridSize,
    List<List<int>> colorRegions,
    int region,
    int removeR,
    int removeC,
    List<int> queenCols,
  ) {
    final seedR = region;
    final seedC = queenCols[region];
    if (seedR == removeR && seedC == removeC) return false;

    final visited = List.generate(gridSize, (_) => List<bool>.filled(gridSize, false));
    int count = 0;
    final queue = [Point(seedR, seedC)];
    visited[seedR][seedC] = true;

    while (queue.isNotEmpty) {
      final curr = queue.removeLast();
      count++;

      final neighbors = [
        Point(curr.x - 1, curr.y),
        Point(curr.x + 1, curr.y),
        Point(curr.x, curr.y - 1),
        Point(curr.x, curr.y + 1),
      ];

      for (final n in neighbors) {
        if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize) {
          if (!visited[n.x][n.y] && colorRegions[n.x][n.y] == region) {
            if (n.x == removeR && n.y == removeC) continue;
            visited[n.x][n.y] = true;
            queue.add(n);
          }
        }
      }
    }

    int total = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (colorRegions[r][c] == region) {
          if (r == removeR && c == removeC) continue;
          total++;
        }
      }
    }

    return count == total;
  }

  List<int>? _findAlternativeSolution(
    int gridSize,
    List<List<int>> colorRegions,
    List<int> targetSolution,
  ) {
    final colsUsed = List<bool>.filled(gridSize, false);
    final regionsUsed = List<bool>.filled(gridSize, false);
    final queenCols = List<int>.filled(gridSize, -1);
    List<int>? alternative;

    void solve(int row) {
      if (alternative != null) return;

      if (row == gridSize) {
        bool different = false;
        for (int i = 0; i < gridSize; i++) {
          if (queenCols[i] != targetSolution[i]) {
            different = true;
            break;
          }
        }
        if (different) {
          alternative = List.from(queenCols);
        }
        return;
      }

      final targetCol = targetSolution[row];

      for (int col = 0; col < gridSize; col++) {
        if (col == targetCol) continue;

        final region = colorRegions[row][col];
        if (colsUsed[col] || regionsUsed[region]) continue;

        if (row > 0) {
          final prevCol = queenCols[row - 1];
          if ((col - prevCol).abs() <= 1) continue;
        }

        colsUsed[col] = true;
        regionsUsed[region] = true;
        queenCols[row] = col;

        solve(row + 1);

        colsUsed[col] = false;
        regionsUsed[region] = false;
        queenCols[row] = -1;
      }

      if (targetCol >= 0 && targetCol < gridSize) {
        final col = targetCol;
        final region = colorRegions[row][col];
        if (!colsUsed[col] && !regionsUsed[region]) {
          if (row > 0) {
            final prevCol = queenCols[row - 1];
            if ((col - prevCol).abs() <= 1) return;
          }

          colsUsed[col] = true;
          regionsUsed[region] = true;
          queenCols[row] = col;

          solve(row + 1);

          colsUsed[col] = false;
          regionsUsed[region] = false;
          queenCols[row] = -1;
        }
      }
    }

    solve(0);
    return alternative;
  }

  int _countSolutions(int gridSize, List<List<int>> colorRegions) {

    int solutions = 0;
    final colsUsed = List<bool>.filled(gridSize, false);
    final regionsUsed = List<bool>.filled(gridSize, false);
    final queenCols = List<int>.filled(gridSize, -1);

    void solve(int row) {
      if (solutions > 1) return; // Short-circuit if multiple solutions exist

      if (row == gridSize) {
        solutions++;
        return;
      }

      for (int col = 0; col < gridSize; col++) {
        final region = colorRegions[row][col];
        if (colsUsed[col] || regionsUsed[region]) continue;

        // Adjacency constraint check (queens cannot touch adjacent cells in previous row)
        if (row > 0) {
          final prevCol = queenCols[row - 1];
          if ((col - prevCol).abs() <= 1) continue;
        }

        // Place
        colsUsed[col] = true;
        regionsUsed[region] = true;
        queenCols[row] = col;

        solve(row + 1);

        // Backtrack
        colsUsed[col] = false;
        regionsUsed[region] = false;
        queenCols[row] = -1;
      }
    }

    solve(0);
    return solutions;
  }

  bool _solveQueens(int row, int N, List<int> cols, Random random) {
    if (row == N) return true;

    final colIndices = List<int>.generate(N, (i) => i)..shuffle(random);
    for (final col in colIndices) {
      if (_isValidPlacement(row, col, cols)) {
        cols[row] = col;
        if (_solveQueens(row + 1, N, cols, random)) {
          return true;
        }
        cols[row] = -1;
      }
    }
    return false;
  }

  bool _isValidPlacement(int row, int col, List<int> cols) {
    for (int prevRow = 0; prevRow < row; prevRow++) {
      final prevCol = cols[prevRow];
      if (prevCol == col) return false;

      final rowDiff = row - prevRow;
      final colDiff = (col - prevCol).abs();
      if (rowDiff == 1 && colDiff <= 1) {
        return false;
      }
    }
    return true;
  }

  List<Color> _pickColors(int count, Random random) {
    final indices = List.generate(AppColors.queensColors.length, (i) => i)
      ..shuffle(random);
    return indices.take(count).map((i) => AppColors.queensColors[i]).toList();
  }
}

class _GrowthCandidate {
  _GrowthCandidate(this.r, this.c, this.region);
  final int r;
  final int c;
  final int region;
}
