import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:queens/ui/features/game/view_models/game_view_model.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
    this.totalMoves = 0,
    this.bestMoves = const {},
    this.bestTimeSeconds = const {},
    this.savedLevelNumber,
    this.savedBoard,
    this.savedMoveCount = 0,
    this.savedElapsedSeconds = 0,
  });

  final int currentLevel;
  final int highestLevelCompleted;
  final int totalMoves;

  /// Best (fewest) moves recorded per level number.
  final Map<int, int> bestMoves;

  /// Best (fastest) completion time in seconds per level number.
  final Map<int, int> bestTimeSeconds;

  /// In-progress (non-random) level saved so the player can resume mid-puzzle.
  /// Null when there is no saved game.
  final int? savedLevelNumber;
  final List<List<int>>? savedBoard; // CellState indices
  final int savedMoveCount;
  final int savedElapsedSeconds;

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
    int? totalMoves,
    Map<int, int>? bestMoves,
    Map<int, int>? bestTimeSeconds,
    int? savedLevelNumber,
    List<List<int>>? savedBoard,
    int? savedMoveCount,
    int? savedElapsedSeconds,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted:
          highestLevelCompleted ?? this.highestLevelCompleted,
      totalMoves: totalMoves ?? this.totalMoves,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      savedLevelNumber: savedLevelNumber ?? this.savedLevelNumber,
      savedBoard: savedBoard ?? this.savedBoard,
      savedMoveCount: savedMoveCount ?? this.savedMoveCount,
      savedElapsedSeconds: savedElapsedSeconds ?? this.savedElapsedSeconds,
    );
  }

  UserProgress incrementLevel() {
    return copyWith(
      currentLevel: currentLevel + 1,
      // Never lower the highest completed level (e.g. when replaying an earlier one).
      highestLevelCompleted: math.max(highestLevelCompleted, currentLevel),
    );
  }

  UserProgress addMoves(int moves) {
    return copyWith(totalMoves: totalMoves + moves);
  }

  /// Records a per-level result, keeping the best (minimum) moves and time.
  UserProgress recordLevelResult(int level, int moves, int seconds) {
    final newBestMoves = Map<int, int>.from(bestMoves);
    final newBestTime = Map<int, int>.from(bestTimeSeconds);

    final priorMoves = newBestMoves[level];
    if (priorMoves == null || moves < priorMoves) {
      newBestMoves[level] = moves;
    }
    final priorTime = newBestTime[level];
    if (priorTime == null || seconds < priorTime) {
      newBestTime[level] = seconds;
    }

    return copyWith(bestMoves: newBestMoves, bestTimeSeconds: newBestTime);
  }

  /// Stores the current in-progress (non-random) board for resume.
  UserProgress withSavedGame({
    required int levelNumber,
    required List<List<CellState>> board,
    required int moveCount,
    required int elapsedSeconds,
  }) {
    return copyWith(
      savedLevelNumber: levelNumber,
      savedBoard: board
          .map((row) => row.map((cell) => cell.index).toList())
          .toList(),
      savedMoveCount: moveCount,
      savedElapsedSeconds: elapsedSeconds,
    );
  }

  /// Clears any saved in-progress game.
  UserProgress withoutSavedGame() {
    return UserProgress(
      currentLevel: currentLevel,
      highestLevelCompleted: highestLevelCompleted,
      totalMoves: totalMoves,
      bestMoves: bestMoves,
      bestTimeSeconds: bestTimeSeconds,
      savedLevelNumber: null,
      savedBoard: null,
      savedMoveCount: 0,
      savedElapsedSeconds: 0,
    );
  }
}
