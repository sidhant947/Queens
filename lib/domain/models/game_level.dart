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
  final List<List<int>> colorRegions; // gridSize x gridSize grid of region indices (0 to gridSize - 1)
  final List<Color> regionColors; // list of gridSize colors
  final List<int> solutionCols; // solutionCols[row] = column of the queen in that row

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
