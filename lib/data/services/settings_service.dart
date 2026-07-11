import 'package:hive_flutter/hive_flutter.dart';

import 'package:queens/domain/models/app_settings.dart';

/// Persists [AppSettings] as primitive values in a small Hive box, so no
/// custom TypeAdapter is required.
class SettingsService {
  static const String _boxName = 'queen_settings';
  static const String _colorblindKey = 'colorblind_mode';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  AppSettings getSettings() {
    return AppSettings(
      colorblindMode: _box.get(_colorblindKey, defaultValue: false) as bool,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_colorblindKey, settings.colorblindMode);
  }
}
