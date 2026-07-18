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

  // 16 rich, vibrant, and highly distinctive modern colors that pop beautifully on charcoal background
  static const List<Color> queensColors = [
    Color(0xFF0EA5E9), // Vibrant Sky Blue
    Color(0xFF6366F1), // Vibrant Indigo
    Color(0xFF10B981), // Vibrant Emerald Green
    Color(0xFFF59E0B), // Rich Amber
    Color(0xFFF43F5E), // Vibrant Rose Pink
    Color(0xFF8B5CF6), // Vibrant Violet
    Color(0xFF06B6D4), // Electric Cyan
    Color(0xFF84CC16), // Bright Lime
    Color(0xFFEAB308), // Rich Gold
    Color(0xFFF97316), // Bright Orange
    Color(0xFFD946EF), // Vibrant Fuchsia
    Color(0xFF22C55E), // Forest Green
    Color(0xFF7F9CF5), // Medium Lavender Blue
    Color(0xFFEF4444), // Bright Red
    Color(0xFF14B8A6), // Vibrant Teal
    Color(0xFFA855F7), // Vibrant Purple
  ];
}
