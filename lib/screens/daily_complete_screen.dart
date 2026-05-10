import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../widgets/primary_button.dart';

class DailyCompleteScreen extends StatelessWidget {
  const DailyCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily complete')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nice work! (placeholder)'),
            const Spacer(),
            PrimaryButton(
              label: 'Home',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.home,
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
