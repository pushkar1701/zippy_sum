import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/zippy_header.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Game over')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.primaryPurpleBright,
                  ],
                ),
              ),
              child: Text(
                'Round complete',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const ZippyHeader(
              title: 'Nice run!',
              subtitle: 'Scoring and continue options will land here.',
              showAccentLine: true,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Back to home',
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
