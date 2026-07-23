import 'package:material_ui/material_ui.dart';

/// A page transitions builder that applies no animation at all.
class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  // 1. Light Neobrutalist Theme (Warm Ivory & Charcoal)
  static ThemeData get light => ThemeData(
    fontFamily: 'BebasNeue',
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAF6EE),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
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
      displayLarge: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      displayMedium: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      displaySmall: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineLarge: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineMedium: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      headlineSmall: TextStyle(color: Color(0xFF2B2D42), letterSpacing: -0.5),
      titleLarge: TextStyle(color: Color(0xFF2B2D42), letterSpacing: 0.5),
      titleMedium: TextStyle(color: Color(0xFF2B2D42), letterSpacing: 0.5),
      bodyLarge: TextStyle(color: Color(0xFF2B2D42), fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: Color(0xFF6C757D), fontWeight: FontWeight.normal),
      labelLarge: TextStyle(color: Color(0xFF2B2D42), fontWeight: FontWeight.bold),
    ),
  );

  // 2. Premium Obsidian Dark Neobrutalist Theme (Deep Night Obsidian & Cream Highlights)
  static ThemeData get dark => ThemeData(
    fontFamily: 'BebasNeue',
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121318), // Deep Premium Obsidian
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
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
      displayLarge: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displayMedium: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      displaySmall: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineLarge: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineMedium: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      headlineSmall: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: -0.5),
      titleLarge: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      titleMedium: TextStyle(color: Color(0xFFFAF6EE), letterSpacing: 0.5),
      bodyLarge: TextStyle(color: Color(0xFFFAF6EE), fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: Color(0xFF8E92A6), fontWeight: FontWeight.normal),
      labelLarge: TextStyle(color: Color(0xFFFAF6EE), fontWeight: FontWeight.bold),
    ),
  );
}
