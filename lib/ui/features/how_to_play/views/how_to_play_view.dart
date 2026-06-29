import 'package:flutter/material.dart';
import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        'HOW TO PLAY',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // Balancer for leading back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 28, 24), // extra right/bottom padding for neobrutalism shadow
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _step(
                      context,
                      1,
                      'Rows & Columns',
                      'There must be exactly one queen in each row and exactly one queen in each column.',
                      Icons.grid_on_rounded,
                      const Color(0xFFF28482), // Coral Rose
                    ),
                    const SizedBox(height: 20),
                    _step(
                      context,
                      2,
                      'Color Regions',
                      'Each colored region must contain exactly one queen.',
                      Icons.palette_rounded,
                      const Color(0xFFF3C68F), // Warm Honey
                    ),
                    const SizedBox(height: 20),
                    _step(
                      context,
                      3,
                      'No Touching',
                      'Queens cannot touch each other, even diagonally. Keep at least one cell of space between all queens.',
                      Icons.space_bar_rounded,
                      const Color(0xFFCAFFBF), // Pastel Green
                    ),
                    const SizedBox(height: 20),
                    _step(
                      context,
                      4,
                      'Tap to Mark',
                      'Tap a cell to cycle: [ Empty ➔ X ➔ Queen ♕ ]. Use X to mark cells where queens cannot go.',
                      Icons.touch_app_rounded,
                      const Color(0xFFB5E2FA), // Pastel Blue
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Got It button at the bottom (Primary CTA)
            Padding(
              padding: const EdgeInsets.all(24),
              child: TangibleButton(
                text: 'Got It!',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(BuildContext context, int num, String title, String desc, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.headingDark,
                width: 2.0,
              ),
            ),
            child: Center(child: Icon(icon, color: AppColors.headingDark, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RULE $num',
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.subtext,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtext,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
