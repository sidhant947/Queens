import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:queens/ui/core/theme/app_colors.dart';
import 'package:queens/ui/core/widgets/tangible_button.dart';
import 'package:queens/ui/core/widgets/crown_widget.dart';
import 'package:queens/ui/features/game/view_models/game_view_model.dart';
import 'package:queens/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty = 'Easy',
  });

  final int levelNumber;
  final bool isRandom;
  final String randomDifficulty;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isRandom) {
        ref.read(gameViewModelProvider.notifier).loadRandomLevel(widget.randomDifficulty);
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        _showCompleteDialog();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    state.isRandomMode
                        ? '${state.level?.gridSize ?? state.randomGridSize ?? 5}x${state.level?.gridSize ?? state.randomGridSize ?? 5}'
                        : 'LEVEL ${widget.levelNumber}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(gameViewModelProvider.notifier).resetLevel(),
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
                        Icons.refresh_rounded,
                        size: 20,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game body
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(gameViewModelProvider.notifier)
                                    .resetLevel(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildGame(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(GameViewModelState state) {
    final level = state.level;
    if (level == null) return const SizedBox.shrink();

    // Count currently placed queens
    int queenCount = 0;
    for (int r = 0; r < level.gridSize; r++) {
      for (int c = 0; c < level.gridSize; c++) {
        if (state.board[r][c] == CellState.queen) {
          queenCount++;
        }
      }
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('MOVES', '${state.moveCount}', Icons.trending_up_rounded),
              _verticalDivider(),
              _stat('GRID', '${level.gridSize}x${level.gridSize}', Icons.grid_on_rounded),
              _verticalDivider(),
              _stat('QUEENS', '$queenCount/${level.gridSize}', Icons.star_rounded),
            ],
          ),
        ),

        // Grid Container
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final N = level.gridSize;

                      return Column(
                        children: List.generate(N, (r) {
                          return Expanded(
                            child: Row(
                              children: List.generate(N, (c) {
                                final cellState = state.board[r][c];
                                final hasConflict = state.conflicts[r][c];
                                final regionIndex = level.colorRegions[r][c];
                                final regionColor = level.regionColors[regionIndex];

                                // Uniform borders between all cells (no region boundary highlights)
                                final borderSide = BorderSide(
                                  color: AppColors.headingDark.withOpacity(0.15),
                                  width: 1.0,
                                );

                                // Check if cell is blocked (auto-X)
                                final blocked = _isCellBlocked(r, c, state.board, level);

                                return Expanded(
                                  child: QueensCell(
                                    cellState: cellState,
                                    hasConflict: hasConflict,
                                    isAutoBlocked: blocked,
                                    regionColor: regionColor,
                                    border: Border(
                                      top: r == 0 ? BorderSide.none : borderSide,
                                      bottom: r == N - 1 ? BorderSide.none : borderSide,
                                      left: c == 0 ? BorderSide.none : borderSide,
                                      right: c == N - 1 ? BorderSide.none : borderSide,
                                    ),
                                    onTap: () {
                                      ref.read(gameViewModelProvider.notifier).toggleCell(r, c);
                                    },
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Help tip text
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'TAP: CYCLE [ EMPTY ➔ X ➔ QUEEN ♕ ]',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.subtext,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  bool _isCellBlocked(int r, int c, List<List<CellState>> board, level) {
    if (board[r][c] != CellState.empty) return false;
    final N = level.gridSize;
    final myRegion = level.colorRegions[r][c];

    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        if (board[i][j] == CellState.queen) {
          // Same row
          if (i == r) return true;
          // Same col
          if (j == c) return true;
          // Same color region
          if (level.colorRegions[i][j] == myRegion) return true;
          // 8-way adjacent
          if ((i - r).abs() <= 1 && (j - c).abs() <= 1) return true;
        }
      }
    }
    return false;
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.headingDark,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.subtext,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.0,
      height: 30,
      color: AppColors.gridLines,
    );
  }

  void _showCompleteDialog() {
    final state = ref.read(gameViewModelProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6A5), // Gold crown background pastel
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.headingDark,
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.headingDark,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'LEVEL COMPLETE!',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingDark,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  state.isRandomMode
                      ? 'You solved this ${state.level?.gridSize}x${state.level?.gridSize} puzzle in ${state.moveCount} moves.'
                      : 'You solved Level ${widget.levelNumber} in ${state.moveCount} moves.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtext,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Column(
                children: [
                  TangibleButton(
                    text: state.isRandomMode ? 'Play Again' : 'Next Level',
                    height: 50,
                    onPressed: () async {
                      final notifier = ref.read(gameViewModelProvider.notifier);
                      await notifier.completeLevel();
                      if (!mounted) return;
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (state.isRandomMode) {
                          notifier.loadRandomLevel(state.randomDifficulty ?? 'Easy');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(levelNumber: widget.levelNumber + 1),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TangibleButton(
                    text: 'Home',
                    isSecondary: true,
                    height: 50,
                    onPressed: () async {
                      final notifier = ref.read(gameViewModelProvider.notifier);
                      await notifier.completeLevel();
                      if (!mounted) return;
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QueensCell extends ConsumerStatefulWidget {
  const QueensCell({
    super.key,
    required this.cellState,
    required this.hasConflict,
    required this.isAutoBlocked,
    required this.regionColor,
    required this.border,
    required this.onTap,
  });

  final CellState cellState;
  final bool hasConflict;
  final bool isAutoBlocked;
  final Color regionColor;
  final BoxBorder border;
  final VoidCallback onTap;

  @override
  ConsumerState<QueensCell> createState() => _QueensCellState();
}

class _QueensCellState extends ConsumerState<QueensCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    if (widget.cellState != CellState.empty) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant QueensCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cellState != widget.cellState) {
      if (widget.cellState != CellState.empty) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.regionColor,
          border: widget.border,
        ),
        alignment: Alignment.center,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    const Color activeIconColor = AppColors.headingDark;

    if (widget.cellState == CellState.queen) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: widget.hasConflict ? 32 : 0,
              height: widget.hasConflict ? 32 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(widget.hasConflict ? 0.35 : 0.0),
                shape: BoxShape.circle,
              ),
            ),
            CrownWidget(
              color: widget.hasConflict ? const Color(0xFFE53935) : activeIconColor,
              size: 24,
            ),
          ],
        ),
      );
    } else if (widget.cellState == CellState.x) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          Icons.close_rounded,
          size: 22,
          color: activeIconColor.withOpacity(0.7),
        ),
      );
    } else if (widget.isAutoBlocked) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: widget.isAutoBlocked ? 1.0 : 0.0,
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: activeIconColor.withOpacity(0.25),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
