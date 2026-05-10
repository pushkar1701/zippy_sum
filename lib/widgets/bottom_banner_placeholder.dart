import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';

/// Reserved space for a future banner ad (no SDK loaded).
class BottomBannerPlaceholder extends StatelessWidget {
  const BottomBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.2)),
      ),
      child: Text(
        'Ad slot',
        style: TextStyle(
          color: AppColors.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}
