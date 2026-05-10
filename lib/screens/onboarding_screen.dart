import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/local_storage_service.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  Future<void> _complete() async {
    await LocalStorageService.instance.setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          TextButton(
            onPressed: _complete,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _page = i),
              children: const [
                _OnboardPage1(),
                _OnboardPage2(),
                _OnboardPage3(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.accentCyan
                          : AppColors.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: _page < 2
                ? PrimaryButton(
                    label: 'Next',
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  )
                : PrimaryButton(
                    label: 'Start playing',
                    onPressed: _complete,
                  ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage1 extends StatelessWidget {
  const _OnboardPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hit the Target',
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tap numbers that add up to the target.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _FakeTargetCard(target: 17),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _MiniTile(label: '8', selected: true),
              const SizedBox(width: AppSpacing.sm),
              const _MiniTile(label: '5', selected: true),
              const SizedBox(width: AppSpacing.sm),
              const _MiniTile(label: '4', selected: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '8 + 5 + 4 = 17',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardPage2 extends StatelessWidget {
  const _OnboardPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Race the Clock',
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Solve fast, build combos, and beat your best score.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(label: 'Time', value: '00:42'),
                    ),
                    Expanded(
                      child: _MiniStat(label: 'Score', value: '1,240'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.accentCyanDim),
                  ),
                  child: Text(
                    'Combo x4',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.accentCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage3 extends StatelessWidget {
  const _OnboardPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Play Daily',
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Try a fresh challenge every day and keep your streak alive.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.4),
                  AppColors.surfaceContainerHigh,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.accentCyanDim),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 48,
                  color: AppColors.accentCyan,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Daily Challenge',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Streak: 5 days · Today’s best: 320',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeTargetCard extends StatelessWidget {
  const _FakeTargetCard({required this.target});

  final int target;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.accentCyanDim, width: 2),
        color: AppColors.surfaceContainerHigh,
      ),
      child: Row(
        children: [
          Text('TARGET', style: AppTextStyles.hudLabel),
          const Spacer(),
          Text(
            '$target',
            style: AppTextStyles.display.copyWith(
              color: AppColors.accentCyan,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentCyan : AppColors.tileFace,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
        border: Border.all(
          color: selected
              ? AppColors.accentCyanDim
              : AppColors.outline.withValues(alpha: 0.25),
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.numberTile.copyWith(
          fontSize: 22,
          color: selected ? AppColors.background : AppColors.tileNumber,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.hudLabel),
        Text(value, style: AppTextStyles.hudValue),
      ],
    );
  }
}
