import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('How to play'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'The quick version',
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.md),
          _Bullet(
            icon: Icons.touch_app_rounded,
            text:
                'Tap number tiles to build sums that hit the target — fast fingers win.',
          ),
          _Bullet(
            icon: Icons.timer_rounded,
            text: 'Classic mode runs against the clock (details coming soon).',
          ),
          _Bullet(
            icon: Icons.calendar_today_rounded,
            text: 'Daily challenge refreshes once per day with a shared puzzle.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Full interactive tutorial will live here before launch.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentCyan, size: 26),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
