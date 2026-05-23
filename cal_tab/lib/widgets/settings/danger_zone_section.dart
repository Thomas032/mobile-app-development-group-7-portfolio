import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Danger Zone',
      icon: Icons.warning_amber_outlined,
      accentColor: colors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const Key('reset_profile_button'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => _confirmAndResetOnboarding(context, ref),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset onboarding'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('clear_food_logs_button'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => _confirmAndClearFoodLogs(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear food logs'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndResetOnboarding(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _showDangerConfirmation(
      context,
      title: 'Reset onboarding?',
      message:
          'Do you really want to delete your onboarding progress? This will remove your saved profile setup and restart the onboarding. It will keep your food logs. Consider exporting a backup first if you want to keep your data.',
      confirmLabel: 'Reset onboarding',
    );
    if (!confirmed) return;

    await ref.read(profileSetupControllerProvider.notifier).clearSavedProfile();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Onboarding reset.')));
  }

  Future<void> _confirmAndClearFoodLogs(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _showDangerConfirmation(
      context,
      title: 'Clear food logs?',
      message:
          'Do you really want to delete all food logs? This permanently removes your meal history. Consider exporting a backup first if you want to keep your data.',
      confirmLabel: 'Clear food logs',
    );
    if (!confirmed) return;

    await ref.read(dailyLogControllerProvider.notifier).clearSavedEntries();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Food logs cleared.')));
  }

  Future<bool> _showDangerConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final colors = Theme.of(context).colorScheme;

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: Icon(
                Icons.warning_amber_rounded,
                color: colors.error,
                size: 32,
              ),
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
