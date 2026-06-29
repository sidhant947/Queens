import 'package:flutter/material.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
    this.totalMoves = 0,
  });

  final int currentLevel;
  final int highestLevelCompleted;
  final int totalMoves;

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
    int? totalMoves,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted:
          highestLevelCompleted ?? this.highestLevelCompleted,
      totalMoves: totalMoves ?? this.totalMoves,
    );
  }

  UserProgress incrementLevel() {
    return UserProgress(
      currentLevel: currentLevel + 1,
      highestLevelCompleted: currentLevel,
      totalMoves: totalMoves,
    );
  }

  UserProgress addMoves(int moves) {
    return copyWith(totalMoves: totalMoves + moves);
  }
}
