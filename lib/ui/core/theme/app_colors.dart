import 'package:material_ui/material_ui.dart';

class AppColors {
  AppColors._();

  // Core palette - Charcoal + White Theme
  static const Color primary = Color(0xFF2D2D2D); // Dark charcoal for primary buttons
  static const Color accent = Color(0xFFFFFFFF); // White for accents
  static const Color headingDark = Color(0xFFFFFFFF); // White text
  static const Color headingWhite = Color(0xFF121212); // Charcoal background text
  static const Color subtext = Color(0xFF888888); // Muted gray
  static const Color bg = Color(0xFF121212); // Pure charcoal background
  static const Color gridLines = Color(0xFF2D2D2D); // Dark gray for grid lines
  static const Color surface = Color(0xFF1C1C1C); // Medium charcoal for cards/surfaces

  // Unified theme configs
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color darkCard = Color(0xFF1C1C1C);
  static const Color darkBorder = Color(0xFF2D2D2D);

  static const Color lightBg = Color(0xFF121212);
  static const Color lightSurface = Color(0xFF1C1C1C);
  static const Color lightCard = Color(0xFF1C1C1C);
  static const Color lightBorder = Color(0xFF2D2D2D);

  // Exactly 12 maximally distinct colors for the 12x12 grid limit
  static const List<Color> queensColors = [
    Color(0xFFE53935), // 1. Red
    Color(0xFFFF9800), // 2. Orange
    Color(0xFFFFEB3B), // 3. Yellow
    Color(0xFF8BC34A), // 4. Lime
    Color(0xFF4CAF50), // 5. Green
    Color(0xFF00BCD4), // 6. Cyan
    Color(0xFF2196F3), // 7. Blue
    Color(0xFF3F51B5), // 8. Indigo
    Color(0xFF9C27B0), // 9. Purple
    Color(0xFFE91E63), // 10. Pink
    Color(0xFF795548), // 11. Brown
    Color(0xFF607D8B), // 12. Blue Grey
  ];
}
