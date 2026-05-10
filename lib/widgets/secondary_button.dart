import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

/// Cyan outline secondary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              border: Border.all(
                color: AppColors.accentCyan.withValues(
                  alpha: onPressed == null ? 0.35 : 1,
                ),
                width: 1.5,
              ),
              color: AppColors.accentCyan.withValues(alpha: 0.06),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.accentCyan.withValues(
                    alpha: onPressed == null ? 0.45 : 1,
                  ),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
