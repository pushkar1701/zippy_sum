import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/ads_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _logoAsset = 'assets/images/zippy_sum_logo.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AdsService.instance.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFF1A1830),
              AppColors.surfaceContainer,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                _logoAsset,
                height: 140,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 88,
                        color: AppColors.accentCyan,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'ZippySum',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.accentCyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
