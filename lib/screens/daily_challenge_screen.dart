import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/zippy_header.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily challenge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ZippyHeader(
              title: "Today's puzzle",
              subtitle: 'One fresh board every day. Placeholder flow for now.',
              showAccentLine: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Center(
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 72,
                  color: AppColors.accentCyan.withValues(alpha: 0.5),
                ),
              ),
            ),
            PrimaryButton(
              label: 'Start (placeholder)',
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(AppRouter.dailyComplete),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
