import 'package:material_ui/material_ui.dart';

enum CrownSkin {
  classic('classic', 'Default', null),
  queen('queen', 'Queen', 'assets/icons/queen.png'),
  cat('cat', 'Cat', 'assets/icons/cat.png'),
  dog('dog', 'Dog', 'assets/icons/dog.png'),
  rabbit('rabbit', 'Rabbit', 'assets/icons/rabbit.png');

  const CrownSkin(this.id, this.displayName, this.assetPath);

  final String id;
  final String displayName;
  final String? assetPath;

  static CrownSkin fromId(String? id) {
    return CrownSkin.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CrownSkin.classic,
    );
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.isColorblindMode = false,
    this.isAutoCrossDisabled = false,
    this.crownSkin = CrownSkin.classic,
    this.isHintEnabled = false,
  });

  final bool isColorblindMode;
  final bool isAutoCrossDisabled;
  final CrownSkin crownSkin;
  final bool isHintEnabled;

  AppSettings copyWith({
    bool? isColorblindMode,
    bool? isAutoCrossDisabled,
    CrownSkin? crownSkin,
    bool? isHintEnabled,
  }) {
    return AppSettings(
      isColorblindMode: isColorblindMode ?? this.isColorblindMode,
      isAutoCrossDisabled: isAutoCrossDisabled ?? this.isAutoCrossDisabled,
      crownSkin: crownSkin ?? this.crownSkin,
      isHintEnabled: isHintEnabled ?? this.isHintEnabled,
    );
  }
}
