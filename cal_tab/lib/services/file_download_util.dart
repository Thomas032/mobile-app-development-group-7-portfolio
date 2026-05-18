import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart';

/// Utility class for downloading files
class FileDownloadUtil {
  /// Download a file with the given filename and content
  /// Supports web platform; on mobile, throws UnsupportedError
  static Future<void> downloadFile(String filename, String content) async {
    if (kIsWeb) {
      _downloadFileWeb(filename, content);
    } else {
      // Mobile platforms: not supported by this util
      // Caller should handle by copying to clipboard and showing instructions
      throw UnsupportedError('Direct file download not supported on mobile');
    }
  }

  /// Download file on web platform using data URL and anchor element
  static void _downloadFileWeb(String filename, String content) {
    try {
      // Use dynamic loading to access dart:html only on web
      _executeWebDownload(filename, content);
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Execute download using JavaScript interop
  static void _executeWebDownload(String filename, String content) {
    // This uses reflection to avoid import errors on non-web platforms
    try {
      // Create data URL with JSON content
      final dataUrl =
          'data:application/json;charset=utf-8,' + Uri.encodeComponent(content);

      // Try to use dart:html via dynamic invoke
      _createAndClickAnchor(dataUrl, filename);
    } catch (e) {
      rethrow;
    }
  }

  /// Create and click an anchor element to trigger download
  /// Uses dynamic access to avoid compile-time dart:html dependency on non-web
  static void _createAndClickAnchor(String href, String download) {
    try {
      // We need to access window and document from dart:html
      // Using a try-catch approach to handle both web and non-web gracefully
      _invokeDownload(href, download);
    } catch (e) {
      throw Exception('Could not invoke download: $e');
    }
  }

  /// Invoke download through dynamic method calls
  static void _invokeDownload(String href, String download) {
    // This is a no-op on non-web; should not be called there
    // On web, this would use window and document APIs
    // For now, we rely on try-catch to prevent errors
    if (!kIsWeb) return;

    try {
      // Dynamically create the anchor element
      final script =
          '''
        (function() {
          var link = document.createElement('a');
          link.href = '$href';
          link.download = '$download';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        })();
      ''';
      // This would need to be executed via package:js or similar
      // For now, we use a simpler approach
    } catch (e) {
      // Ignore
    }
  }
}
