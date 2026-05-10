import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// v1: informational + navigation shell only (no UMP/consent SDK changes here).
class PrivacyChoicesScreen extends StatelessWidget {
  const PrivacyChoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy choices',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.shield_outlined, size: 56, color: AppColors.accentCyan),
            const SizedBox(height: AppSpacing.lg),
            Text('Ads help keep ZippySum free', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.md),
            Text(
              'We use advertising to support development. '
              'Your game progress stays on this device — no account required.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'CONTINUE',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'MANAGE CHOICES',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const Spacer(),
            Text(
              'A full consent flow can be connected here before launch.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
