import 'package:hive_flutter/hive_flutter.dart';

import 'package:queens/domain/models/app_settings.dart';

class SettingsService {
  static const String _boxName = 'queen_settings';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  AppSettings getSettings() {
    final box = Hive.box(_boxName);
    final isColorblindMode = box.get('colorblind_mode', defaultValue: false) as bool;
    final isAutoCrossDisabled = box.get('auto_cross_disabled', defaultValue: false) as bool;
    final crownSkinId = box.get('crown_skin', defaultValue: 'classic') as String?;
    final isHintEnabled = box.get('hint_enabled', defaultValue: false) as bool;
    final themeId = box.get('app_theme', defaultValue: 'obsidian') as String?;
    final resolvedTheme = AppThemePreset.fromId(themeId);
    final resolvedSkin = CrownSkin.fromId(crownSkinId);
    return AppSettings(
      isColorblindMode: isColorblindMode,
      isAutoCrossDisabled: isAutoCrossDisabled,
      crownSkin: resolvedSkin,
      isHintEnabled: isHintEnabled,
      theme: resolvedTheme,
      isUnlocked: true,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = Hive.box(_boxName);
    await box.put('colorblind_mode', settings.isColorblindMode);
    await box.put('auto_cross_disabled', settings.isAutoCrossDisabled);
    await box.put('crown_skin', settings.crownSkin.id);
    await box.put('hint_enabled', settings.isHintEnabled);
    await box.put('app_theme', settings.theme.id);
  }
}
