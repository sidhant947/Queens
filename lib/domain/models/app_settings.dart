import 'package:material_ui/material_ui.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.colorblindMode = false,
  });

  /// When true, the board draws region-boundary borders so colour regions are
  /// distinguishable without relying on hue alone.
  final bool colorblindMode;

  AppSettings copyWith({bool? colorblindMode}) {
    return AppSettings(
      colorblindMode: colorblindMode ?? this.colorblindMode,
    );
  }
}
