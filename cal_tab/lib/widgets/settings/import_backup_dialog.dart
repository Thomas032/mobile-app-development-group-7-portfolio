import 'package:cal_tab/providers/backup_provider.dart';
import 'package:cal_tab/services/file_download_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportBackupDialog extends StatefulWidget {
  const ImportBackupDialog({super.key, required this.parentRef});

  final WidgetRef parentRef;

  @override
  State<ImportBackupDialog> createState() => _ImportBackupDialogState();
}

class _ImportBackupDialogState extends State<ImportBackupDialog> {
  late TextEditingController _controller;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useFilePicker = FileDownloadUtil.isMobilePlatform;

    return AlertDialog(
      title: const Text('Import Backup'),
      content: SizedBox(
        width: double.maxFinite,
        child: useFilePicker
            ? const Text(
                'Choose a backup JSON file from your device to restore your data.',
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Paste your backup JSON data here:'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    minLines: 5,
                    maxLines: 10,
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: 'Paste backup JSON',
                      hintText: 'Paste the backup file content...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isImporting
              ? null
              : useFilePicker
              ? _importFromFile
              : _importFromClipboard,
          child: Text(
            _isImporting
                ? 'Importing...'
                : (useFilePicker ? 'Choose backup file' : 'Import'),
          ),
        ),
      ],
    );
  }

  Future<void> _importFromFile() async {
    setState(() => _isImporting = true);

    try {
      final backupJson = await FileDownloadUtil.pickBackupJson();
      if (!mounted) return;

      if (backupJson == null || backupJson.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No backup file selected')),
        );
        return;
      }

      final success = await widget.parentRef
          .read(backupControllerProvider.notifier)
          .importData(backupJson.trim());

      if (!mounted) return;
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import backup')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _importFromClipboard() async {
    final backupJson = _controller.text.trim();
    if (backupJson.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please paste backup data')));
      return;
    }

    final success = await widget.parentRef
        .read(backupControllerProvider.notifier)
        .importData(backupJson);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup imported successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to import backup')));
    }
  }
}
