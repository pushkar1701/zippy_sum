import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String _logoAsset = 'assets/images/zippy_sum_logo.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ZippySum')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Image.asset(
            _logoAsset,
            height: 120,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.offline_bolt_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ZippySum',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Logo not found (add $_logoAsset)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Classic',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.classicGame),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Daily challenge',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.dailyChallenge),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Stats',
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.stats),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'How to play',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.howToPlay),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.settings),
          ),
        ],
      ),
    );
  }
}
