import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/domain/models/app_settings.dart';
import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/crown_widget.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';
import 'package:queens/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 1.0,
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
                padding: const EdgeInsets.fromLTRB(24, 16, 28, 28),
                children: [
                  Builder(
                    builder: (context) {
                      final settings = ref.watch(settingsProvider);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUEEN ICON',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headingDark,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Choose the icon style for pieces placed on the board',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtext,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: CrownSkin.values.map((skin) {
                                  final isSelected = settings.crownSkin == skin;
                                  return GestureDetector(
                                    onTap: () => ref
                                        .read(settingsProvider.notifier)
                                        .setCrownSkin(skin),
                                    child: Container(
                                      width: 78,
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF2A2A2A)
                                            : const Color(0xFF161616),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white12,
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: Center(
                                              child: CrownWidget(
                                                color: const Color(0xFFFFCC00),
                                                size: 38,
                                                skin: skin,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            skin.displayName.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'BebasNeue',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? AppColors.headingDark
                                                  : AppColors.subtext,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final settings = ref.watch(settingsProvider);
                      final isON = settings.isColorblindMode;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'COLORBLIND MODE',
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingDark,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Add region borders to assist color perception',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.subtext,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isON,
                              onChanged: (val) => ref
                                  .read(settingsProvider.notifier)
                                  .toggleColorblindMode(val),
                              activeThumbColor: AppColors.headingDark,
                              activeTrackColor: AppColors.primary,
                              inactiveThumbColor: AppColors.subtext,
                              inactiveTrackColor: AppColors.bg,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final settings = ref.watch(settingsProvider);
                      final isAutoCrossDisabled = settings.isAutoCrossDisabled;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'DISABLE AUTO-CROSS',
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingDark,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Stop automatic X marks when placing a queen',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.subtext,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isAutoCrossDisabled,
                              onChanged: (val) => ref
                                  .read(settingsProvider.notifier)
                                  .toggleAutoCrossDisabled(val),
                              activeThumbColor: AppColors.headingDark,
                              activeTrackColor: AppColors.primary,
                              inactiveThumbColor: AppColors.subtext,
                              inactiveTrackColor: AppColors.bg,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  TangibleButton(
                    text: 'Reset Progress',
                    isSecondary: true,
                    onPressed: () => _confirmReset(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1.0),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RESET PROGRESS?',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This clears all level progress and best scores. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 24),
              TangibleButton(
                text: 'Reset Everything',
                onPressed: () async {
                  await ref.read(homeViewModelProvider.notifier).resetProgress();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    color: AppColors.subtext,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
