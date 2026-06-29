import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/features/game/views/game_view.dart';
import 'package:queens/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    // Display a dynamic grid of levels, keeping a buffer of 20 levels ahead of current progress
    final int totalLevelsToShow = math.max(60, currentLevel + 20);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
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
                        'LEVELS',
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
                  // Balanced invisible spacer to perfectly center the text
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Grid of levels
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 24, 28, 28), // extra right/bottom padding for 3D shadow
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalLevelsToShow,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isCompleted = levelNumber <= highestCompleted;
                  final isCurrent = levelNumber == currentLevel;
                  final isLocked = levelNumber > currentLevel;

                  return _buildLevelCard(
                    context,
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLocked: isLocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    Color cardBg = Colors.white;
    Color borderColor = AppColors.headingDark;
    Widget content;
    bool isClickable = !isLocked;
    Offset shadowOffset = const Offset(3, 3);

    if (isCompleted) {
      cardBg = const Color(0xFFCAFFBF); // Pastel Green for completed
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$levelNumber',
            style: const TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.headingDark,
            ),
          ),
          const SizedBox(height: 2),
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.headingDark,
          ),
        ],
      );
    } else if (isCurrent) {
      cardBg = const Color(0xFFFFC6FF); // Pastel Pink for current level
      shadowOffset = const Offset(4, 4);
      content = Text(
        '$levelNumber',
        style: const TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 26,
          color: AppColors.headingDark,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      // Locked state
      cardBg = const Color(0xFFE2E2E6); // Light Grey
      borderColor = AppColors.headingDark;
      shadowOffset = Offset.zero; // flat/sunken
      content = const Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: AppColors.subtext,
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(levelNumber: levelNumber),
                ),
              );
              // Refresh when returning to update completions
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.5 : 2.0,
          ),
          boxShadow: [
            if (shadowOffset != Offset.zero)
              BoxShadow(
                color: borderColor,
                offset: shadowOffset,
                blurRadius: 0,
              ),
          ],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
