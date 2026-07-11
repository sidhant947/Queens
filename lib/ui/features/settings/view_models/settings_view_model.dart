import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/data/services/settings_service.dart';
import 'package:queens/domain/models/app_settings.dart';

class SettingsViewModel extends StateNotifier<AppSettings> {
  SettingsViewModel({required this.settingsService})
      : super(settingsService.getSettings());

  final SettingsService settingsService;

  Future<void> setColorblindMode(bool enabled) async {
    state = state.copyWith(colorblindMode: enabled);
    await settingsService.saveSettings(state);
  }
}
