import 'package:material_ui/material_ui.dart';

enum CrownSkin {
  classic('classic', 'Default', null),
  queen('queen', 'Queen', 'assets/icons/queen.png'),
  cat('cat', 'Cat', 'assets/icons/cat.png'),
  dog('dog', 'Dog', 'assets/icons/dog.png'),
  rabbit('rabbit', 'Rabbit', 'assets/icons/rabbit.png'),
  bear('bear', 'Bear', 'assets/icons/bear.png'),
  fox('fox', 'Fox', 'assets/icons/fox.png'),
  panda('panda', 'Panda', 'assets/icons/panda.png');

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

  bool get isFree =>
      this == CrownSkin.classic ||
      this == CrownSkin.queen ||
      this == CrownSkin.cat;
}

enum AppThemePreset {
  obsidian(
    id: 'obsidian',
    displayName: 'Obsidian',
    bg: Color(0xFF121212),
    surface: Color(0xFF1C1C1C),
    primary: Color(0xFF2D2D2D),
    headingDark: Color(0xFFFFFFFF),
    headingWhite: Color(0xFF121212),
    subtext: Color(0xFF888888),
    gridLines: Color(0xFF2D2D2D),
    accent: Color(0xFFFFFFFF),
    border: Color(0x3DFFFFFF),
  ),
  midnight(
    id: 'midnight',
    displayName: 'Midnight',
    bg: Color(0xFF0B132B),
    surface: Color(0xFF1C2541),
    primary: Color(0xFF3A506B),
    headingDark: Color(0xFFE0E6ED),
    headingWhite: Color(0xFF0B132B),
    subtext: Color(0xFF7A8B99),
    gridLines: Color(0xFF2C3E55),
    accent: Color(0xFF5BC0BE),
    border: Color(0x3DE0E6ED),
  ),
  emerald(
    id: 'emerald',
    displayName: 'Emerald',
    bg: Color(0xFF0A1C14),
    surface: Color(0xFF122E22),
    primary: Color(0xFF1B4332),
    headingDark: Color(0xFFD8F3DC),
    headingWhite: Color(0xFF0A1C14),
    subtext: Color(0xFF74C69D),
    gridLines: Color(0xFF2D5D46),
    accent: Color(0xFF52B788),
    border: Color(0x3DD8F3DC),
  ),
  cyberpunk(
    id: 'cyberpunk',
    displayName: 'Cyberpunk',
    bg: Color(0xFF0E0720),
    surface: Color(0xFF1B1035),
    primary: Color(0xFF49117D),
    headingDark: Color(0xFF00F5D4),
    headingWhite: Color(0xFF0E0720),
    subtext: Color(0xFF9B82C1),
    gridLines: Color(0xFF3C1361),
    accent: Color(0xFFF72585),
    border: Color(0x3D00F5D4),
  ),
  crimson(
    id: 'crimson',
    displayName: 'Crimson',
    bg: Color(0xFF1A0A0E),
    surface: Color(0xFF2B1219),
    primary: Color(0xFF4A1E29),
    headingDark: Color(0xFFFCE7EA),
    headingWhite: Color(0xFF1A0A0E),
    subtext: Color(0xFFA76D79),
    gridLines: Color(0xFF411722),
    accent: Color(0xFFFF3366),
    border: Color(0x3DFCE7EA),
  ),
  sunset(
    id: 'sunset',
    displayName: 'Sunset',
    bg: Color(0xFF1C1412),
    surface: Color(0xFF2B1D19),
    primary: Color(0xFF442E27),
    headingDark: Color(0xFFFFF1E8),
    headingWhite: Color(0xFF1C1412),
    subtext: Color(0xFFB58E7D),
    gridLines: Color(0xFF3E271F),
    accent: Color(0xFFFF8C42),
    border: Color(0x3DFFF1E8),
  ),
  nordic(
    id: 'nordic',
    displayName: 'Nordic',
    bg: Color(0xFF131921),
    surface: Color(0xFF1E2631),
    primary: Color(0xFF2D3949),
    headingDark: Color(0xFFECEFF4),
    headingWhite: Color(0xFF131921),
    subtext: Color(0xFF8190A5),
    gridLines: Color(0xFF344254),
    accent: Color(0xFF88C0D0),
    border: Color(0x3DECEFF4),
  ),
  monokai(
    id: 'monokai',
    displayName: 'Monokai',
    bg: Color(0xFF1E1F1C),
    surface: Color(0xFF272822),
    primary: Color(0xFF3E3D32),
    headingDark: Color(0xFFF8F8F2),
    headingWhite: Color(0xFF1E1F1C),
    subtext: Color(0xFF75715E),
    gridLines: Color(0xFF383830),
    accent: Color(0xFFE6DB74),
    border: Color(0x3DF8F8F2),
  ),
  amethyst(
    id: 'amethyst',
    displayName: 'Amethyst',
    bg: Color(0xFF140C20),
    surface: Color(0xFF211434),
    primary: Color(0xFF392257),
    headingDark: Color(0xFFF2E9E4),
    headingWhite: Color(0xFF140C20),
    subtext: Color(0xFF9D81BA),
    gridLines: Color(0xFF3B205D),
    accent: Color(0xFFC77DFF),
    border: Color(0x3DF2E9E4),
  ),
  coffee(
    id: 'coffee',
    displayName: 'Coffee',
    bg: Color(0xFF161210),
    surface: Color(0xFF241D1A),
    primary: Color(0xFF3A2E29),
    headingDark: Color(0xFFF5EBE6),
    headingWhite: Color(0xFF161210),
    subtext: Color(0xFF9C877D),
    gridLines: Color(0xFF382C26),
    accent: Color(0xFFD4A373),
    border: Color(0x3DF5EBE6),
  ),
  solarized(
    id: 'solarized',
    displayName: 'Solarized',
    bg: Color(0xFF001E26),
    surface: Color(0xFF002B36),
    primary: Color(0xFF073642),
    headingDark: Color(0xFFEEE8D5),
    headingWhite: Color(0xFF001E26),
    subtext: Color(0xFF657B83),
    gridLines: Color(0xFF0C4352),
    accent: Color(0xFF2AA198),
    border: Color(0x3DEEE8D5),
  ),
  ivory(
    id: 'ivory',
    displayName: 'Ivory',
    bg: Color(0xFFFAF6EE),
    surface: Color(0xFFEDE8DC),
    primary: Color(0xFFD8D2C4),
    headingDark: Color(0xFF2B2D42),
    headingWhite: Color(0xFFFAF6EE),
    subtext: Color(0xFF6C757D),
    gridLines: Color(0xFFD0CAB8),
    accent: Color(0xFFE07A5F),
    border: Color(0x3D2B2D42),
  );

  const AppThemePreset({
    required this.id,
    required this.displayName,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.headingDark,
    required this.headingWhite,
    required this.subtext,
    required this.gridLines,
    required this.accent,
    required this.border,
  });

  final String id;
  final String displayName;
  final Color bg;
  final Color surface;
  final Color primary;
  final Color headingDark;
  final Color headingWhite;
  final Color subtext;
  final Color gridLines;
  final Color accent;
  final Color border;

  static AppThemePreset fromId(String? id) {
    return AppThemePreset.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AppThemePreset.obsidian,
    );
  }

  bool get isDark => bg.computeLuminance() < 0.5;

  bool get isFree =>
      this == AppThemePreset.obsidian ||
      this == AppThemePreset.midnight ||
      this == AppThemePreset.emerald;
}

@immutable
class AppSettings {
  const AppSettings({
    this.isColorblindMode = false,
    this.isAutoCrossDisabled = false,
    this.crownSkin = CrownSkin.classic,
    this.isHintEnabled = false,
    this.theme = AppThemePreset.obsidian,
    this.isUnlocked = false,
  });

  final bool isColorblindMode;
  final bool isAutoCrossDisabled;
  final CrownSkin crownSkin;
  final bool isHintEnabled;
  final AppThemePreset theme;
  final bool isUnlocked;

  AppSettings copyWith({
    bool? isColorblindMode,
    bool? isAutoCrossDisabled,
    CrownSkin? crownSkin,
    bool? isHintEnabled,
    AppThemePreset? theme,
    bool? isUnlocked,
  }) {
    return AppSettings(
      isColorblindMode: isColorblindMode ?? this.isColorblindMode,
      isAutoCrossDisabled: isAutoCrossDisabled ?? this.isAutoCrossDisabled,
      crownSkin: crownSkin ?? this.crownSkin,
      isHintEnabled: isHintEnabled ?? this.isHintEnabled,
      theme: theme ?? this.theme,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
