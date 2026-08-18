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
    state = state.copyWith(crownSkin: skin);
    await settingsService.saveSettings(state);
  }
}
