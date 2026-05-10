import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../game/game_controller.dart';
import '../widgets/number_tile.dart';

/// Classic timed round driven by [GameController] (no submit — sum = target to solve).
class ClassicGameScreen extends StatefulWidget {
  const ClassicGameScreen({super.key});

  @override
  State<ClassicGameScreen> createState() => _ClassicGameScreenState();
}

class _ClassicGameScreenState extends State<ClassicGameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _game;
  late final Ticker _ticker;
  Duration? _prevElapsed;

  @override
  void initState() {
    super.initState();
    _game = GameController(onChanged: _onGameChanged);
    _game.resetSession();

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final prev = _prevElapsed;
    _prevElapsed = elapsed;
    if (prev == null) return;
    final ms = (elapsed - prev).inMilliseconds;
    if (ms <= 0) return;
    _game.tick(ms);
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _pause() async {
    _ticker.stop();
    _prevElapsed = null;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          title: Text('Paused', style: AppTextStyles.headline),
          content: Text(
            'Gameplay pauses here. More options later.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Quit',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (mounted) {
      _prevElapsed = null;
      _ticker.start();
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
              if (ended) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Time\'s up — board locked.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
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
                      onTap: () => _game.toggleTile(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: ended ? null : _game.clearSelection,
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _pause,
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
