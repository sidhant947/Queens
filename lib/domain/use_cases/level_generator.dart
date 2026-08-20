import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:queens/domain/models/game_level.dart';
import 'package:queens/ui/core/theme/app_colors.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};
  // Tracks active background pre-generation isolates (not main loads).
  // Kept at 1 to avoid spawning multiple heavy compute() isolates
  // simultaneously, which causes OOM on Android for large grids (9×9+).
  int _backgroundComputes = 0;
  // True while a main-load compute() isolate is running; suppresses
  // pre-generation until the user's level is fully loaded.
  bool _mainLoadActive = false;

  GameLevel generate(int levelNumber) {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      level = _cache.remove(levelNumber)!;
    } else {
      level = _generateInternal(levelNumber);
    }
    _generating.remove(levelNumber);
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  Future<GameLevel> generateAsync(int levelNumber) async {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      level = _cache.remove(levelNumber)!;
    } else {
      _mainLoadActive = true;
      try {
        level = await compute(_isolateGenerate, levelNumber);
      } finally {
        _mainLoadActive = false;
      }
    }
    _generating.remove(levelNumber);
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final random = Random(levelNumber);
    final gridSize = _getGridSize(levelNumber);
    final snakeFactor = _getSnakeFactor(levelNumber);
    final varianceFactor = _getVarianceFactor(levelNumber);
    return _generateLevelWithSeed(
      levelNumber,
      gridSize,
      random,
      snakeFactor: snakeFactor,
      varianceFactor: varianceFactor,
    );
  }

  void pregenerateAround(int currentLevel, {int range = 1}) {
    for (int i = 0; i <= range; i++) {
      final levelNumber = currentLevel + i;
      if (levelNumber < 1) continue;
      if (_cache.containsKey(levelNumber) || _generating.contains(levelNumber)) continue;
      // Limit concurrency: skip if a main load is running or a background
      // isolate is already active. Prevents OOM from simultaneous heavy
      // compute() calls on large grids (9×9+).
      if (_mainLoadActive || _backgroundComputes >= 1) break;
      _generating.add(levelNumber);
      _backgroundComputes++;
      compute(_isolateGenerate, levelNumber).then((level) {
        _cache[levelNumber] = level;
        _generating.remove(levelNumber);
        _backgroundComputes--;
      }).catchError((e) {
        _generating.remove(levelNumber);
        _backgroundComputes--;
      });
    }
  }

  void _pregenerateNext(int startLevel) {
    pregenerateAround(startLevel, range: 1);
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator()._generateInternal(levelNumber);
  }

  static GameLevel _isolateGenerateRandom(Map<String, int> params) {
    return LevelGenerator().generateRandom(
      gridSize: params['gridSize']!,
      seed: params['seed']!,
    );
  }

  Future<GameLevel> generateRandomAsync({required int gridSize, required int seed}) {
    return compute(_isolateGenerateRandom, {'gridSize': gridSize, 'seed': seed});
  }

  GameLevel generateRandom({required int gridSize, required int seed}) {
    final random = Random(seed);
    final snakeFactor = (gridSize >= 10) ? 0.75 : (gridSize >= 8 ? 0.55 : 0.35);
    final varianceFactor = (gridSize >= 10) ? 0.60 : (gridSize >= 8 ? 0.40 : 0.20);
    return _generateLevelWithSeed(
      -1,
      gridSize,
      random,
      snakeFactor: snakeFactor,
      varianceFactor: varianceFactor,
    );
  }

  int _getGridSize(int level) {
    if (level <= 5) return 5;
    if (level <= 20) return 6;
    if (level <= 45) return 7;
    if (level <= 80) return 8;
    if (level <= 130) return 9;
    if (level <= 190) return 10;
    if (level <= 250) return 11;
    return 12;
  }

  double _getSnakeFactor(int level) {
    if (level <= 5) return 0.10;
    if (level <= 20) return 0.25;
    if (level <= 45) return 0.40;
    if (level <= 80) return 0.55;
    if (level <= 130) return 0.68;
    if (level <= 190) return 0.78;
    if (level <= 250) return 0.85;
    return 0.90;
  }

  double _getVarianceFactor(int level) {
    if (level <= 5) return 0.05;
    if (level <= 20) return 0.15;
    if (level <= 45) return 0.28;
    if (level <= 80) return 0.40;
    if (level <= 130) return 0.52;
    if (level <= 190) return 0.64;
    if (level <= 250) return 0.74;
    return 0.80;
  }

  GameLevel _generateLevelWithSeed(
    int levelNumber,
    int gridSize,
    Random random, {
    double snakeFactor = 0.3,
    double varianceFactor = 0.2,
  }) {
    var queenCols = List<int>.filled(gridSize, -1);
    var colorRegions = List.generate(gridSize, (_) => List<int>.filled(gridSize, -1));
    var finalColors = <Color>[];

    int attempt = 0;
    while (true) {
      attempt++;
      final subSeed = levelNumber >= 0
          ? (levelNumber * 1000 + attempt)
          : random.nextInt(1000000);
      final subRandom = Random(subSeed);

      queenCols = List<int>.filled(gridSize, -1);
      final solved = _solveQueens(0, gridSize, queenCols, subRandom);
      if (!solved) continue;

      colorRegions = List.generate(gridSize, (_) => List<int>.filled(gridSize, -1));
      for (int r = 0; r < gridSize; r++) {
        colorRegions[r][queenCols[r]] = r;
      }

      final regionWeights = List<double>.generate(gridSize, (i) {
        final variance = (subRandom.nextDouble() * 2.0 - 1.0) * varianceFactor;
        return (1.0 + variance).clamp(0.4, 2.0);
      });

      final activeFrontier = <Point<int>>[];
      final lastDirections = <int, Point<int>>{};

      for (int r = 0; r < gridSize; r++) {
        activeFrontier.add(Point(r, queenCols[r]));
      }

      int unassignedCells = (gridSize * gridSize) - gridSize;

      while (unassignedCells > 0 && activeFrontier.isNotEmpty) {
        activeFrontier.shuffle(subRandom);
        final currentPoint = activeFrontier.removeLast();
        final r = currentPoint.x;
        final c = currentPoint.y;
        final currentRegion = colorRegions[r][c];

        final candidates = [
          Point(r - 1, c),
          Point(r + 1, c),
          Point(r, c - 1),
          Point(r, c + 1),
        ].where((p) =>
            p.x >= 0 &&
            p.x < gridSize &&
            p.y >= 0 &&
            p.y < gridSize &&
            colorRegions[p.x][p.y] == -1).toList();

        if (candidates.isEmpty) continue;

        Point<int> chosen;
        final lastDir = lastDirections[currentRegion];
        if (lastDir != null &&
            subRandom.nextDouble() < snakeFactor &&
            candidates.any((p) => (p.x - r == lastDir.x && p.y - c == lastDir.y))) {
          chosen = candidates.firstWhere((p) => (p.x - r == lastDir.x && p.y - c == lastDir.y));
        } else {
          candidates.shuffle(subRandom);
          chosen = candidates.first;
        }

        colorRegions[chosen.x][chosen.y] = currentRegion;
        lastDirections[currentRegion] = Point(chosen.x - r, chosen.y - c);
        unassignedCells--;

        final expansionChance = regionWeights[currentRegion];
        if (subRandom.nextDouble() <= expansionChance) {
          activeFrontier.add(chosen);
        } else {
          activeFrontier.insert(0, chosen);
        }

        if (candidates.length > 1 && subRandom.nextDouble() < (1.0 - snakeFactor)) {
          activeFrontier.add(currentPoint);
        }
      }

      while (unassignedCells > 0) {
        bool progress = false;
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            if (colorRegions[r][c] == -1) {
              final adj = [
                Point(r - 1, c),
                Point(r + 1, c),
                Point(r, c - 1),
                Point(r, c + 1),
              ].where((p) =>
                  p.x >= 0 &&
                  p.x < gridSize &&
                  p.y >= 0 &&
                  p.y < gridSize &&
                  colorRegions[p.x][p.y] != -1).toList();
              if (adj.isNotEmpty) {
                adj.shuffle(subRandom);
                colorRegions[r][c] = colorRegions[adj.first.x][adj.first.y];
                unassignedCells--;
                progress = true;
              }
            }
          }
        }
        if (!progress) break;
      }

      bool success = false;
      int mutations = 0;
      final maxMutations = (150 + (snakeFactor * 100)).round();

      while (mutations < maxMutations) {
        final altSolution = _findAlternativeSolution(gridSize, colorRegions, queenCols, subRandom);
        if (altSolution == null) {
          success = true;
          break;
        }
        if (altSolution.isEmpty) {
          success = false;
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
    Random random,
  ) {
    final colsUsed = List<bool>.filled(gridSize, false);
    final regionsUsed = List<bool>.filled(gridSize, false);
    final queenCols = List<int>.filled(gridSize, -1);
    List<int>? alternative;
    int visits = 0;

    void solve(int row, bool hasDiverged) {
      visits++;
      if (visits > 100000) {
        alternative = const <int>[];
        return;
      }
      if (alternative != null) return;

      if (row == gridSize) {
        if (hasDiverged) {
          alternative = List<int>.from(queenCols);
        }
        return;
      }

      final cols = List<int>.generate(gridSize, (i) => i)..shuffle(random);

      for (final c in cols) {
        if (colsUsed[c]) continue;
        final region = colorRegions[row][c];
        if (region < 0 || region >= gridSize || regionsUsed[region]) continue;

        if (row > 0) {
          final prevC = queenCols[row - 1];
          if ((prevC - c).abs() <= 1) continue;
        }

        final nextDiverged = hasDiverged || (c != targetSolution[row]);

        colsUsed[c] = true;
        regionsUsed[region] = true;
        queenCols[row] = c;

        solve(row + 1, nextDiverged);

        colsUsed[c] = false;
        regionsUsed[region] = false;
        queenCols[row] = -1;

        if (alternative != null) return;
      }
    }

    solve(0, false);
    return alternative;
  }

  bool _solveQueens(int row, int gridSize, List<int> queenCols, Random random) {
    if (row == gridSize) return true;

    final cols = List<int>.generate(gridSize, (i) => i)..shuffle(random);

    for (final c in cols) {
      bool ok = true;
      for (int r = 0; r < row; r++) {
        final qc = queenCols[r];
        if (qc == c || (qc - c).abs() <= 1 && (r - row).abs() <= 1) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;

      queenCols[row] = c;
      if (_solveQueens(row + 1, gridSize, queenCols, random)) {
        return true;
      }
      queenCols[row] = -1;
    }
    return false;
  }

  List<Color> _pickColors(int count, Random random, int gridSize, List<List<int>> colorRegions) {
    final available = List<Color>.from(AppColors.queensColors);
    final chosenColors = <Color>[];

    for (int i = 0; i < count; i++) {
      chosenColors.add(available[i % available.length]);
    }

    final adj = List.generate(count, (_) => <int>{});
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final reg = colorRegions[r][c];
        if (r + 1 < gridSize) {
          final regBelow = colorRegions[r + 1][c];
          if (reg != regBelow) {
            adj[reg].add(regBelow);
            adj[regBelow].add(reg);
          }
        }
        if (c + 1 < gridSize) {
          final regRight = colorRegions[r][c + 1];
          if (reg != regRight) {
            adj[reg].add(regRight);
            adj[regRight].add(reg);
          }
        }
      }
    }

    double colorDistance(Color a, Color b) {
      final r1 = (a.r * 255.0);
      final g1 = (a.g * 255.0);
      final b1 = (a.b * 255.0);
      final r2 = (b.r * 255.0);
      final g2 = (b.g * 255.0);
      final b2 = (b.b * 255.0);
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
