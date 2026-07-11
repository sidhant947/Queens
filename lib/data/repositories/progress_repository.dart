import 'package:queens/domain/models/user_progress.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';
import '../services/hive_service.dart';

class ProgressRepository {
  ProgressRepository({required this._hiveService});

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    await _hiveService.saveProgress(progress);
  }

  Future<void> completeLevel(int moves) async {
    final current = await getProgress();
    final updated = current.incrementLevel().addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> addRandomLevelMoves(int moves) async {
    final current = await getProgress();
    final updated = current.addMoves(moves);
    await saveProgress(updated);
  }

  /// Records the best moves/time for a completed level.
  Future<void> recordLevelResult(int level, int moves, int seconds) async {
    final current = await getProgress();
    await saveProgress(current.recordLevelResult(level, moves, seconds));
  }

  /// Persists the current in-progress (non-random) board so it can be resumed.
  Future<void> saveInProgress(
    int level,
    List<List<CellState>> board,
    int moves,
    int seconds,
  ) async {
    final current = await getProgress();
    await saveProgress(
      current.withSavedGame(
        levelNumber: level,
        board: board,
        moveCount: moves,
        elapsedSeconds: seconds,
      ),
    );
  }

  /// Clears any saved in-progress game (e.g. after completion).
  Future<void> clearInProgress() async {
    final current = await getProgress();
    if (current.savedLevelNumber == null) return;
    await saveProgress(current.withoutSavedGame());
  }

  Future<void> resetProgress() async {
    _cachedProgress = null;
    await _hiveService.clearProgress();
  }
}
