import 'package:flutter/material.dart';

import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

class ZippyHeader extends StatelessWidget {
  const ZippyHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headline),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
