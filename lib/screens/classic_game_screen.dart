import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../game/game_controller.dart';
import '../models/game_result.dart';
import '../services/local_storage_service.dart';
import '../widgets/number_tile.dart';

enum _PauseChoice { resume, restart, home }

/// Classic timed round driven by [GameController] (no submit — sum = target to solve).
class ClassicGameScreen extends StatefulWidget {
  const ClassicGameScreen({super.key});

  @override
  State<ClassicGameScreen> createState() => _ClassicGameScreenState();
}

class _ClassicGameScreenState extends State<ClassicGameScreen> {
  late final GameController _game;
  Timer? _roundTimer;
  bool _paused = false;
  bool _navigatedToGameOver = false;

  @override
  void initState() {
    super.initState();
    _game = GameController(onChanged: _onGameChanged);
    _game.resetSession();
    _startRoundTimer();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
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

    final recorded =
        await LocalStorageService.instance.recordClassicResult(raw);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      AppRouter.gameOver,
      arguments: recorded.result,
    );
  }

  @override
  void dispose() {
    _cancelRoundTimer();
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
      // Resume, or dismissed barrier — continue the round.
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classic'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HudRow(
                label1: 'Time',
                value1: _formatTime(_game.remainingSeconds),
                label2: 'Score',
                value2: '${_game.score}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _HudRow(
                label1: 'Combo',
                value1: 'x${_game.combo}',
                label2: 'Solved',
                value2: '${_game.solvedCount}',
              ),
              const SizedBox(height: AppSpacing.md),
              _TargetCard(target: _game.target),
              const SizedBox(height: AppSpacing.md),
              _CurrentSumPanel(sum: _game.currentSum, target: _game.target),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1,
                  ),
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    return NumberTile(
                      tile: models[index],
                      onTap: interactive
                          ? () => _game.toggleTile(index)
                          : null,
                    );
                  },
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
      ),
    );
  }
}

/// Prominent target — purple frame, cyan number.
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

/// Large current sum for at-a-glance feedback.
class _CurrentSumPanel extends StatelessWidget {
  const _CurrentSumPanel({
    required this.sum,
    required this.target,
  });

  final int sum;
  final int target;

  @override
  Widget build(BuildContext context) {
    final over = sum > target;
    final match = sum == target && target > 0;

    final Color accent;
    if (over) {
      accent = AppColors.error;
    } else if (match) {
      accent = AppColors.accentCyan;
    } else {
      accent = AppColors.onSurfaceMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.35),
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
                over ? 'Over target' : (match ? 'Match!' : 'Keep tapping'),
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
  });

  final String label1;
  final String value1;
  final String label2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _HudCell(label: label1, value: value1)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _HudCell(label: label2, value: value2)),
      ],
    );
  }
}

class _HudCell extends StatelessWidget {
  const _HudCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.hudLabel),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.hudValue),
        ],
      ),
    );
  }
}
