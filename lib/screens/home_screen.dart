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
import '../widgets/arcade_background.dart';
import '../widgets/arcade_list_tile.dart';
import '../widgets/home_more_sheet.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _statsReloadToken = 0;
  late final AnimationController _bobCtrl;
  late final Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobCtrl.dispose();
    super.dispose();
  }

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
      body: ArcadeBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingH,
                  AppSpacing.sm,
                  AppSpacing.screenPaddingH,
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
                        child: Text(
                          'ZippySum',
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 18,
                            color: AppColors.accentCyan,
                          ),
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

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPaddingH,
                            AppSpacing.sm,
                            AppSpacing.screenPaddingH,
                            AppSpacing.md,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight - AppSpacing.md,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HomeLogoHero(bobAnim: _bobAnim),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Tap fast. Sum faster.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.tagline.copyWith(
                                    fontSize: 15,
                                    letterSpacing: 0.15,
                                  ),
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
                                            ? '0 days'
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
                                _GlowButton(
                                  label: 'PLAY CLASSIC',
                                  icon: Icons.play_arrow_rounded,
                                  onPressed: () =>
                                      _openRoute(AppRouter.classicGame),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ArcadeListTile(
                                  label: 'Daily Challenge',
                                  icon: Icons.bolt_rounded,
                                  badge: 'TODAY',
                                  compact: true,
                                  onTap: () =>
                                      _openRoute(AppRouter.dailyChallenge),
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
                                  onTap: () =>
                                      _openRoute(AppRouter.howToPlay),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo hero with bob + glow
// ---------------------------------------------------------------------------

class _HomeLogoHero extends StatelessWidget {
  const _HomeLogoHero({required this.bobAnim});

  final Animation<double> bobAnim;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final maxH = (h * 0.26).clamp(160.0, 248.0);
    final maxW =
        MediaQuery.sizeOf(context).width - AppSpacing.screenPaddingH * 2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial glow behind the logo
            Container(
              width: maxW,
              height: maxH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.72,
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.22),
                    AppColors.accentCyan.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Gently bobbing logo
            AnimatedBuilder(
              animation: bobAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, bobAnim.value),
                child: child,
              ),
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
                        fontSize: 28,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glowing primary CTA
// ---------------------------------------------------------------------------

class _GlowButton extends StatefulWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  late final Animation<double> _glowAlpha;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAlpha = Tween<double>(begin: 0.32, end: 0.58).animate(
      CurvedAnimation(parent: _glow, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAlpha,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(
                  alpha: _glowAlpha.value,
                ),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: PrimaryButton(
            label: widget.label,
            large: false,
            trailingIcon: widget.icon,
            onPressed: widget.onPressed,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared header icon button (unchanged)
// ---------------------------------------------------------------------------

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
    final proper = Material(
      color: AppColors.surfaceContainer.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        child: SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: Icon(icon, size: 22, color: AppColors.accentCyan),
        ),
      ),
    );
    final t = tooltip;
    if (t != null && t.isNotEmpty) {
      return Tooltip(message: t, preferBelow: false, child: proper);
    }
    return proper;
  }
}

