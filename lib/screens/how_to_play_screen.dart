import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../widgets/primary_button.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'How to Play',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'How to Play',
                  style: AppTextStyles.display.copyWith(fontSize: 26),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _Step(
                  number: '1',
                  title: 'Look at the Target',
                  body: 'Find the number you need to make.',
                ),
                const _Step(
                  number: '2',
                  title: 'Pick Tiles',
                  body: 'Tap numbers that add up to the target.',
                ),
                const _Step(
                  number: '3',
                  title: 'Go Fast',
                  body: 'Solve quickly to build your combo.',
                ),
                const _Step(
                  number: '4',
                  title: 'Too High?',
                  body: 'Tap tiles again or hit Clear.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Quick example', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text('Target 17 — tap 8, 5, and 4.', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                const _ExampleBoard(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              label: 'GOT IT',
              trailingIcon: Icons.check_rounded,
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRouter.home);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentCyanDim),
            ),
            child: Text(
              number,
              style: AppTextStyles.title.copyWith(color: AppColors.accentCyan),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleBoard extends StatelessWidget {
  const _ExampleBoard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('TARGET', style: AppTextStyles.hudLabel),
              const Spacer(),
              Text(
                '17',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.accentCyan,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ExTile('8', true),
              const SizedBox(width: AppSpacing.sm),
              _ExTile('5', true),
              const SizedBox(width: AppSpacing.sm),
              _ExTile('4', true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'That clears it — next target!',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExTile extends StatelessWidget {
  const _ExTile(this.label, this.selected);

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentCyan : AppColors.tileFace,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
        border: Border.all(
          color: selected ? AppColors.accentCyanDim : AppColors.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.numberTile.copyWith(
          fontSize: 20,
          color: selected ? AppColors.background : AppColors.tileNumber,
        ),
      ),
    );
  }
}
