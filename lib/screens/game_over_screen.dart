import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/game_result.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key, required this.result});

  final GameResult result;

  String _accuracyLabel() {
    final pct = (result.accuracy * 100).clamp(0, 100);
    return '${pct.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classic'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryPurpleBright,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "TIME'S UP",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Final score',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${result.score}',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatRow(label: 'Targets solved', value: '${result.targetsSolved}'),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(label: 'Best combo', value: 'x${result.bestCombo}'),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(label: 'Accuracy', value: _accuracyLabel()),
              const Spacer(),
              PrimaryButton(
                label: 'Play again',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRouter.classicGame,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
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
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body),
          const Spacer(),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
