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
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    // No-op since settings is currently empty.
  }
}
