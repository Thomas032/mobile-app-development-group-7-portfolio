import 'package:cal_tab/providers/backup_provider.dart';
import 'package:cal_tab/services/file_download_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportBackupDialog extends ConsumerWidget {
  const ExportBackupDialog({super.key, required this.parentRef});

  final WidgetRef parentRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Export Backup'),
      content: const Text(
        'This will download your backup file. You can later import it to restore all your data.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final backupJson = await parentRef
                .read(backupControllerProvider.notifier)
                .exportData();
            if (backupJson == null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to export backup')),
              );
              return;
            }

            if (!context.mounted) return;
            await FileDownloadUtil.exportBackupJson(context, backupJson);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
