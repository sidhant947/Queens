import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';
import 'package:queens/ui/core/widgets/crown_widget.dart';
import 'package:queens/ui/features/game/views/game_view.dart';
import 'package:queens/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:queens/ui/features/level_select/views/level_select_view.dart';
import 'package:queens/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Tactile 3D Crown Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.headingDark,
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.headingDark,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const CrownWidget(
                  color: Color(0xFFE9C46A), // Designer crown gold
                  size: 56,
                ),
              ),
              const SizedBox(height: 28),

              // Game Title
              const Text(
                'QUEENS',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 62,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'A CROWN PLACEMENT LOGIC PUZZLE',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(flex: 2),

              // Single line Level Panel (3D Pill style)
              if (state.progress != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC6FF), // Pastel Pink
                    borderRadius: BorderRadius.circular(30),
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
                  child: Text(
                    'Level ${state.progress!.currentLevel}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ] else ...[
                const Spacer(flex: 5),
              ],

              // Play Button (Primary CTA)
              TangibleButton(
                text: state.progress == null || state.progress!.currentLevel <= 1 ? 'Start Game' : 'Continue',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(levelNumber: state.progress?.currentLevel ?? 1),
                          ),
                        );
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      },
              ),

              const SizedBox(height: 16),

              // Level Select Button
              TangibleButton(
                text: 'Select Level',
                isSecondary: true,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectView(),
                    ),
                  );
                  ref.read(homeViewModelProvider.notifier).loadProgress();
                },
              ),

              const SizedBox(height: 16),

              // Random Puzzle Button
              TangibleButton(
                text: 'Random Puzzle',
                isSecondary: true,
                onPressed: () => _showDifficultyDialog(context),
              ),

              const SizedBox(height: 16),

              // How to Play Button (Secondary Button)
              TangibleButton(
                text: 'How to Play',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToPlayView(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.headingDark,
              width: 2.5,
            ),
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
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'CHOOSE GRID SIZE',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingDark,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Play a dynamically generated Queens puzzle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtext,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  Widget sizeButton(String label, String diff) {
                    return SizedBox(
                      width: 70,
                      height: 70,
                      child: TangibleButton(
                        text: label,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(
                                levelNumber: 0,
                                isRandom: true,
                                randomDifficulty: diff,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      sizeButton('5x5', 'Easy'),
                      sizeButton('6x6', 'Medium'),
                      sizeButton('7x7', 'Hard'),
                      sizeButton('8x8', 'Super Hard'),
                      sizeButton('9x9', 'Super Duper Hard'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
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
