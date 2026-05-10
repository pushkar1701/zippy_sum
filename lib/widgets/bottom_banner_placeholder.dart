import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

/// Fake banner slot — layout only, no ad SDK.
class BottomBannerPlaceholder extends StatelessWidget {
  const BottomBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.outlineBright.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rectangle_outlined,
                size: 18,
                color: AppColors.onSurfaceMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Banner placeholder',
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 0.4,
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
