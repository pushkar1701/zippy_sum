import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          LocalStorageService.instance
              .getInt(LocalStorageService.keyBestClassicScore),
          LocalStorageService.instance
              .getInt(LocalStorageService.keyGamesPlayed),
        ]),
        builder: (context, snapshot) {
          final best = snapshot.data?[0] ?? 0;
          final played = snapshot.data?[1] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ZippyHeader(
                title: 'Your stats',
                subtitle: 'Stored on this device only.',
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
            ],
          );
        },
      ),
    );
  }
}
