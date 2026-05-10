import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

/// Home-style list row with chevron (no Ranks / no extra tabs).
class ArcadeListTile extends StatelessWidget {
  const ArcadeListTile({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.compact = false,
    this.badge,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool compact;
  /// Optional small pill badge shown before the chevron (e.g. "TODAY").
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final vPad = compact ? AppSpacing.sm : AppSpacing.md;
    final iconSize = compact ? 20.0 : 22.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.xs : AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: vPad,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.accentCyan, size: iconSize),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 16 : 18,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: AppColors.accentCyan.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.hudLabel.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
