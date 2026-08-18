import 'package:material_ui/material_ui.dart';

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.gridSize,
    required this.colorRegions,
    required this.regionColors,
    required this.solutionCols,
  });

  final int levelNumber;
  final int gridSize;
  final List<List<int>> colorRegions;
  final List<Color> regionColors;
  final List<int> solutionCols;

  GameLevel copyWith({
    int? levelNumber,
    int? gridSize,
    List<List<int>>? colorRegions,
    List<Color>? regionColors,
    List<int>? solutionCols,
  }) {
    return GameLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      gridSize: gridSize ?? this.gridSize,
      colorRegions: colorRegions ?? this.colorRegions,
      regionColors: regionColors ?? this.regionColors,
      solutionCols: solutionCols ?? this.solutionCols,
    );
  }
}
