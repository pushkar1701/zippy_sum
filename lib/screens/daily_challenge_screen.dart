import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../game/daily_seed.dart';
import '../models/game_mode.dart';
import '../models/player_stats.dart';
import '../services/local_storage_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/zippy_header.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMMd();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'DAILY CHALLENGE',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<PlayerStats>(
              future: LocalStorageService.instance.loadStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? PlayerStats.empty();
                final scoreFmt = NumberFormat.decimalPattern();
                final today = DateTime.now();
                final todayKey = DailySeed.dateKey(today);
                final todayBest = stats.lastDailyDateString == todayKey
                    ? stats.todayDailyBestScore
                    : 0;

                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ZippyHeader(
                        title: "Today's puzzle",
                        subtitle: 'One seeded board per calendar day.',
                        showAccentLine: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        dateFmt.format(today),
                        style: AppTextStyles.title,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Current streak',
                              value: stats.dailyStreak == 0
                                  ? '—'
                                  : (stats.dailyStreak == 1
                                        ? '1 day'
                                        : '${stats.dailyStreak} days'),
                              compact: true,
                              accentTitle: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: StatCard(
                              title: "Today's best",
                              value: scoreFmt.format(todayBest),
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StatCard(
                        title: 'Best daily score',
                        value: scoreFmt.format(stats.bestDailyScore),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'RECENT PUZZLES',
                        style: AppTextStyles.hudLabel.copyWith(
                          color: AppColors.accentCyan,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Today (${DailySeed.dateKey(today)}): '
                          'best ${scoreFmt.format(todayBest)}. '
                          'Full history stays on device only.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'START DAILY',
                        trailingIcon: Icons.play_arrow_rounded,
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.classicGame,
                            arguments: GameMode.daily,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SecondaryButton(
                        label: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
