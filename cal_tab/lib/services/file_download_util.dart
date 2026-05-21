import 'dart:convert';

import 'package:cal_tab/services/backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileDownloadUtil {
  const FileDownloadUtil._();

  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<void> exportBackupJson(
    BuildContext context,
    String backupJson,
  ) async {
    final fileName = BackupService.getBackupFileName();
    final bytes = Uint8List.fromList(utf8.encode(backupJson));

    if (isMobilePlatform) {
      await _saveBackupFileMobile(context, bytes, fileName);
    } else {
      await _saveBackupFileDesktop(context, backupJson, bytes, fileName);
    }
  }

  static Future<void> _saveBackupFileMobile(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Backup speichern',
        fileName: fileName,
        bytes: bytes,
      );

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup gespeichert: $path')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
    }
  }

  static Future<void> _saveBackupFileDesktop(
    BuildContext context,
    String backupJson,
    Uint8List bytes,
    String fileName,
  ) async {
    if (kIsWeb) {
      await _copyToClipboardFallback(context, backupJson, fileName);
      return;
    }

    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Backup speichern',
        fileName: fileName,
        bytes: bytes,
      );

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup gespeichert: $path')));
      }
    } catch (e) {
      await _copyToClipboardFallback(context, backupJson, fileName);
    }
  }

  static Future<void> _copyToClipboardFallback(
    BuildContext context,
    String backupJson,
    String fileName,
  ) async {
    await Clipboard.setData(ClipboardData(text: backupJson));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backup in die Zwischenablage kopiert!'),
                  Text(
                    'Dateiname: $fileName',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static Future<String?> pickBackupJson() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.single.bytes;
    if (bytes == null) return null;

    return utf8.decode(bytes);
  }
}
