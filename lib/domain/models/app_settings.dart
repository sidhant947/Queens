import 'package:material_ui/material_ui.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.isColorblindMode = false,
    this.isAutoCrossDisabled = false,
  });

  final bool isColorblindMode;
  final bool isAutoCrossDisabled;

  AppSettings copyWith({
    bool? isColorblindMode,
    bool? isAutoCrossDisabled,
  }) {
    return AppSettings(
      isColorblindMode: isColorblindMode ?? this.isColorblindMode,
      isAutoCrossDisabled: isAutoCrossDisabled ?? this.isAutoCrossDisabled,
    );
  }
}

