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
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key, required this.result});

  final GameResult result;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_afterFirstFrame());
    });
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
        title: const Text('Classic'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (result.isNewBestScore) ...[
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 48,
                        color: AppColors.accentCyan,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.accentCyan,
                            AppColors.primaryPurpleBright,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'NEW BEST SCORE!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        scoreFormat.format(result.score),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (prev != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'PREVIOUS BEST ${scoreFormat.format(prev)}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          '+${scoreFormat.format(result.score - prev)}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          color: AppColors.surfaceContainer,
                          border: Border.all(
                            color: AppColors.accentCyan.withValues(alpha: 0.35),
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
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              scoreFormat.format(result.score),
                              style: AppTextStyles.display.copyWith(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.35,
                        children: [
                          _StatCell(
                            label: 'BEST SCORE',
                            value: scoreFormat.format(result.bestScore),
                          ),
                          _StatCell(
                            label: 'TARGETS SOLVED',
                            value: '${result.targetsSolved}',
                          ),
                          _StatCell(
                            label: 'BEST COMBO',
                            value: 'x${result.bestCombo}',
                          ),
                          _StatCell(label: 'ACCURACY', value: _accuracyLabel()),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      label: 'PLAY AGAIN',
                      trailingIcon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRouter.classicGame);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: 'RETURN HOME',
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.hudLabel.copyWith(
              color: AppColors.accentCyan,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
