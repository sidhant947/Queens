import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:queens/domain/use_cases/cell_rules.dart';
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
        _onLevelComplete(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        onTap: () => Navigator.pop(context),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _circleButton(
                            icon: Icons.undo_rounded,
                            iconSize: 20,
                            enabled: state.canUndo && !state.isComplete,
                            onTap: () =>
                                ref.read(gameViewModelProvider.notifier).undo(),
                          ),
                          const SizedBox(width: 8),
                          _circleButton(
                            icon: Icons.refresh_rounded,
                            iconSize: 20,
                            onTap: () => ref
                                .read(gameViewModelProvider.notifier)
                                .resetLevel(),
                          ),
                        ],
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
            ConfettiExplosion(trigger: state.isComplete),
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white24,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('MOVES', '${state.moveCount}', Icons.trending_up_rounded),
              _verticalDivider(),
              _stat('TIME', _formatTime(state.elapsedSeconds), Icons.timer_outlined),
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
                child: Container(
                  color: Colors.transparent,
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

                                // Check if cell is blocked (auto-X)
                                final blocked = CellRules.isCellBlocked(
                                    r, c, state.board, level);
                                final isHinted =
                                    state.hintCell == r * N + c;

                                return Expanded(
                                  child: QueensCell(
                                    cellState: cellState,
                                    hasConflict: hasConflict,
                                    isAutoBlocked: blocked,
                                    isHinted: isHinted,
                                    regionColor: regionColor,
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

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
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
          child: Icon(
            icon,
            size: iconSize,
            color: AppColors.headingDark,
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

  Future<void> _onLevelComplete(GameViewModelState state) async {
    // Capture the prior best (before recording) so we can flag a new record,
    // then persist the result immediately so it is saved even if the player
    // exits via Home rather than Next Level.
    bool isNewBest = false;
    if (!state.isRandomMode && state.level != null) {
      final progress = await ref.read(progressRepositoryProvider).getProgress();
      final priorMoves = progress.bestMoves[state.level!.levelNumber];
      final priorTime = progress.bestTimeSeconds[state.level!.levelNumber];
      isNewBest = priorMoves == null ||
          state.moveCount < priorMoves ||
          priorTime == null ||
          state.elapsedSeconds < priorTime;
    }
    await ref.read(gameViewModelProvider.notifier).completeLevel();
    if (!mounted) return;
    _showCompleteDialog(state, isNewBest);
  }

  void _showCompleteDialog(GameViewModelState state, bool isNewBest) {
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
              color: Colors.white24,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface, // Charcoal surface background
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1.0,
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
                      ? 'You solved this ${state.level?.gridSize}x${state.level?.gridSize} puzzle in ${state.moveCount} moves and ${_formatTime(state.elapsedSeconds)}.'
                      : 'You solved Level ${widget.levelNumber} in ${state.moveCount} moves and ${_formatTime(state.elapsedSeconds)}.',
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
              if (isNewBest && !state.isRandomMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white24, width: 1.0),
                  ),
                  child: const Text(
                    '★ NEW BEST!',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      TangibleButton(
                        text: state.isRandomMode ? 'Play Again' : 'Next Level',
                        height: 50,
                        onPressed: () {
                          // Progress was already recorded in _onLevelComplete.
                          final notifier = ref.read(gameViewModelProvider.notifier);
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
                        },
                      ),
                      const SizedBox(height: 14),
                      TangibleButton(
                        text: 'Home',
                        isSecondary: true,
                        height: 50,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 14),
                      TangibleButton(
                        text: 'Buy Me a Coffee',
                        isSecondary: true,
                        height: 50,
                        onPressed: () async {
                          final url = Uri.parse('https://buymeacoffee.com/sidhant947');
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
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

class QueensCell extends ConsumerStatefulWidget {
  const QueensCell({
    super.key,
    required this.cellState,
    required this.hasConflict,
    required this.isAutoBlocked,
    required this.isHinted,
    required this.regionColor,
    required this.onTap,
  });

  final CellState cellState;
  final bool hasConflict;
  final bool isAutoBlocked;
  final bool isHinted;
  final Color regionColor;
  final VoidCallback onTap;

  @override
  ConsumerState<QueensCell> createState() => _QueensCellState();
}

class _QueensCellState extends ConsumerState<QueensCell> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -5.0, end: 3.5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 3.5, end: -3.5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -3.5, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
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
    if (widget.hasConflict && !oldWidget.hasConflict) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0.0),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: widget.regionColor,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hint flash overlay.
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.isHinted
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: widget.isHinted
                        ? Border.all(color: Colors.white24, width: 1.0)
                        : null,
                  ),
                ),
              ),
              _buildContent(),
            ],
          ),
        ),
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
                color: Colors.white.withValues(alpha: widget.hasConflict ? 0.4 : 0.0),
                shape: BoxShape.circle,
              ),
            ),
            CrownWidget(
              color: widget.hasConflict ? Colors.black : activeIconColor,
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
          color: activeIconColor, // Fully opaque white for maximum contrast
        ),
      );
    } else if (widget.isAutoBlocked) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: widget.isAutoBlocked ? 1.0 : 0.0,
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: activeIconColor.withValues(alpha: 0.55), // Increased opacity for helpers
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  bool isCircle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.isCircle,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 300.0 * dt; // gravity
    vx *= math.pow(0.98, dt * 60); // air resistance
    vy *= math.pow(0.98, dt * 60);
    rotation += rotationSpeed * dt;
  }
}

class ConfettiExplosion extends StatefulWidget {
  final bool trigger;
  const ConfettiExplosion({super.key, required this.trigger});

  @override
  State<ConfettiExplosion> createState() => _ConfettiExplosionState();
}

class _ConfettiExplosionState extends State<ConfettiExplosion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_tick);

    if (widget.trigger) {
      _burst();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _burst();
    }
  }

  void _burst() {
    _particles.clear();
    final List<Color> colors = [
      Colors.white,
      Colors.white70,
      Colors.white54,
      Colors.white30,
      const Color(0xFF888888),
      const Color(0xFFCCCCCC),
      const Color(0xFF555555),
      const Color(0xFFAAAAAA),
    ];

    // Spawn 80 particles bursting from center of the screen
    for (int i = 0; i < 80; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double speed = 150 + _random.nextDouble() * 250;
      _particles.add(ConfettiParticle(
        x: 0.5, // Normalized coordinates (0 to 1) for the viewport
        y: 0.4,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 150, // Burst upwards
        size: 6 + _random.nextDouble() * 8,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        color: colors[_random.nextInt(colors.length)],
        isCircle: _random.nextBool(),
      ));
    }
    _controller.forward(from: 0.0);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.update(0.016); // ~60fps step
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: ConfettiPainter(particles: _particles),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double px = p.x * size.width;
      final double py = p.y * size.height;

      // Skip painting if out of screen bounds
      if (px < 0 || px > size.width || py > size.height) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final Paint paint = Paint()..color = p.color;

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
