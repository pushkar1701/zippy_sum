import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_colors.dart';
import '../app/app_links.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/consent_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// v1: informational consent shell — full UMP form wired via ConsentService.
class PrivacyChoicesScreen extends StatelessWidget {
  const PrivacyChoicesScreen({super.key});

  Future<void> _manageChoices(BuildContext context) async {
    final required = await ConsentService.instance.isPrivacyOptionsRequired();
    if (!required) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Privacy options are not required right now.'),
            backgroundColor: AppColors.surfaceContainerHigh,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    await ConsentService.instance.showPrivacyOptionsForm();
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppLinks.privacyPolicy);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Privacy Policy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy choices',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.shield_outlined, size: 56, color: AppColors.accentCyan),
            const SizedBox(height: AppSpacing.lg),
            Text('Ads help keep ZippySum free', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You can manage your privacy choices anytime. '
              'Your game progress stays on this device — no account required.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'CONTINUE',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'MANAGE CHOICES',
              onPressed: () => _manageChoices(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => _openPrivacyPolicy(context),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Privacy Policy'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentCyan,
              ),
            ),
            const Spacer(),
            Text(
              'A full UMP consent flow is connected via the Google SDK.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
