import 'package:material_ui/material_ui.dart';
import 'package:queens/domain/models/app_settings.dart';

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

  static ThemeData fromPreset(AppThemePreset preset) {
    final isLight = preset == AppThemePreset.ivory;
    return ThemeData(
      fontFamily: 'BebasNeue',
      pageTransitionsTheme: _noTransitionTheme,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: preset.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: preset.headingDark,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: preset.headingDark),
      ),
      dividerTheme: DividerThemeData(
        color: preset.border,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        displayMedium: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        displaySmall: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        headlineLarge: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        headlineSmall: TextStyle(color: preset.headingDark, letterSpacing: -0.5),
        titleLarge: TextStyle(color: preset.headingDark, letterSpacing: 0.5),
        titleMedium: TextStyle(color: preset.headingDark, letterSpacing: 0.5),
        bodyLarge: TextStyle(color: preset.headingDark, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: preset.subtext, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(color: preset.headingDark, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get light => fromPreset(AppThemePreset.ivory);
  static ThemeData get dark => fromPreset(AppThemePreset.obsidian);
}
