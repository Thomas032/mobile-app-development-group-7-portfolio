import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/screens/placeholder_feature_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderFeatureScreen(
      title: 'Settings',
      icon: Icons.tune_outlined,
      description:
          'Profile edits, calorie target adjustments, macros, theme, and AI key settings will live here.',
      actions: [
        OutlinedButton.icon(
          key: const Key('reset_profile_button'),
          onPressed: () => ref
              .read(profileSetupControllerProvider.notifier)
              .clearSavedProfile(),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset onboarding'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('clear_food_logs_button'),
          onPressed: () =>
              ref.read(dailyLogControllerProvider.notifier).clearSavedEntries(),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear food logs'),
        ),
      ],
    );
  }
}
