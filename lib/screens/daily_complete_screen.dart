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
import '../services/haptics_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class DailyCompleteScreen extends StatefulWidget {
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
  State<DailyCompleteScreen> createState() => _DailyCompleteScreenState();
}

class _DailyCompleteScreenState extends State<DailyCompleteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticsService.instance.gameOver();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoreFmt = NumberFormat.decimalPattern();
    final r = widget.args.result;
    final s = widget.args.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'DAILY COMPLETE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      scoreFmt.format(r.score),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StatRow(
                      label: "Today's score",
                      value: scoreFmt.format(r.score),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatRow(
                      label: 'Daily streak',
                      value: s.dailyStreak == 1
                          ? '1 day'
                          : '${s.dailyStreak} days',
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
                    const Spacer(),
                    PrimaryButton(
                      label: 'PLAY CLASSIC',
                      trailingIcon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRouter.classicGame,
                          arguments: GameMode.classic,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'MY STATS',
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.stats);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SecondaryButton(
                            label: 'TRY AGAIN',
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                AppRouter.classicGame,
                                arguments: GameMode.daily,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
                      },
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
            const AdBanner(),
          ],
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
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
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
