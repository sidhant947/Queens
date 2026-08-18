import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/repositories/progress_repository.dart';
import 'package:queens/data/services/settings_service.dart';
import 'package:queens/domain/models/game_level.dart';
import 'package:queens/domain/use_cases/cell_rules.dart';
import 'package:queens/domain/use_cases/level_generator.dart';

enum CellState {
  empty,
  x,
  queen,
}

@immutable
class _Snapshot {
  const _Snapshot(this.board, this.moveCount);
  final List<List<CellState>> board;
  final int moveCount;
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
    this.elapsedSeconds = 0,
    this.canUndo = false,
    this.hintCell,
    this.hintsRemaining = 2,
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
  final int elapsedSeconds;
  final bool canUndo;
  final int? hintCell;
  final int hintsRemaining;
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
    int? elapsedSeconds,
    bool? canUndo,
    int? hintCell,
    bool clearHint = false,
    int? hintsRemaining,
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
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      canUndo: canUndo ?? this.canUndo,
      hintCell: clearHint ? null : (hintCell ?? this.hintCell),
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
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
    required this.settingsService,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;
  final SettingsService settingsService;

  static const int _maxUndo = 50;

  final List<_Snapshot> _undoStack = [];
  Timer? _timer;
  Timer? _hintTimer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _stopTimer();
        return;
      }
      if (state.isComplete) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  List<List<CellState>> _emptyBoard(int n) =>
      List.generate(n, (_) => List<CellState>.filled(n, CellState.empty));

  Future<void> loadLevel(int levelNumber) async {
    _undoStack.clear();
    state = const GameViewModelState(isLoading: true);

    try {
      final level = await levelGenerator.generateAsync(levelNumber);
      if (!mounted) return;

      final progress = await progressRepository.getProgress();
      if (!mounted) return;

      List<List<CellState>> board;
      int moveCount = 0;
      int elapsed = 0;
      if (progress.savedLevelNumber == levelNumber &&
          progress.savedBoard != null &&
          progress.savedBoard!.length == level.gridSize) {
        board = progress.savedBoard!
            .map((row) =>
                row.map((i) => CellState.values[i]).toList(growable: false))
            .toList();
        moveCount = progress.savedMoveCount;
        elapsed = progress.savedElapsedSeconds;
      } else {
        board = _emptyBoard(level.gridSize);
      }

      final conflicts = CellRules.computeConflicts(board, level);
      final isComplete = CellRules.isComplete(board, level);

      state = GameViewModelState(
        level: level,
        board: board,
        conflicts: conflicts,
        moveCount: moveCount,
        elapsedSeconds: elapsed,
        isComplete: isComplete,
        hintsRemaining: 2,
      );
      if (!isComplete) _startTimer();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load level: $e',
      );
    }
  }

  int _parseGridSize(String difficulty) {
    final lower = difficulty.toLowerCase().trim();
    if (lower.contains('x')) {
      final parts = lower.split('x');
      final size = int.tryParse(parts[0].trim());
      if (size != null && size >= 4 && size <= 12) return size;
    }
    switch (lower) {
      case 'easy':
      case '5x5':
        return 5;
      case 'medium':
      case '6x6':
        return 6;
      case 'hard':
      case '7x7':
        return 7;
      case 'super hard':
      case '8x8':
        return 8;
      case 'super duper hard':
      case 'expert':
      case '9x9':
        return 9;
      case '10x10':
        return 10;
      case '11x11':
        return 11;
      case '12x12':
        return 12;
      default:
        final parsed = int.tryParse(difficulty);
        if (parsed != null && parsed >= 4 && parsed <= 12) return parsed;
        return 5;
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    _undoStack.clear();
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final int gridSize = _parseGridSize(difficulty);

    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
      randomGridSize: gridSize,
      hintsRemaining: 2,
    );

    try {
      final level = await levelGenerator.generateRandomAsync(
        gridSize: gridSize,
        seed: levelSeed,
      );
      if (!mounted) return;

      final board = _emptyBoard(gridSize);
      final conflicts = CellRules.computeConflicts(board, level);

      state = state.copyWith(
        level: level,
        board: board,
        conflicts: conflicts,
        moveCount: 0,
        elapsedSeconds: 0,
        canUndo: false,
        isLoading: false,
        randomGridSize: gridSize,
        hintsRemaining: 2,
      );
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load random level: $e',
      );
    }
  }

  void toggleCell(int r, int c) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
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

    final newConflicts = CellRules.computeConflicts(newBoard, level);
    final isComplete = CellRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    }

    state = state.copyWith(
      board: newBoard,
      conflicts: newConflicts,
      moveCount: state.moveCount + movesDelta,
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void setCellState(int r, int c, CellState next) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    final current = state.board[r][c];
    if (current == next) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<CellState>.from(state.board[row]),
    );

    newBoard[r][c] = next;

    final newConflicts = CellRules.computeConflicts(newBoard, level);
    final isComplete = CellRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    } else {
      HapticFeedback.selectionClick();
    }

    state = state.copyWith(
      board: newBoard,
      conflicts: newConflicts,
      moveCount: state.moveCount,
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void _pushUndo() {
    final snapshotBoard = state.board
        .map((row) => List<CellState>.from(row))
        .toList(growable: false);
    _undoStack.add(_Snapshot(snapshotBoard, state.moveCount));
    if (_undoStack.length > _maxUndo) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty || state.level == null || state.isComplete) return;
    final snapshot = _undoStack.removeLast();
    final conflicts = CellRules.computeConflicts(snapshot.board, state.level!);
    HapticFeedback.lightImpact();
    state = state.copyWith(
      board: snapshot.board,
      conflicts: conflicts,
      moveCount: snapshot.moveCount,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );
    _persistInProgress();
  }

  void revealHint() {
    final level = state.level;
    if (level == null || state.isComplete || state.hintsRemaining <= 0) return;

    final n = level.gridSize;
    int? targetRow;

    for (int r = 0; r < n; r++) {
      final c = level.solutionCols[r];
      if (state.board[r][c] != CellState.queen) {
        targetRow = r;
        break;
      }
    }

    if (targetRow == null) return;

    final targetCol = level.solutionCols[targetRow];
    _pushUndo();

    final newBoard = state.board.map((row) => List<CellState>.from(row)).toList();

    for (int c = 0; c < n; c++) {
      if (newBoard[targetRow][c] == CellState.queen && c != targetCol) {
        newBoard[targetRow][c] = CellState.empty;
      }
    }
    for (int r = 0; r < n; r++) {
      if (newBoard[r][targetCol] == CellState.queen && r != targetRow) {
        newBoard[r][targetCol] = CellState.empty;
      }
    }

    newBoard[targetRow][targetCol] = CellState.queen;

    final conflicts = CellRules.computeConflicts(newBoard, level);
    final isComplete = CellRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    } else {
      HapticFeedback.mediumImpact();
    }

    final encoded = targetRow * n + targetCol;

    state = state.copyWith(
      board: newBoard,
      conflicts: conflicts,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      hintsRemaining: state.hintsRemaining - 1,
      hintCell: encoded,
    );

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) state = state.copyWith(clearHint: true);
    });

    _persistInProgress();
  }

  void _persistInProgress() {
    final level = state.level;
    if (level == null || state.isRandomMode) return;
    if (state.isComplete) return;
    progressRepository.saveInProgress(
      level.levelNumber,
      state.board,
      state.moveCount,
      state.elapsedSeconds,
    );
  }

  Future<void> completeLevel() async {
    final level = state.level;
    if (level == null || !state.isComplete) return;
    if (state.isRandomMode) {
      await progressRepository.addRandomLevelMoves(state.moveCount);
    } else {
      await progressRepository.completeLevel(level.levelNumber, state.moveCount);
      if (!mounted) return;
      await progressRepository.recordLevelResult(
        level.levelNumber,
        state.moveCount,
        state.elapsedSeconds,
      );
      if (!mounted) return;
      await progressRepository.clearInProgress();
    }
  }

  Future<void> resetLevel() async {
    final level = state.level;
    if (level == null) return;
    if (state.isRandomMode) {
      await loadRandomLevel(state.randomDifficulty ?? '5x5',
          seed: state.randomSeed);
    } else {
      await progressRepository.clearInProgress();
      if (!mounted) return;
      await loadLevel(level.levelNumber);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _hintTimer?.cancel();
    super.dispose();
  }
}
