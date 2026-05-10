import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../services/haptics_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/secondary_button.dart';

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
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          title: Text('Reset Stats?', style: AppTextStyles.headline),
          content: Text(
            'This will clear your local scores and progress. '
            'Onboarding will stay completed.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Reset',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                Text('Support & legal', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _placeholderSheet(
                    'Privacy Policy',
                    'A full policy will be linked here before public release. '
                    'Everything today stays on your device — no account, no cloud sync.',
                  ),
                ),
                ListTile(
                  title: const Text('Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _placeholderSheet(
                    'Support',
                    'Contact options will be added before launch. Thanks for testing!',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Data', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: 'Reset stats',
                  onPressed: _confirmResetStats,
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
