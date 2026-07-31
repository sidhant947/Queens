import 'package:hive_flutter/hive_flutter.dart';

import 'package:queens/domain/models/app_settings.dart';

/// Persists [AppSettings] as primitive values in a small Hive box, so no
/// custom TypeAdapter is required.
class SettingsService {
  static const String _boxName = 'queen_settings';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  AppSettings getSettings() {
    final box = Hive.box(_boxName);
    final isColorblindMode = box.get('colorblind_mode', defaultValue: false) as bool;
    final isAutoCrossDisabled = box.get('auto_cross_disabled', defaultValue: false) as bool;
    return AppSettings(
      isColorblindMode: isColorblindMode,
      isAutoCrossDisabled: isAutoCrossDisabled,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = Hive.box(_boxName);
    await box.put('colorblind_mode', settings.isColorblindMode);
    await box.put('auto_cross_disabled', settings.isAutoCrossDisabled);
  }
}

