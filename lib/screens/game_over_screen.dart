import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../widgets/primary_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game over')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Round finished (placeholder).'),
            const Spacer(),
            PrimaryButton(
              label: 'Back to home',
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
