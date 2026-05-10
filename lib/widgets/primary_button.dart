import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

/// Purple gradient primary CTA (arcade board style).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.large = false,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool large;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final height = large ? 56.0 : 52.0;

    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            child: Ink(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                gradient: LinearGradient(
                  colors: enabled
                      ? AppColors.primaryButtonGradient
                      : [
                          AppColors.surfaceContainerHighest,
                          AppColors.surfaceContainerHigh,
                        ],
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(trailingIcon, color: Colors.white, size: 22),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
