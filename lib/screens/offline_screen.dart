import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/primary_button.dart';

/// Shown when you need a dedicated offline message (no auto-routing wired).
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.cloud_off_rounded,
                size: 72,
                color: AppColors.onSurfaceMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "You're offline",
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(fontSize: 26),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Scores and puzzles still work on device. '
                'Some ads may not load until you reconnect.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'CONTINUE PLAYING',
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed(AppRouter.home);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
