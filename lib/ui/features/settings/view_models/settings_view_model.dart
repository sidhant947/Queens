import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/services/settings_service.dart';
import 'package:queens/domain/models/app_settings.dart';

class SettingsViewModel extends StateNotifier<AppSettings> {
  SettingsViewModel({required this.settingsService})
      : super(settingsService.getSettings());

  final SettingsService settingsService;

  Future<void> toggleColorblindMode(bool value) async {
    state = state.copyWith(isColorblindMode: value);
    await settingsService.saveSettings(state);
  }

  Future<void> toggleAutoCrossDisabled(bool value) async {
    state = state.copyWith(isAutoCrossDisabled: value);
    await settingsService.saveSettings(state);
  }

  Future<void> setCrownSkin(CrownSkin skin) async {
    if (!skin.isFree && !state.isUnlocked) {
      return;
    }
    state = state.copyWith(crownSkin: skin);
    await settingsService.saveSettings(state);
  }

  Future<void> setTheme(AppThemePreset theme) async {
    if (!theme.isFree && !state.isUnlocked) {
      return;
    }
    state = state.copyWith(theme: theme);
    await settingsService.saveSettings(state);
  }

  Future<void> toggleHintEnabled(bool value) async {
    state = state.copyWith(isHintEnabled: value);
    await settingsService.saveSettings(state);
  }

  Future<bool> unlock(String code) async {
    if (code.trim().toLowerCase() == 'thankyou') {
      state = state.copyWith(isUnlocked: true);
      await settingsService.saveSettings(state);
      return true;
    }
    return false;
  }
}
