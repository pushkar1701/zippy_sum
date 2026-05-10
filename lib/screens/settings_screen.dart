import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/secondary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Preferences', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sound, haptics, and legal links will be grouped here.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'No accounts, cloud saves, or purchases in this build.',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: 'Open Flutter docs (demo link)',
            onPressed: () async {
              final uri = Uri.parse('https://docs.flutter.dev/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}
