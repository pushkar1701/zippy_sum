import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/daily_complete_args.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../models/player_stats.dart';
import '../services/haptics_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/arcade_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class DailyCompleteScreen extends StatefulWidget {
  const DailyCompleteScreen({super.key, required this.args});

  final DailyCompleteArgs args;

  factory DailyCompleteScreen.fallback() {
    return DailyCompleteScreen(
      args: DailyCompleteArgs(
        result: GameResult.placeholder(),
        stats: PlayerStats.empty(),
      ),
    );
  }

  @override
  State<DailyCompleteScreen> createState() => _DailyCompleteScreenState();
}

class _DailyCompleteScreenState extends State<DailyCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;
  late final Animation<double> _enterScale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _enterFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _enterScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutBack),
      ),
    );
    _enterCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticsService.instance.gameOver();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreFmt = NumberFormat.decimalPattern();
    final r = widget.args.result;
    final s = widget.args.stats;
    final streak = s.dailyStreak;
    final streakLabel =
        streak == 1 ? '1 day' : '$streak days';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ArcadeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _enterFade,
                  child: ScaleTransition(
                    scale: _enterScale,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPaddingH,
                        AppSpacing.md,
                        AppSpacing.screenPaddingH,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Celebration header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A3A5C), Color(0xFF2D1B69)],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCard,
                              ),
                              border: Border.all(
                                color: AppColors.accentCyan.withValues(
                                  alpha: 0.45,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: AppColors.accentAmber,
                                      size: 22,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'DAILY COMPLETE',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.screenTitle.copyWith(
                                        fontSize: 20,
                                        color: AppColors.accentCyan,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: AppColors.accentAmber,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  scoreFmt.format(r.score),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.display.copyWith(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.accentCyan.withValues(
                                          alpha: 0.55,
                                        ),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                if (streak > 0) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  _StreakPill(label: '$streakLabel streak 🔥'),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _StatRow(
                            label: "Today's score",
                            value: scoreFmt.format(r.score),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _StatRow(
                            label: 'Daily streak',
                            value: streakLabel,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _StatRow(
                            label: "Today's best",
                            value: scoreFmt.format(s.todayDailyBestScore),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _StatRow(
                            label: 'Best daily score',
                            value: scoreFmt.format(s.bestDailyScore),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PrimaryButton(
                            label: 'PLAY CLASSIC',
                            trailingIcon: Icons.play_arrow_rounded,
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                AppRouter.classicGame,
                                arguments: GameMode.classic,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'MY STATS',
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.stats);
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: SecondaryButton(
                                  label: 'TRY AGAIN',
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(
                                      AppRouter.classicGame,
                                      arguments: GameMode.daily,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRouter.home,
                                (_) => false,
                              );
                            },
                            child: Text(
                              'HOME',
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
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
// Streak pill
// ---------------------------------------------------------------------------

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: AppColors.primaryPurpleBright.withValues(alpha: 0.55),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryPurpleBright,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat row
// ---------------------------------------------------------------------------

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
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
