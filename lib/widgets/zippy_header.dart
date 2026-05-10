import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

class ZippyHeader extends StatelessWidget {
  const ZippyHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showAccentLine = true,
  });

  final String title;
  final String? subtitle;
  final bool showAccentLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAccentLine)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        Text(title, style: AppTextStyles.headline),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
