import 'package:flutter/material.dart';

import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          Text(
            'ZippySum is a number puzzle. '
            'Full rules and tutorials will go here.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
