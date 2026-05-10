import 'dart:async';
import 'dart:math' show Random, min;
import 'dart:ui' show ImageFilter;

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
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

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
      if (mounted && !_paused && !_navigatedToGameOver && !_game.isRoundEnded) {
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
      final recorded = await LocalStorageService.instance.recordClassicResult(
        raw,
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRouter.gameOver, arguments: recorded.result);
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
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PAUSED',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 26,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'CURRENT SCORE: ${_game.score}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'TIME LEFT: ${_formatTime(_game.remainingSeconds)}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'RESUME',
                      trailingIcon: Icons.play_arrow_rounded,
                      onPressed: () =>
                          Navigator.of(context).pop(_PauseChoice.resume),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: 'RESTART',
                      onPressed: () =>
                          Navigator.of(context).pop(_PauseChoice.restart),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PauseChoice.home),
                      child: Text(
                        'HOME',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
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
    final interactive = !ended && !_paused && !_navigatedToGameOver;
    final rem = _game.remainingSeconds;
    final timeWarn = rem > 0 && rem <= 10;
    final mistake = _game.mistakeActive;
    final matchReady =
        interactive &&
        !mistake &&
        _game.target > 0 &&
        _game.currentSum == _game.target &&
        _game.currentSum > 0;
    final roundProgress = _game.config.classicDurationSeconds > 0
        ? rem / _game.config.classicDurationSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.mode == GameMode.daily ? 'Daily' : 'ZippySum',
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.settings),
          ),
        ],
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
                  Row(
                    children: [
                      Expanded(
                        child: _HudPill(
                          icon: Icons.schedule_rounded,
                          label: 'TIME',
                          value: _formatTime(rem),
                          valueColor: timeWarn
                              ? AppColors.error
                              : AppColors.accentCyan,
                          emphasize: timeWarn,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HudPill(
                          icon: Icons.stars_rounded,
                          label: 'SCORE',
                          value: '${_game.score}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ComboPill(
                          combo: _game.combo,
                          comboAnimKey: _comboAnimKey,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HudPill(
                          label: 'SOLVED',
                          value: '${_game.solvedCount}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TargetCard(
                    target: _game.target,
                    glowSuccess: _floatingPoints != null || matchReady,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CurrentSumPanel(sum: _game.currentSum, target: _game.target),
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
                                  final t = models[index];
                                  return NumberTile(
                                    tile: t,
                                    showMatchCheck: matchReady && t.isSelected,
                                    onTap: interactive
                                        ? () {
                                            unawaited(
                                              HapticsService.instance.tileTap(),
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
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: roundProgress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Fixed height keeps [Expanded] grid size stable; mistake used to
                  // inject a callout above the grid and shrink tiles (bad UX).
                  SizedBox(
                    height: 52,
                    child: mistake && interactive
                        ? PrimaryButton(
                            label: 'CLEAR SELECTION',
                            trailingIcon: Icons.refresh_rounded,
                            onPressed: () => _game.clearSelection(),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: interactive
                                      ? _game.clearSelection
                                      : null,
                                  icon: const Icon(
                                    Icons.clear_all_rounded,
                                    size: 20,
                                  ),
                                  label: const Text('CLEAR'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: (ended || _navigatedToGameOver)
                                      ? null
                                      : _showPauseModal,
                                  child: const Text('PAUSE'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            if (_floatingPoints != null)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: const Alignment(0, -0.08),
                    child: Text(
                      '+${_floatingPoints!}',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 36,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
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

class _HudPill extends StatelessWidget {
  const _HudPill({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: emphasize
            ? AppColors.error.withValues(alpha: 0.12)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: emphasize
              ? AppColors.error.withValues(alpha: 0.65)
              : AppColors.outline.withValues(alpha: 0.4),
          width: emphasize ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.accentCyan),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.hudLabel),
                Text(
                  value,
                  style: AppTextStyles.hudValue.copyWith(
                    color: valueColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
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

class _ComboPill extends StatelessWidget {
  const _ComboPill({required this.combo, required this.comboAnimKey});

  final int combo;
  final int comboAnimKey;

  @override
  Widget build(BuildContext context) {
    final child = comboAnimKey == 0
        ? Text(
            'COMBO x$combo',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.tileNumber,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          )
        : TweenAnimationBuilder<double>(
            key: ValueKey(comboAnimKey),
            tween: Tween(begin: 1.12, end: 1.0),
            duration: const Duration(milliseconds: 340),
            curve: Curves.elasticOut,
            builder: (context, scale, c) {
              return Transform.scale(scale: scale, child: c);
            },
            child: Text(
              'COMBO x$combo',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.tileNumber,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentCyan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.target, this.glowSuccess = false});

  final int target;
  final bool glowSuccess;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.38),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.accentCyanDim, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(
              alpha: glowSuccess ? 0.45 : 0.15,
            ),
            blurRadius: glowSuccess ? 28 : 16,
            spreadRadius: glowSuccess ? 2 : 0,
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
                Text('Tap tiles that add up', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '$target',
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentSumPanel extends StatelessWidget {
  const _CurrentSumPanel({required this.sum, required this.target});

  final int sum;
  final int target;

  @override
  Widget build(BuildContext context) {
    final over = sum > target;
    final match = sum == target && target > 0;

    final Color accent;
    if (over) {
      accent = AppColors.warningOrange;
    } else if (match) {
      accent = AppColors.accentCyan;
    } else {
      accent = AppColors.onSurfaceMuted;
    }

    final progress = target > 0 ? (sum / target).clamp(0.0, 1.0) : 0.0;

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
              ? AppColors.warningOrange.withValues(alpha: 0.65)
              : AppColors.outline.withValues(alpha: 0.35),
          width: over ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT SUM', style: AppTextStyles.hudLabel),
                  const SizedBox(height: 2),
                  Text(
                    over
                        ? 'Too high — tap off or Clear'
                        : (match ? 'Nice!' : 'Keep tapping'),
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
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: over ? 1.0 : progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: over ? AppColors.warningOrange : AppColors.accentCyan,
            ),
          ),
        ],
      ),
    );
  }
}
