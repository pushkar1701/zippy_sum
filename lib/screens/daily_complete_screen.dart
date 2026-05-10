import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/primary_button.dart';

class DailyCompleteScreen extends StatelessWidget {
  const DailyCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daily complete')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: AppColors.accentCyan,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Daily cleared!',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Rewards and streak updates will connect here later.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
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
    );
  }
}
