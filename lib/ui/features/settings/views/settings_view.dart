import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:queens/domain/models/app_settings.dart';
import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/crown_widget.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';
import 'package:queens/ui/features/settings/widgets/unlock_themes_dialog.dart';
import 'package:queens/ui/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  _sectionTitle(
                    title: 'THEME',
                    valueText: settings.theme.displayName.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppThemePreset.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final preset = AppThemePreset.values[index];
                        final isSelected = settings.theme == preset;
                        final isLocked = !preset.isFree && !settings.isUnlocked;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (isLocked) {
                              UnlockThemesDialog.show(
                                context,
                                targetPreset: preset,
                              );
                              return;
                            }
                            ref
                                .read(settingsProvider.notifier)
                                .setTheme(preset);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: preset.bg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? preset.accent
                                    : preset.border,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: preset.accent.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isLocked
                                  ? Icon(
                                      Icons.lock_rounded,
                                      size: 14,
                                      color: preset.accent.withValues(alpha: 0.8),
                                    )
                                  : Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: preset.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _divider(),

                  _sectionTitle(
                    title: 'PIECE',
                    valueText: settings.crownSkin.displayName.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: CrownSkin.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final skin = CrownSkin.values[index];
                        final isSelected = settings.crownSkin == skin;
                        final isLocked = !skin.isFree && !settings.isUnlocked;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (isLocked) {
                              UnlockThemesDialog.show(
                                context,
                                targetCrownSkin: skin,
                              );
                              return;
                            }
                            ref
                                .read(settingsProvider.notifier)
                                .setCrownSkin(skin);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.16)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: isLocked ? 0.35 : 1.0,
                                    child: CrownWidget(
                                      size: 28,
                                      skin: skin,
                                      color: isSelected
                                          ? const Color(0xFFFFCC00)
                                          : AppColors.headingDark,
                                    ),
                                  ),
                                  if (isLocked)
                                    IgnorePointer(
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface.withValues(alpha: 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock_rounded,
                                          size: 12,
                                          color: AppColors.headingDark,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _divider(),

                  _gameToggle(
                    label: 'AUTO-CROSS',
                    value: !settings.isAutoCrossDisabled,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleAutoCrossDisabled(!val);
                    },
                  ),
                  _gameToggle(
                    label: 'HINTS',
                    value: settings.isHintEnabled,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleHintEnabled(val);
                    },
                  ),
                  _gameToggle(
                    label: 'COLORBLIND',
                    value: settings.isColorblindMode,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleColorblindMode(val);
                    },
                  ),

                  _divider(),

                  const SizedBox(height: 8),
                  TangibleButton(
                    text: 'BECOME A BACKER',
                    height: 48,
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.headingDark,
                    borderColor: AppColors.border,
                    onPressed: () => _openUrl('https://liberapay.com/sidhant947/donate'),
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: 'RESET PROGRESS',
                    isSecondary: true,
                    height: 48,
                    backgroundColor: AppColors.surface,
                    textColor: const Color(0xFFFF5252),
                    borderColor: const Color(0x55FF5252),
                    onPressed: () => _confirmReset(context, ref),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required String title, required String valueText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.headingDark,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          valueText,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  Widget _gameToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.headingDark,
              letterSpacing: 1.5,
            ),
          ),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!value) {
                      HapticFeedback.selectionClick();
                      onChanged(true);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'ON',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: value
                            ? (AppColors.currentTheme.isDark
                                ? const Color(0xFF121212)
                                : const Color(0xFFFFFFFF))
                            : AppColors.subtext,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (value) {
                      HapticFeedback.selectionClick();
                      onChanged(false);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !value
                          ? AppColors.headingDark.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'OFF',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: !value ? AppColors.headingDark : AppColors.subtext,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RESET PROGRESS?',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingDark,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'All solved puzzles, best times, and saved games will be permanently erased.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subtext,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: 'CANCEL',
                      isSecondary: true,
                      height: 46,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TangibleButton(
                      text: 'RESET',
                      backgroundColor: const Color(0xFFD32F2F),
                      textColor: Colors.white,
                      borderColor: const Color(0xFFFF5252),
                      height: 46,
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .resetProgress();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }
}
