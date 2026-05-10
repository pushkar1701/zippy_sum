import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/player_stats.dart';
import '../services/local_storage_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'STATS',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<PlayerStats>(
        future: LocalStorageService.instance.loadStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? PlayerStats.empty();
          final avgAcc = stats.averageAccuracy;
          final accLabel = '${(avgAcc * 100).round()}%';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'TOP SCORE',
                style: AppTextStyles.hudLabel.copyWith(
                  color: AppColors.accentCyan,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.45),
                      AppColors.surfaceContainerHigh,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  formatter.format(stats.bestClassicScore),
                  style: AppTextStyles.display.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.4,
                children: [
                  _MiniStat(
                    label: 'TOTAL GAMES',
                    value: formatter.format(stats.totalGamesPlayed),
                  ),
                  _MiniStat(
                    label: 'TARGETS SOLVED',
                    value: formatter.format(stats.totalTargetsSolved),
                  ),
                  _MiniStat(
                    label: 'BEST COMBO',
                    value: stats.bestCombo > 0 ? 'x${stats.bestCombo}' : '—',
                  ),
                  _MiniStat(label: 'AVG ACCURACY', value: accLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Everything stays on this device.',
                style: AppTextStyles.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.hudLabel.copyWith(fontSize: 9)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
