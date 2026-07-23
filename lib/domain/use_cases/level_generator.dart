import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:queens/domain/models/game_level.dart';
import 'package:queens/ui/core/theme/app_colors.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};

  GameLevel generate(int levelNumber) {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      debugPrint('⚡ [LevelGenerator] Cache HIT for level $levelNumber. Loading instantly.');
      level = _cache.remove(levelNumber)!;
    } else {
      debugPrint('🐌 [LevelGenerator] Cache MISS for level $levelNumber. Generating on UI thread.');
      level = _generateInternal(levelNumber);
    }
    _generating.remove(levelNumber);
    
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final random = Random(levelNumber);
    final gridSize = _getGridSize(levelNumber);
    return _generateLevelWithSeed(levelNumber, gridSize, random);
  }

  void _pregenerateNext(int startLevel) {
    for (int i = 0; i < 3; i++) {
      final levelNumber = startLevel + i;
      if (!_cache.containsKey(levelNumber) && !_generating.contains(levelNumber)) {
        _generating.add(levelNumber);
        debugPrint('⏳ [LevelGenerator] Spawning isolate to pre-generate level $levelNumber...');
        compute(_isolateGenerate, levelNumber).then((level) {
          _cache[levelNumber] = level;
          _generating.remove(levelNumber);
          debugPrint('✅ [LevelGenerator] Finished pre-generating level $levelNumber in background.');
        }).catchError((e) {
          _generating.remove(levelNumber);
          debugPrint('❌ [LevelGenerator] Failed to pre-generate level $levelNumber: $e');
        });
      }
    }
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator()._generateInternal(levelNumber);
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
    return 12;
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

      // 3. Grow connected color regions using BFS
      List<Point<int>> queue = [];
      for (int r = 0; r < gridSize; r++) {
        queue.add(Point(r, queenCols[r]));
      }
      
      queue.shuffle(subRandom);

      while (queue.isNotEmpty) {
        List<Point<int>> nextQueue = [];
        for (final p in queue) {
          final r = p.x;
          final c = p.y;
          final currentRegion = colorRegions[r][c];

          final neighbors = [
            Point(r - 1, c),
            Point(r + 1, c),
            Point(r, c - 1),
            Point(r, c + 1),
          ];
          neighbors.shuffle(subRandom);

          for (final n in neighbors) {
            if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize) {
              if (colorRegions[n.x][n.y] == -1) {
                colorRegions[n.x][n.y] = currentRegion;
                nextQueue.add(n);
              }
            }
          }
        }
        nextQueue.shuffle(subRandom);
        queue = nextQueue;
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
        finalColors = _pickColors(gridSize, subRandom, gridSize, colorRegions);
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

  List<Color> _pickColors(int count, Random random, int gridSize, List<List<int>> colorRegions) {
    final indices = List.generate(AppColors.queensColors.length, (i) => i)..shuffle(random);
    final chosenColors = indices.take(count).map((i) => AppColors.queensColors[i]).toList();

    // Build adjacency graph for regions.
    final adj = List.generate(count, (_) => <int>{});
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final reg1 = colorRegions[r][c];
        if (reg1 == -1) continue;
        final neighbors = [
          Point(r - 1, c),
          Point(r + 1, c),
          Point(r, c - 1),
          Point(r, c + 1),
        ];
        for (final n in neighbors) {
          if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize) {
            final reg2 = colorRegions[n.x][n.y];
            if (reg2 != -1 && reg1 != reg2) {
              adj[reg1].add(reg2);
              adj[reg2].add(reg1);
            }
          }
        }
      }
    }

    double colorDistance(Color a, Color b) {
      final r1 = (a.value >> 16) & 0xFF;
      final g1 = (a.value >> 8) & 0xFF;
      final b1 = a.value & 0xFF;
      final r2 = (b.value >> 16) & 0xFF;
      final g2 = (b.value >> 8) & 0xFF;
      final b2 = b.value & 0xFF;
      return sqrt((r1 - r2) * (r1 - r2) + (g1 - g2) * (g1 - g2) + (b1 - b2) * (b1 - b2));
    }

    double calculateScore(List<Color> assignment) {
      double minScore = double.infinity;
      for (int i = 0; i < count; i++) {
        for (final j in adj[i]) {
          final dist = colorDistance(assignment[i], assignment[j]);
          if (dist < minScore) {
            minScore = dist;
          }
        }
      }
      return minScore;
    }

    List<Color> bestAssignment = List.from(chosenColors);
    double bestScore = calculateScore(bestAssignment);

    // Hill climbing: try swapping colors to improve the minimum adjacent distance
    bool improved = true;
    while (improved) {
      improved = false;
      for (int i = 0; i < count; i++) {
        for (int j = i + 1; j < count; j++) {
          final testAssignment = List<Color>.from(bestAssignment);
          final temp = testAssignment[i];
          testAssignment[i] = testAssignment[j];
          testAssignment[j] = temp;
          
          final score = calculateScore(testAssignment);
          if (score > bestScore) {
            bestScore = score;
            bestAssignment = testAssignment;
            improved = true;
          }
        }
      }
    }

    return bestAssignment;
  }
}


