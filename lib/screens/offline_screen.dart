import 'package:flutter/material.dart';

import '../app/app_assets.dart';
import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/arcade_background.dart';
import '../widgets/primary_button.dart';

/// Shown when you need a dedicated offline message.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ArcadeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // ZippySum mark or cloud-off fallback
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft glow behind mark
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentCyan.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        AppAssets.mark,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 72,
                              color: AppColors.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
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
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'CONTINUE PLAYING',
                  trailingIcon: Icons.play_arrow_rounded,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed(AppRouter.home);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
