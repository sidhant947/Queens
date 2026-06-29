import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/repositories/progress_repository.dart';
import 'package:queens/domain/models/game_level.dart';
import 'package:queens/domain/use_cases/level_generator.dart';

enum CellState {
  empty,
  x,
  queen,
}

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.level,
    this.board = const [],
    this.conflicts = const [],
    this.isLoading = false,
    this.isComplete = false,
    this.moveCount = 0,
    this.error,
    this.isRandomMode = false,
    this.randomDifficulty,
    this.randomSeed,
    this.randomGridSize,
  });

  final GameLevel? level;
  final List<List<CellState>> board;
  final List<List<bool>> conflicts;
  final bool isLoading;
  final bool isComplete;
  final int moveCount;
  final String? error;
  final bool isRandomMode;
  final String? randomDifficulty;
  final int? randomSeed;
  final int? randomGridSize;

  GameViewModelState copyWith({
    GameLevel? level,
    List<List<CellState>>? board,
    List<List<bool>>? conflicts,
    bool? isLoading,
    bool? isComplete,
    int? moveCount,
    String? error,
    bool? isRandomMode,
    String? randomDifficulty,
    int? randomSeed,
    int? randomGridSize,
  }) {
    return GameViewModelState(
      level: level ?? this.level,
      board: board ?? this.board,
      conflicts: conflicts ?? this.conflicts,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      moveCount: moveCount ?? this.moveCount,
      error: error,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      randomDifficulty: randomDifficulty ?? this.randomDifficulty,
      randomSeed: randomSeed ?? this.randomSeed,
      randomGridSize: randomGridSize ?? this.randomGridSize,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.levelGenerator,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;

  Future<void> loadLevel(int levelNumber) async {
    state = const GameViewModelState(isLoading: true);

    try {
      final level = levelGenerator.generate(levelNumber);
      final board = List.generate(
        level.gridSize,
        (_) => List.filled(level.gridSize, CellState.empty),
      );
      final conflicts = List.generate(
        level.gridSize,
        (_) => List.filled(level.gridSize, false),
      );

      state = GameViewModelState(
        level: level,
        board: board,
        conflicts: conflicts,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load level: $e');
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
    );

    try {
      int gridSize = 5;
      if (difficulty == 'Medium') {
        gridSize = 6;
      } else if (difficulty == 'Hard') {
        gridSize = 7;
      } else if (difficulty == 'Super Hard') {
        gridSize = 8;
      } else if (difficulty == 'Super Duper Hard') {
        gridSize = 9;
      }

      final level = levelGenerator.generateRandom(
        gridSize: gridSize,
        seed: levelSeed,
      );
      final board = List.generate(
        gridSize,
        (_) => List.filled(gridSize, CellState.empty),
      );
      final conflicts = List.generate(
        gridSize,
        (_) => List.filled(gridSize, false),
      );

      state = state.copyWith(
        level: level,
        board: board,
        conflicts: conflicts,
        isLoading: false,
        randomGridSize: gridSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load random level: $e',
      );
    }
  }

  void toggleCell(int r, int c) {
    if (state.isComplete || state.level == null) return;

    final N = state.level!.gridSize;
    final newBoard = List.generate(
      N,
      (row) => List<CellState>.from(state.board[row]),
    );

    final current = newBoard[r][c];
    CellState next;
    int movesDelta = 0;

    if (current == CellState.empty) {
      next = CellState.x;
      HapticFeedback.lightImpact();
    } else if (current == CellState.x) {
      next = CellState.queen;
      movesDelta = 1;
      HapticFeedback.mediumImpact();
    } else {
      next = CellState.empty;
      movesDelta = 1;
      HapticFeedback.lightImpact();
    }

    newBoard[r][c] = next;

    // Calculate conflicts
    final newConflicts = List.generate(
      N,
      (_) => List.filled(N, false),
    );

    int queenCount = 0;

    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        if (newBoard[i][j] == CellState.queen) {
          queenCount++;
          // Check row conflict
          for (int col = 0; col < N; col++) {
            if (col != j && newBoard[i][col] == CellState.queen) {
              newConflicts[i][j] = true;
              newConflicts[i][col] = true;
            }
          }
          // Check col conflict
          for (int row = 0; row < N; row++) {
            if (row != i && newBoard[row][j] == CellState.queen) {
              newConflicts[i][j] = true;
              newConflicts[row][j] = true;
            }
          }
          // Check color region conflict
          final myRegion = state.level!.colorRegions[i][j];
          for (int row = 0; row < N; row++) {
            for (int col = 0; col < N; col++) {
              if ((row != i || col != j) &&
                  newBoard[row][col] == CellState.queen &&
                  state.level!.colorRegions[row][col] == myRegion) {
                newConflicts[i][j] = true;
                newConflicts[row][col] = true;
              }
            }
          }
          // Check 8-way adjacent neighbors
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;
              final nr = i + dr;
              final nc = j + dc;
              if (nr >= 0 && nr < N && nc >= 0 && nc < N) {
                if (newBoard[nr][nc] == CellState.queen) {
                  newConflicts[i][j] = true;
                  newConflicts[nr][nc] = true;
                }
              }
            }
          }
        }
      }
    }

    // Check if level is complete
    bool hasConflicts = false;
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        if (newConflicts[i][j]) {
          hasConflicts = true;
          break;
        }
      }
    }

    final isComplete = queenCount == N && !hasConflicts;

    if (isComplete) {
      HapticFeedback.heavyImpact();
    }

    state = state.copyWith(
      board: newBoard,
      conflicts: newConflicts,
      moveCount: state.moveCount + movesDelta,
      isComplete: isComplete,
    );
  }

  Future<void> completeLevel() async {
    if (state.level == null || !state.isComplete) return;
    if (state.isRandomMode) {
      await progressRepository.addRandomLevelMoves(state.moveCount);
    } else {
      await progressRepository.completeLevel(state.moveCount);
    }
  }

  void resetLevel() {
    if (state.level != null) {
      if (state.isRandomMode) {
        loadRandomLevel(state.randomDifficulty ?? 'Easy', seed: state.randomSeed);
      } else {
        loadLevel(state.level!.levelNumber);
      }
    }
  }
}
