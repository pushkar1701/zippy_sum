import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../widgets/primary_button.dart';
import '../widgets/zippy_header.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily challenge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ZippyHeader(
              title: 'Daily',
              subtitle: 'Placeholder — challenge flow comes later.',
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Mark complete (demo)',
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(AppRouter.dailyComplete),
            ),
          ],
        ),
      ),
    );
  }
}
