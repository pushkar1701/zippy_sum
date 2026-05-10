import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
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
      body: FutureBuilder<List<int>>(
        future: Future.wait([
          LocalStorageService.instance
              .getInt(LocalStorageService.keyBestClassicScore),
          LocalStorageService.instance
              .getInt(LocalStorageService.keyGamesPlayed),
          LocalStorageService.instance
              .getInt(LocalStorageService.keyDailyStreak),
        ]),
        builder: (context, snapshot) {
          final best = snapshot.data?[0] ?? 0;
          final played = snapshot.data?[1] ?? 0;
          final streak = snapshot.data?[2] ?? 0;

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
                title: 'Best classic score',
                value: formatter.format(best),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Games played',
                value: formatter.format(played),
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Daily streak',
                value: streak == 1 ? '1 day' : '${formatter.format(streak)} days',
                accentTitle: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
