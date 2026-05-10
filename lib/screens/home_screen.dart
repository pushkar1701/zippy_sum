import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/local_storage_service.dart';
import '../widgets/bottom_banner_placeholder.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String _logoAsset = 'assets/images/zippy_sum_logo.png';

  @override
  Widget build(BuildContext context) {
    final scoreFormat = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<int>>(
                future: Future.wait([
                  LocalStorageService.instance
                      .getInt(LocalStorageService.keyBestClassicScore),
                  LocalStorageService.instance
                      .getInt(LocalStorageService.keyDailyStreak),
                ]),
                builder: (context, snapshot) {
                  final best = snapshot.data?[0] ?? 0;
                  final streak = snapshot.data?[1] ?? 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            _logoAsset,
                            height: 120,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 72,
                                    color: AppColors.accentCyan,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'ZippySum',
                                    style: AppTextStyles.display,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Tap fast. Sum faster.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tagline,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Best score',
                                value: scoreFormat.format(best),
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: StatCard(
                                title: 'Daily streak',
                                value: streak == 1 ? '1 day' : '$streak days',
                                compact: true,
                                accentTitle: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: 'Play Classic',
                          large: true,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRouter.classicGame),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Daily Challenge',
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRouter.dailyChallenge),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Stats',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRouter.stats),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'How to Play',
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRouter.howToPlay),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Settings',
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRouter.settings),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  );
                },
              ),
            ),
            const BottomBannerPlaceholder(),
          ],
        ),
      ),
    );
  }
}
