import 'package:flutter_test/flutter_test.dart';

import 'package:queens/domain/models/user_progress.dart';

void main() {
  test('incrementLevel advances current and raises highest', () {
    const p = UserProgress(currentLevel: 5, highestLevelCompleted: 4);
    final next = p.incrementLevel();
    expect(next.currentLevel, 6);
    expect(next.highestLevelCompleted, 5);
  });

  test('incrementLevel never lowers highestLevelCompleted on replay', () {
    // Player is replaying level 3 while highest is already 10.
    const p = UserProgress(currentLevel: 3, highestLevelCompleted: 10);
    final next = p.incrementLevel();
    expect(next.currentLevel, 4);
    expect(next.highestLevelCompleted, 10); // unchanged, not lowered to 3
  });

  test('recordLevelResult keeps the minimum moves and time', () {
    const p = UserProgress();
    final first = p.recordLevelResult(2, 20, 90);
    expect(first.bestMoves[2], 20);
    expect(first.bestTimeSeconds[2], 90);

    // A worse run does not overwrite.
    final worse = first.recordLevelResult(2, 30, 120);
    expect(worse.bestMoves[2], 20);
    expect(worse.bestTimeSeconds[2], 90);

    // A better run does.
    final better = worse.recordLevelResult(2, 15, 70);
    expect(better.bestMoves[2], 15);
    expect(better.bestTimeSeconds[2], 70);
  });

  test('withSavedGame and withoutSavedGame round-trip', () {
    const p = UserProgress(currentLevel: 4);
    final saved = p.withSavedGame(
      levelNumber: 4,
      board: const [],
      moveCount: 12,
      elapsedSeconds: 34,
    );
    expect(saved.savedLevelNumber, 4);
    expect(saved.savedMoveCount, 12);
    expect(saved.savedElapsedSeconds, 34);
    expect(saved.savedBoard, isNotNull);

    final cleared = saved.withoutSavedGame();
    expect(cleared.savedLevelNumber, isNull);
    expect(cleared.savedBoard, isNull);
    expect(cleared.savedMoveCount, 0);
    // Other progress is preserved.
    expect(cleared.currentLevel, 4);
  });

  test('defaults are sensible for a fresh profile', () {
    const p = UserProgress();
    expect(p.currentLevel, 1);
    expect(p.highestLevelCompleted, 0);
    expect(p.bestMoves, isEmpty);
    expect(p.savedLevelNumber, isNull);
  });
}
