import 'package:cal_tab/providers/backup_provider.dart';
import 'package:cal_tab/widgets/settings/export_backup_dialog.dart';
import 'package:cal_tab/widgets/settings/import_backup_dialog.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupControllerProvider);

    return SectionCard(
      title: 'Backup',
      icon: Icons.backup_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const Key('export_backup_button'),
            onPressed: backupState == BackupState.loading
                ? null
                : () => _showExportDialog(context, ref),
            icon: backupState == BackupState.loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text('Export backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('import_backup_button'),
            onPressed: backupState == BackupState.loading
                ? null
                : () => _showImportDialog(context, ref),
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Import backup'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ExportBackupDialog(parentRef: ref),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ImportBackupDialog(parentRef: ref),
    );
  }
}
