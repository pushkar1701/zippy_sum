import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

/// Rounded stat surface for home / stats flows.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.compact = false,
    this.accentTitle = false,
  });

  final String title;
  final String value;
  final bool compact;
  final bool accentTitle;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.caption.copyWith(
      color: accentTitle ? AppColors.accentCyan : AppColors.onSurfaceMuted,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = compact
        ? AppTextStyles.title.copyWith(fontWeight: FontWeight.w800)
        : AppTextStyles.headline;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase(), style: titleStyle),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
