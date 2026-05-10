import 'dart:async';
import 'dart:math' show Random, min;

import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../game/daily_seed.dart';
import '../game/game_controller.dart';
import '../models/daily_complete_args.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../services/haptics_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/number_tile.dart';

enum _PauseChoice { resume, restart, home }

/// Timed round: [GameMode.classic] or deterministic [GameMode.daily].
class ClassicGameScreen extends StatefulWidget {
  const ClassicGameScreen({super.key, this.mode = GameMode.classic});

  final GameMode mode;

  @override
  State<ClassicGameScreen> createState() => _ClassicGameScreenState();
}

class _ClassicGameScreenState extends State<ClassicGameScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final GameController _game;
  late final DateTime _sessionCalendarDay;
  Timer? _roundTimer;
  bool _paused = false;
  bool _navigatedToGameOver = false;
  int _comboAnimKey = 0;
  int? _floatingPoints;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    final n = DateTime.now();
    _sessionCalendarDay = DateTime(n.year, n.month, n.day);
    _game = GameController(
      onChanged: _onGameChanged,
      onCorrect: _onCorrectSolve,
      onMistake: _onMistake,
      random: widget.mode == GameMode.daily
          ? DailySeed.randomForDate(_sessionCalendarDay)
          : Random(),
    );
    _game.resetSession();
    _startRoundTimer();
  }

  void _onCorrectSolve(int pointsEarned) {
    unawaited(HapticsService.instance.correct());
    setState(() {
      _comboAnimKey++;
      _floatingPoints = pointsEarned;
    });
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _floatingPoints = null);
    });
    _pulseController.forward(from: 0).then((_) {
      if (mounted) _pulseController.reverse();
    });
  }

  void _onMistake() {
    unawaited(HapticsService.instance.mistake());
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cancelRoundTimer();
    } else if (state == AppLifecycleState.resumed) {
      if (mounted &&
          !_paused &&
          !_navigatedToGameOver &&
          !_game.isRoundEnded) {
        _startRoundTimer();
      }
    }
  }

  void _cancelRoundTimer() {
    _roundTimer?.cancel();
    _roundTimer = null;
  }

  void _startRoundTimer() {
    _cancelRoundTimer();
    if (!mounted || _paused || _navigatedToGameOver || _game.isRoundEnded) {
      return;
    }
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused || _navigatedToGameOver) return;
      _game.tick(1000);
      if (_game.isRoundEnded) {
        _finishRoundAndNavigate();
      }
    });
  }

  Future<void> _finishRoundAndNavigate() async {
    if (_navigatedToGameOver || !mounted) return;
    _navigatedToGameOver = true;
    _cancelRoundTimer();

    final raw = GameResult(
      score: _game.score,
      targetsSolved: _game.solvedCount,
      mistakes: _game.mistakeCount,
      bestCombo: _game.bestCombo,
      accuracy: GameResult.computeAccuracy(
        targetsSolved: _game.solvedCount,
        mistakes: _game.mistakeCount,
      ),
      durationSeconds: _game.config.classicDurationSeconds,
      playedAt: DateTime.now(),
    );

    if (widget.mode == GameMode.daily) {
      final recorded = await LocalStorageService.instance.recordDailyResult(
        raw,
        _sessionCalendarDay,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRouter.dailyComplete,
        arguments: DailyCompleteArgs(
          result: recorded.result,
          stats: recorded.stats,
        ),
      );
    } else {
      final recorded =
          await LocalStorageService.instance.recordClassicResult(raw);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRouter.gameOver,
        arguments: recorded.result,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelRoundTimer();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _showPauseModal() async {
    _cancelRoundTimer();
    setState(() => _paused = true);

    if (!mounted) return;
    final choice = await showDialog<_PauseChoice>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          title: Text('Paused', style: AppTextStyles.headline),
          content: Text(
            'Timer is paused. What would you like to do?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_PauseChoice.resume),
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_PauseChoice.restart),
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_PauseChoice.home),
              child: Text(
                'Home',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (choice == _PauseChoice.restart) {
      setState(() {
        _paused = false;
        _navigatedToGameOver = false;
        _comboAnimKey = 0;
        _floatingPoints = null;
        _game.resetSession();
      });
      _startRoundTimer();
    } else if (choice == _PauseChoice.home) {
      setState(() => _paused = false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (_) => false,
      );
    } else {
      setState(() => _paused = false);
      if (!_game.isRoundEnded) _startRoundTimer();
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final models = _game.tileModels();
    final ended = _game.isRoundEnded;
    final interactive =
        !ended && !_paused && !_navigatedToGameOver;
    final rem = _game.remainingSeconds;
    final timeWarn = rem > 0 && rem <= 10;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.mode == GameMode.daily ? 'Daily' : 'Classic'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HudRow(
                    label1: 'Time',
                    value1: _formatTime(rem),
                    value1Color:
                        timeWarn ? scheme.error : null,
                    label2: 'Score',
                    value2: '${_game.score}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _HudRow(
                    label1: 'Combo',
                    value1: 'x${_game.combo}',
                    value1Widget: _comboAnimKey == 0
                        ? Text(
                            'x${_game.combo}',
                            style: AppTextStyles.hudValue,
                          )
                        : TweenAnimationBuilder<double>(
                            key: ValueKey(_comboAnimKey),
                            tween: Tween(begin: 1.18, end: 1.0),
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                alignment: Alignment.centerLeft,
                                child: child,
                              );
                            },
                            child: Text(
                              'x${_game.combo}',
                              style: AppTextStyles.hudValue,
                            ),
                          ),
                    label2: 'Solved',
                    value2: '${_game.solvedCount}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TargetCard(target: _game.target),
                  const SizedBox(height: AppSpacing.md),
                  _CurrentSumPanel(
                    sum: _game.currentSum,
                    target: _game.target,
                    tooHighColor: scheme.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: ScaleTransition(
                      scale: _pulseScale,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = AppSpacing.sm;
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;
                          final cellW = (maxW - 3 * spacing) / 4;
                          final cellH = (maxH - 3 * spacing) / 4;
                          final cell = min(cellW, cellH);
                          final extent = 4 * cell + 3 * spacing;
                          return Center(
                            child: SizedBox(
                              width: extent,
                              height: extent,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: spacing,
                                  crossAxisSpacing: spacing,
                                  childAspectRatio: 1,
                                ),
                                itemCount: models.length,
                                itemBuilder: (context, index) {
                                  return NumberTile(
                                    tile: models[index],
                                    onTap: interactive
                                        ? () {
                                            unawaited(
                                              HapticsService.instance
                                                  .tileTap(),
                                            );
                                            _game.toggleTile(index);
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              interactive ? _game.clearSelection : null,
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: (ended || _navigatedToGameOver)
                              ? null
                              : _showPauseModal,
                          child: const Text('Pause'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_floatingPoints != null)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: const Alignment(0, -0.05),
                    child: Text(
                      '+${_floatingPoints!}',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 32,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.target});

  final int target;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.35),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: AppColors.accentCyanDim,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARGET',
                  style: AppTextStyles.hudLabel.copyWith(
                    color: AppColors.accentCyan,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap tiles that add up',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '$target',
            style: AppTextStyles.display.copyWith(
              color: AppColors.accentCyan,
              fontSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentSumPanel extends StatelessWidget {
  const _CurrentSumPanel({
    required this.sum,
    required this.target,
    required this.tooHighColor,
  });

  final int sum;
  final int target;
  final Color tooHighColor;

  @override
  Widget build(BuildContext context) {
    final over = sum > target;
    final match = sum == target && target > 0;

    final Color accent;
    if (over) {
      accent = tooHighColor;
    } else if (match) {
      accent = AppColors.accentCyan;
    } else {
      accent = AppColors.onSurfaceMuted;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: over
              ? tooHighColor.withValues(alpha: 0.65)
              : AppColors.outline.withValues(alpha: 0.35),
          width: over ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT SUM',
                style: AppTextStyles.hudLabel,
              ),
              const SizedBox(height: 2),
              Text(
                over ? 'Too high — tap off or Clear' : (match ? 'Nice!' : 'Keep tapping'),
                style: AppTextStyles.caption.copyWith(color: accent),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$sum',
            style: AppTextStyles.display.copyWith(
              fontSize: 36,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  const _HudRow({
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    this.value1Color,
    this.value1Widget,
  });

  final String label1;
  final String value1;
  final String label2;
  final String value2;
  final Color? value1Color;
  final Widget? value1Widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HudCell(
            label: label1,
            value: value1,
            valueColor: value1Color,
            valueWidget: value1Widget,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _HudCell(label: label2, value: value2)),
      ],
    );
  }
}

class _HudCell extends StatelessWidget {
  const _HudCell({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: valueColor != null
              ? valueColor!.withValues(alpha: 0.55)
              : AppColors.outline.withValues(alpha: 0.4),
          width: valueColor != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.hudLabel),
          const SizedBox(height: 2),
          valueWidget ??
              Text(
                value,
                style: AppTextStyles.hudValue.copyWith(
                  color: valueColor,
                ),
              ),
        ],
      ),
    );
  }
}
