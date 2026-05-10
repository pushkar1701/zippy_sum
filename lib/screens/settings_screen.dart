import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_spacing.dart';
import '../widgets/secondary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Text('App settings will go here.'),
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
