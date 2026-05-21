import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/settings/about_section.dart';
import 'package:cal_tab/widgets/settings/api_key_section.dart';
import 'package:cal_tab/widgets/settings/appearance_section.dart';
import 'package:cal_tab/widgets/settings/backup_section.dart';
import 'package:cal_tab/widgets/settings/danger_zone_section.dart';
import 'package:cal_tab/widgets/settings/profile_section.dart';
import 'package:cal_tab/widgets/settings/targets_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(profileSetupControllerProvider).profile;
    final settings = ref.watch(appSettingsControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Settings',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          AppearanceSection(themeMode: settings.themeMode),
          const SizedBox(height: 16),
          const ApiKeySection(),
          if (profile != null) ...[
            const SizedBox(height: 16),
            TargetsSection(profile: profile),
            const SizedBox(height: 16),
            ProfileSection(profile: profile),
          ],
          const SizedBox(height: 16),
          const BackupSection(),
          const SizedBox(height: 16),
          const DangerZoneSection(),
          const SizedBox(height: 16),
          const AboutSection(),
        ],
      ),
    );
  }
}
