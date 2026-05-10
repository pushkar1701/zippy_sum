import 'package:flutter/material.dart';

import '../app/app_assets.dart';
import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      final seen = await LocalStorageService.instance.getHasSeenOnboarding();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(seen ? AppRouter.home : AppRouter.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final logoHeight = (shortest * 0.42).clamp(188.0, 300.0);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primaryPurple.withValues(alpha: 0.35),
              AppColors.surfaceContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.logoFull,
                      height: logoHeight,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'ZippySum',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Arcade',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCyan,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  color: AppColors.accentCyan,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRouter.privacyChoices),
                    child: Text(
                      'Privacy',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                  Text(
                    '|',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          title: const Text('Terms'),
                          content: const Text(
                            'Terms of use will be linked here before public release.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Terms',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
