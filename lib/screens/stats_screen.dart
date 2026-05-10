import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../models/player_stats.dart';
import '../services/local_storage_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/zippy_header.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              const ZippyHeader(
                title: 'Your stats',
                subtitle: 'Everything stays on this device for now.',
                showAccentLine: true,
              ),
              const SizedBox(height: AppSpacing.md),
              StatCard(
                title: 'Total games played',
                value: formatter.format(stats.totalGamesPlayed),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Best classic score',
                value: formatter.format(stats.bestClassicScore),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Total targets solved',
                value: formatter.format(stats.totalTargetsSolved),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Best combo',
                value: stats.bestCombo > 0 ? 'x${stats.bestCombo}' : '—',
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Average accuracy',
                value: accLabel,
              ),
            ],
          );
        },
      ),
    );
  }
}
