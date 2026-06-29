import 'dart:math';
import 'package:flutter/material.dart';

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
    // 1. Find a valid placement of gridSize queens that do not touch (row, col, 8-way adjacent)
    final queenCols = List<int>.filled(gridSize, -1);
    final solved = _solveQueens(0, gridSize, queenCols, random);
    if (!solved) {
      // Fallback in case of highly improbable random failure (though it solves instantly)
      for (int i = 0; i < gridSize; i++) {
        queenCols[i] = i;
      }
    }

    // 2. Generate connected color regions containing exactly one queen each
    final colorRegions = List.generate(
      gridSize,
      (_) => List<int>.filled(gridSize, -1),
    );

    for (int r = 0; r < gridSize; r++) {
      colorRegions[r][queenCols[r]] = r;
    }

    // List of regions to keep track of their growth
    final regionSizes = List<int>.filled(gridSize, 1);

    while (true) {
      final candidates = <_GrowthCandidate>[];
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (colorRegions[r][c] == -1) {
            // Check 4-way neighbors
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

      // Select candidate that grows the smallest region to keep sizes somewhat balanced
      candidates.shuffle(random);
      candidates.sort((a, b) => regionSizes[a.region].compareTo(regionSizes[b.region]));

      final choice = candidates.first;
      colorRegions[choice.r][choice.c] = choice.region;
      regionSizes[choice.region]++;
    }

    // 3. Pick beautiful colors
    final colors = _pickColors(gridSize, random);

    return GameLevel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      colorRegions: colorRegions,
      regionColors: colors,
    );
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
      if (prevCol == col) return false; // same column

      final rowDiff = row - prevRow;
      final colDiff = (col - prevCol).abs();
      if (rowDiff == 1 && colDiff <= 1) {
        return false; // touching
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
