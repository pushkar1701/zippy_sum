import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_assets.dart';
import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/player_stats.dart';
import '../services/local_storage_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/arcade_list_tile.dart';
import '../widgets/home_more_sheet.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  Future<PlayerStats> _loadHome() => LocalStorageService.instance.loadStats();

  Future<void> _showMoreSheet() {
    return showHomeMoreSheet(
      context,
      onSettings: () => _openRoute(AppRouter.settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreFormat = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.menu_rounded,
                    tooltip: 'More',
                    onPressed: _showMoreSheet,
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        AppAssets.logoHorizontal,
                        height: 40,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'ZippySum',
                            style: AppTextStyles.title.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.settings_rounded,
                    tooltip: 'Settings',
                    onPressed: () => _openRoute(AppRouter.settings),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<PlayerStats>(
                key: ValueKey(_statsReloadToken),
                future: _loadHome(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? PlayerStats.empty();
                  final streakVal = stats.dailyStreak;
                  final best = stats.bestClassicScore;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HomeLogoHero(),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap fast. Sum faster.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tagline.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: AppSpacing.md),
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
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'PLAY CLASSIC',
                          large: false,
                          trailingIcon: Icons.play_arrow_rounded,
                          onPressed: () => _openRoute(AppRouter.classicGame),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ArcadeListTile(
                          label: 'Daily Challenge',
                          icon: Icons.calendar_month_rounded,
                          compact: true,
                          onTap: () => _openRoute(AppRouter.dailyChallenge),
                        ),
                        ArcadeListTile(
                          label: 'Stats',
                          icon: Icons.emoji_events_rounded,
                          compact: true,
                          onTap: () => _openRoute(AppRouter.stats),
                        ),
                        ArcadeListTile(
                          label: 'How to Play',
                          icon: Icons.help_outline_rounded,
                          compact: true,
                          onTap: () => _openRoute(AppRouter.howToPlay),
                        ),
                        const SizedBox(height: AppSpacing.xs),
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

/// Main branding — full logo, bounded so it never stretches (aspect preserved).
class _HomeLogoHero extends StatelessWidget {
  const _HomeLogoHero();

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final maxH = (shortest * 0.42).clamp(168.0, 260.0);
    final maxW = MediaQuery.sizeOf(context).width - AppSpacing.md * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: Image.asset(
            AppAssets.logoFull,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'ZippySum',
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 32,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceContainer.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.accentCyan,
          ),
        ),
      ),
    );
    final t = tooltip;
    if (t != null && t.isNotEmpty) {
      return Tooltip(
        message: t,
        preferBelow: false,
        child: button,
      );
    }
    return button;
  }
}
