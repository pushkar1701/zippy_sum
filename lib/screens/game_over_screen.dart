import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/game_result.dart';
import '../services/ads_service.dart';
import '../services/haptics_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/arcade_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key, required this.result});

  final GameResult result;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;
  late final Animation<double> _enterScale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _enterFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _enterScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _enterCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_afterFirstFrame());
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _afterFirstFrame() async {
    await _playHaptics();
    if (!mounted) return;
    await _maybeShowInterstitial();
  }

  Future<void> _playHaptics() async {
    await HapticsService.instance.gameOver();
    if (!mounted) return;
    if (widget.result.isNewBestScore) {
      await HapticsService.instance.newBestScore();
    }
  }

  Future<void> _maybeShowInterstitial() async {
    final n = widget.result.classicCompletionsTotal;
    if (n < 3 || n % 3 != 0) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await AdsService.instance.showInterstitialIfReady();
  }

  String _accuracyLabel() {
    final pct = (widget.result.accuracy * 100).clamp(0, 100);
    return '${pct.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final scoreFormat = NumberFormat.decimalPattern();
    final result = widget.result;
    final prev = result.previousClassicBestBeforeRound;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ZippySum',
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
                          if (result.isNewBestScore) ...[
                            _NewBestHero(
                              score: scoreFormat.format(result.score),
                              prev: prev != null
                                  ? scoreFormat.format(prev)
                                  : null,
                              delta: prev != null
                                  ? '+${scoreFormat.format(result.score - prev)}'
                                  : null,
                            ),
                          ] else ...[
                            _TimesUpHero(score: scoreFormat.format(result.score)),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 1.5,
                            children: [
                              _StatCell(
                                label: 'BEST SCORE',
                                value: scoreFormat.format(result.bestScore),
                                icon: Icons.emoji_events_rounded,
                              ),
                              _StatCell(
                                label: 'TARGETS SOLVED',
                                value: '${result.targetsSolved}',
                                icon: Icons.bolt_rounded,
                              ),
                              _StatCell(
                                label: 'BEST COMBO',
                                value: 'x${result.bestCombo}',
                                icon: Icons.local_fire_department_rounded,
                              ),
                              _StatCell(
                                label: 'ACCURACY',
                                value: _accuracyLabel(),
                                icon: Icons.gps_fixed_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: 'PLAY AGAIN',
                            trailingIcon: Icons.play_arrow_rounded,
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                AppRouter.classicGame,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SecondaryButton(
                            label: 'RETURN HOME',
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRouter.home,
                                (_) => false,
                              );
                            },
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
// NEW BEST hero
// ---------------------------------------------------------------------------

class _NewBestHero extends StatelessWidget {
  const _NewBestHero({required this.score, this.prev, this.delta});

  final String score;
  final String? prev;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B1E7A),
            Color(0xFF1A3A5C),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.25),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Spark icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.accentAmber, size: 20),
              const SizedBox(width: AppSpacing.sm),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.accentCyan, AppColors.primaryPurpleBright],
                ).createShader(bounds),
                child: Text(
                  'NEW BEST SCORE!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.bolt_rounded, color: AppColors.accentAmber, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Glowing score
          Text(
            score,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.7),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          if (prev != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Previous best $prev',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
            Text(
              delta!,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TIME'S UP hero
// ---------------------------------------------------------------------------

class _TimesUpHero extends StatelessWidget {
  const _TimesUpHero({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "TIME'S UP",
            textAlign: TextAlign.center,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.accentCyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nice run!',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            score,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat cell (with icon)
// ---------------------------------------------------------------------------

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.accentCyan),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.hudLabel.copyWith(
                  color: AppColors.accentCyan,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
