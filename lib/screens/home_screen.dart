import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/player_stats.dart';
import '../services/local_storage_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String _logoAsset = 'assets/images/zippy_sum_logo.png';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _statsReloadToken = 0;

  void _reloadStats() {
    setState(() => _statsReloadToken++);
  }

  Future<void> _openRoute(String route) async {
    await Navigator.of(context).pushNamed(route);
    if (mounted) _reloadStats();
  }

  Future<PlayerStats> _loadHome() =>
      LocalStorageService.instance.loadStats();

  @override
  Widget build(BuildContext context) {
    final scoreFormat = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<PlayerStats>(
                key: ValueKey(_statsReloadToken),
                future: _loadHome(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? PlayerStats.empty();
                  final streakVal = stats.dailyStreak;
                  final best = stats.bestClassicScore;

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
                            HomeScreen._logoAsset,
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
                                value: streakVal == 0
                                    ? '—'
                                    : (streakVal == 1
                                        ? '1 day'
                                        : '$streakVal days'),
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
                          onPressed: () => _openRoute(AppRouter.classicGame),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Daily Challenge',
                          onPressed: () =>
                              _openRoute(AppRouter.dailyChallenge),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Stats',
                          onPressed: () => _openRoute(AppRouter.stats),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'How to Play',
                          onPressed: () => _openRoute(AppRouter.howToPlay),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Settings',
                          onPressed: () => _openRoute(AppRouter.settings),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  );
                },
              ),
            ),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}
