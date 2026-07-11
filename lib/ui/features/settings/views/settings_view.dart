import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';
import 'package:queens/ui/providers.dart';

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
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.headingDark,
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.headingDark,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
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
                  _settingCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COLORBLIND MODE',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.headingDark,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Show region borders so regions are distinct without colour.',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: settings.colorblindMode,
                          activeThumbColor: AppColors.headingDark,
                          onChanged: (value) => ref
                              .read(settingsProvider.notifier)
                              .setColorblindMode(value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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

  Widget _settingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.headingDark, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.headingDark,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
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
            border: Border.all(color: AppColors.headingDark, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.headingDark,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
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
                  fontFamily: 'BebasNeue',
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
