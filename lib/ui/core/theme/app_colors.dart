import 'package:material_ui/material_ui.dart';
import 'package:queens/domain/models/app_settings.dart';

class AppColors {
  AppColors._();

  static AppThemePreset currentTheme = AppThemePreset.obsidian;

  static Color get primary => currentTheme.primary;
  static Color get accent => currentTheme.accent;
  static Color get headingDark => currentTheme.headingDark;
  static Color get headingWhite => currentTheme.headingWhite;
  static Color get subtext => currentTheme.subtext;
  static Color get bg => currentTheme.bg;
  static Color get gridLines => currentTheme.gridLines;
  static Color get surface => currentTheme.surface;
  static Color get border => currentTheme.border;

  static Color get darkBg => bg;
  static Color get darkSurface => surface;
  static Color get darkCard => surface;
  static Color get darkBorder => border;

  static Color get lightBg => bg;
  static Color get lightSurface => surface;
  static Color get lightCard => surface;
  static Color get lightBorder => border;

  static const List<Color> queensColors = [
    Color(0xFFE53935),
    Color(0xFFFF9800),
    Color(0xFFFFEB3B),
    Color(0xFF00897B),
    Color(0xFF2E7D32),
    Color(0xFF00BCD4),
    Color(0xFF2196F3),
    Color(0xFF3F51B5),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];
}

class GameColors {
  GameColors._();

  static const Color bg = Color(0xFF121212);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color primary = Color(0xFF2D2D2D);
  static const Color headingDark = Color(0xFFFFFFFF);
  static const Color headingWhite = Color(0xFF121212);
  static const Color subtext = Color(0xFF888888);
  static const Color gridLines = Color(0xFF2D2D2D);
  static const Color border = Color(0x3DFFFFFF);
}
