import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app/app_colors.dart';
import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/haptics_service.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _haptics = true;
  bool _sound = false;
  String _version = '…';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await LocalStorageService.instance.getHapticsEnabled();
    final s = await LocalStorageService.instance.getSoundEffectsEnabled();
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _haptics = h;
      _sound = s;
      _version = '${info.version} (${info.buildNumber})';
      _loaded = true;
    });
  }

  Future<void> _setHaptics(bool v) async {
    await LocalStorageService.instance.setHapticsEnabled(v);
    HapticsService.instance.invalidateSettings();
    setState(() => _haptics = v);
  }

  Future<void> _setSound(bool v) async {
    await LocalStorageService.instance.setSoundEffectsEnabled(v);
    setState(() => _sound = v);
  }

  Future<void> _confirmResetStats() async {
    final go = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: AppColors.warningOrange,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'RESET STATS?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This clears local scores and progress. '
                'Onboarding stays completed.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'CANCEL',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('RESET STATS'),
            ),
          ],
        );
      },
    );

    if (go == true && mounted) {
      await LocalStorageService.instance.resetStats();
      if (mounted) setState(() {});
    }
  }

  void _placeholderSheet(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.md),
              Text(body, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !_loaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Gameplay', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  title: const Text('Haptics'),
                  subtitle: const Text('Light taps on actions and results'),
                  value: _haptics,
                  activeThumbColor: AppColors.accentCyan,
                  onChanged: _setHaptics,
                ),
                SwitchListTile(
                  title: const Text('Sound effects'),
                  subtitle: const Text('Coming soon — toggle saved for later'),
                  value: _sound,
                  activeThumbColor: AppColors.accentCyan,
                  onChanged: _setSound,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Privacy', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  title: const Text('Privacy choices'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.privacyChoices),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Support & legal', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _placeholderSheet(
                    'Privacy Policy',
                    'A full policy will be linked here before public release. '
                        'Everything today stays on your device — no account, no cloud sync.',
                  ),
                ),
                ListTile(
                  title: const Text('Support'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _placeholderSheet(
                    'Support',
                    'Contact options will be added before launch. Thanks for testing!',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.onSurfaceMuted,
                  ),
                  title: const Text('Offline info'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.offline),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Data', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusButton,
                      ),
                    ),
                  ),
                  onPressed: _confirmResetStats,
                  child: Text(
                    'RESET STATS',
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    'ZippySum · v$_version',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
