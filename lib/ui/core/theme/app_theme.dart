import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 1. Light Neobrutalist Theme (Warm Ivory & Charcoal)
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAF6EE),
    fontFamily: 'BebasNeue',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color(0xFF2B2D42),
        letterSpacing: 1.0,
      ),
      iconTheme: IconThemeData(color: Color(0xFF2B2D42)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E2E6),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineSmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: -0.5),
      titleLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: 0.5),
      titleMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), letterSpacing: 0.5),
      bodyLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF6C757D), fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF2B2D42), fontWeight: FontWeight.bold),
    ),
  );

  // 2. Premium Obsidian Dark Neobrutalist Theme (Deep Night Obsidian & Cream Highlights)
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121318), // Deep Premium Obsidian
    fontFamily: 'BebasNeue',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFAF6EE), // Cream white
        letterSpacing: 1.0,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFAF6EE)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF232530),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineSmall: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      titleLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      titleMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      bodyLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFF8E92A6), fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontFamily: 'BebasNeue', color: Color(0xFFFAF6EE), fontWeight: FontWeight.bold),
    ),
  );
}
