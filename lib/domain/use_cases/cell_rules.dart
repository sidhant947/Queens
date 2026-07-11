import 'package:queens/domain/models/game_level.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';

/// Pure Queens rule helpers shared by the view model (conflict + completion),
/// the board UI (auto-blocked hints), and the hint generator. Keeping a single
/// implementation guarantees these three stay in sync.
class CellRules {
  const CellRules._();

  /// Returns true if an *empty* cell cannot legally hold a queen given the
  /// queens currently on the board (same row/col/region or 8-way adjacent).
  static bool isCellBlocked(
    int r,
    int c,
    List<List<CellState>> board,
    GameLevel level,
  ) {
    if (board[r][c] != CellState.empty) return false;
    final n = level.gridSize;
    final myRegion = level.colorRegions[r][c];

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (board[i][j] == CellState.queen) {
          if (i == r) return true; // same row
          if (j == c) return true; // same col
          if (level.colorRegions[i][j] == myRegion) return true; // same region
          if ((i - r).abs() <= 1 && (j - c).abs() <= 1) return true; // adjacent
        }
      }
    }
    return false;
  }

  /// Computes the conflict grid for the current board.
  ///
  /// Only placed queens are compared pairwise (O(Q²) where Q is the number of
  /// queens), instead of scanning every cell against every other cell. The
  /// semantics are identical to the original full-board scan: a queen is in
  /// conflict if it shares a row, column, colour region, or 8-way-adjacency
  /// with another queen.
  static List<List<bool>> computeConflicts(
    List<List<CellState>> board,
    GameLevel level,
  ) {
    final n = level.gridSize;
    final conflicts = List.generate(n, (_) => List<bool>.filled(n, false));

    // Collect queen coordinates once.
    final queens = <List<int>>[];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (board[i][j] == CellState.queen) queens.add([i, j]);
      }
    }

    for (int a = 0; a < queens.length; a++) {
      for (int b = a + 1; b < queens.length; b++) {
        final r1 = queens[a][0];
        final c1 = queens[a][1];
        final r2 = queens[b][0];
        final c2 = queens[b][1];

        final sameRow = r1 == r2;
        final sameCol = c1 == c2;
        final sameRegion =
            level.colorRegions[r1][c1] == level.colorRegions[r2][c2];
        final adjacent = (r1 - r2).abs() <= 1 && (c1 - c2).abs() <= 1;

        if (sameRow || sameCol || sameRegion || adjacent) {
          conflicts[r1][c1] = true;
          conflicts[r2][c2] = true;
        }
      }
    }

    return conflicts;
  }

  /// Counts the queens on the board.
  static int countQueens(List<List<CellState>> board) {
    int count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == CellState.queen) count++;
      }
    }
    return count;
  }

  /// True if the board is a complete, conflict-free solution.
  static bool isComplete(List<List<CellState>> board, GameLevel level) {
    final n = level.gridSize;
    if (countQueens(board) != n) return false;
    final conflicts = computeConflicts(board, level);
    for (final row in conflicts) {
      for (final cell in row) {
        if (cell) return false;
      }
    }
    return true;
  }

  /// Suggests a single cell where a queen should be placed.
  ///
  /// Deduction-first: if any row or colour region has exactly one cell that can
  /// still legally hold a queen, that placement is logically forced and is
  /// returned. When nothing is strictly forced (possible because levels are not
  /// guaranteed to have a unique solution), it falls back to the generator's
  /// reference solution and returns a correct queen that has not been placed
  /// yet. Returns null only when every solution queen is already placed.
  static List<int>? suggestHint(List<List<CellState>> board, GameLevel level) {
    final n = level.gridSize;

    // A cell is a candidate if it is empty and not blocked by an existing queen.
    bool isCandidate(int r, int c) =>
        board[r][c] == CellState.empty && !isCellBlocked(r, c, board, level);

    bool rowHasQueen(int r) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == CellState.queen) return true;
      }
      return false;
    }

    // 1a. Row with exactly one candidate cell.
    for (int r = 0; r < n; r++) {
      if (rowHasQueen(r)) continue;
      final candidates = <List<int>>[];
      for (int c = 0; c < n; c++) {
        if (isCandidate(r, c)) candidates.add([r, c]);
      }
      if (candidates.length == 1) return candidates.first;
    }

    // 1b. Region with exactly one candidate cell.
    final regionHasQueen = List<bool>.filled(n, false);
    final regionCandidates = List.generate(n, (_) => <List<int>>[]);
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final region = level.colorRegions[r][c];
        if (board[r][c] == CellState.queen) {
          regionHasQueen[region] = true;
        } else if (isCandidate(r, c)) {
          regionCandidates[region].add([r, c]);
        }
      }
    }
    for (int region = 0; region < n; region++) {
      if (regionHasQueen[region]) continue;
      if (regionCandidates[region].length == 1) {
        return regionCandidates[region].first;
      }
    }

    // 2. Fallback to the generator's reference solution.
    for (int r = 0; r < n; r++) {
      final c = level.solutionCols[r];
      if (board[r][c] != CellState.queen) return [r, c];
    }

    return null;
  }
}
