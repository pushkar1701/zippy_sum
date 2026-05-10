import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/daily_complete_args.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../models/player_stats.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class DailyCompleteScreen extends StatelessWidget {
  const DailyCompleteScreen({super.key, required this.args});

  final DailyCompleteArgs args;

  factory DailyCompleteScreen.fallback() {
    return DailyCompleteScreen(
      args: DailyCompleteArgs(
        result: GameResult.placeholder(),
        stats: PlayerStats.empty(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreFmt = NumberFormat.decimalPattern();
    final r = args.result;
    final s = args.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 72,
                color: AppColors.accentCyan,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Daily complete',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatRow(
                label: "Today's score",
                value: scoreFmt.format(r.score),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: "Today's best",
                value: scoreFmt.format(s.todayDailyBestScore),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Best daily score',
                value: scoreFmt.format(s.bestDailyScore),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Daily streak',
                value: s.dailyStreak == 1 ? '1 day' : '${s.dailyStreak} days',
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Try again',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRouter.classicGame,
                    arguments: GameMode.daily,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Play Classic',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRouter.classicGame,
                    arguments: GameMode.classic,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.home,
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
