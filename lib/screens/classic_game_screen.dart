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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final GameController _game;
  late final DateTime _sessionCalendarDay;
  Timer? _roundTimer;
  bool _paused = false;
  bool _navigatedToGameOver = false;
  int _comboAnimKey = 0;
  int? _floatingPoints;
  bool _wasTimeWarn = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final AnimationController _timerWarnPulse;

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
    _timerWarnPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
    final warn = _game.remainingSeconds <= 10 &&
        _game.remainingSeconds > 0 &&
        !_game.isRoundEnded;
    if (warn != _wasTimeWarn) {
      _wasTimeWarn = warn;
      if (warn) {
        unawaited(_timerWarnPulse.repeat(reverse: true));
      } else {
        _timerWarnPulse
          ..stop()
          ..reset();
      }
    }
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
    _timerWarnPulse.dispose();
    super.dispose();
  }

  Future<void> _showPauseModal() async {
    _cancelRoundTimer();
    setState(() => _paused = true);

    if (!mounted) return;
    final choice = await showDialog<_PauseChoice>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
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
                          fontSize: 22,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Current score · ${_game.score}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Time left · ${_formatTime(_game.remainingSeconds)}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_PauseChoice.home),
                        child: Text(
                          'Home',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
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
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.sm,
                AppSpacing.screenPaddingH,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _timerWarnPulse,
                          builder: (context, child) {
                            final scale = timeWarn
                                ? 1.0 + 0.04 * _timerWarnPulse.value
                                : 1.0;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: _HudPill(
                            icon: Icons.schedule_rounded,
                            label: 'TIME',
                            value: _formatTime(rem),
                            valueColor: timeWarn
                                ? AppColors.timerUrgent
                                : AppColors.accentCyan,
                            emphasize: timeWarn,
                            compact: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HudPill(
                          icon: Icons.stars_rounded,
                          label: 'SCORE',
                          value: '${_game.score}',
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TargetCard(
                    target: _game.target,
                    glowSuccess: _floatingPoints != null || matchReady,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CurrentSumPanel(sum: _game.currentSum, target: _game.target),
                  const SizedBox(height: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: roundProgress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      color: timeWarn
                          ? AppColors.timerUrgent
                          : AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                  child: Align(
                    alignment: const Alignment(0, 0.1),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(_comboAnimKey),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        return Opacity(
                          opacity: (t < 0.3
                                  ? t / 0.3
                                  : t > 0.7
                                  ? (1.0 - (t - 0.7) / 0.3)
                                  : 1.0)
                              .clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1 - t) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: AppColors.accentAmber,
                            size: 22,
                            shadows: [
                              Shadow(
                                color: AppColors.accentAmber.withValues(
                                  alpha: 0.7,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          Text(
                            '+${_floatingPoints!}',
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.accentCyan,
                              fontSize: 32,
                              shadows: [
                                Shadow(
                                  color: AppColors.accentCyan.withValues(
                                    alpha: 0.65,
                                  ),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.bolt_rounded,
                            color: AppColors.accentAmber,
                            size: 22,
                            shadows: [
                              Shadow(
                                color: AppColors.accentAmber.withValues(
                                  alpha: 0.7,
                                ),
                                blurRadius: 8,
                              ),
                            ],
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
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final urgent = emphasize;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm + 2 : AppSpacing.md,
        vertical: compact ? 6 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: urgent
            ? AppColors.timerUrgent.withValues(alpha: 0.12)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: urgent
              ? AppColors.timerUrgent.withValues(alpha: 0.7)
              : AppColors.outline.withValues(alpha: 0.4),
          width: urgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: compact ? 18 : 20,
              color: urgent ? AppColors.timerUrgent : AppColors.accentCyan,
            ),
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
                    fontSize: compact ? 15 : 17,
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
    final comboStyle = AppTextStyles.caption.copyWith(
      color: AppColors.background,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.35,
      fontSize: 12,
    );
    final child = comboAnimKey == 0
        ? Text('COMBO x$combo', style: comboStyle)
        : TweenAnimationBuilder<double>(
            key: ValueKey(comboAnimKey),
            tween: Tween(begin: 1.12, end: 1.0),
            duration: const Duration(milliseconds: 340),
            curve: Curves.elasticOut,
            builder: (context, scale, c) {
              return Transform.scale(scale: scale, child: c);
            },
            child: Text('COMBO x$combo', style: comboStyle),
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentCyan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withValues(
              alpha: glowSuccess ? 0.55 : 0.38,
            ),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: glowSuccess
              ? AppColors.tileSuccessFill
              : AppColors.accentCyanDim,
          width: glowSuccess ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (glowSuccess ? AppColors.tileSuccessFill : AppColors.accentCyan)
                .withValues(alpha: glowSuccess ? 0.5 : 0.14),
            blurRadius: glowSuccess ? 26 : 12,
            spreadRadius: glowSuccess ? 2 : 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lightning bolt accent
          Icon(
            Icons.bolt_rounded,
            size: 22,
            color: glowSuccess
                ? AppColors.tileSuccessFill
                : AppColors.accentCyan,
          ),
          const SizedBox(width: AppSpacing.xs),
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
                const SizedBox(height: 2),
                Text(
                  glowSuccess ? 'ZAP! Keep going' : 'Tap tiles that add up',
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '$target',
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: (glowSuccess ? AppColors.tileSuccessFill : AppColors.accentCyan)
                      .withValues(alpha: 0.55),
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
    final almostThere =
        !over && !match && target > 0 && sum > 0 && (target - sum) <= 2;

    final Color accent;
    if (over) {
      accent = AppColors.warningOrange;
    } else if (match) {
      accent = AppColors.accentCyan;
    } else if (almostThere) {
      accent = AppColors.accentCyan.withValues(alpha: 0.85);
    } else {
      accent = AppColors.onSurfaceMuted;
    }

    final progress = target > 0 ? (sum / target).clamp(0.0, 1.0) : 0.0;

    final barColor =
        over ? AppColors.error.withValues(alpha: 0.9) : AppColors.accentCyan;
    final borderColor = over
        ? AppColors.error.withValues(alpha: 0.65)
        : (almostThere || match)
            ? AppColors.accentCyan.withValues(alpha: 0.5)
            : AppColors.outline.withValues(alpha: 0.35);

    final String helper;
    if (over) {
      helper = 'Too high — tap off or Clear';
    } else if (match) {
      helper = 'Tap to score';
    } else if (almostThere) {
      helper = 'Almost there!';
    } else {
      helper = 'Keep tapping';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: borderColor,
          width: (over || almostThere || match) ? 2 : 1,
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
                    helper,
                    style: AppTextStyles.caption.copyWith(
                      color: accent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.display.copyWith(
                  fontSize: 30,
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
                child: Text('$sum'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: over ? 1.0 : progress,
              minHeight: 5,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
