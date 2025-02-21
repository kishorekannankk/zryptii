import 'dart:io';
import 'package:flutter/services.dart';

class FileOperationService {
  static const MethodChannel _channel =
      MethodChannel('zryptii/file_operations');

  static Future<bool> preventFileModification(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('preventFileModification', {
          'filePath': filePath,
        });
        return result ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFileReadOnly(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return !stat.modeString().contains('w');
    } catch (e) {
      return false;
    }
  }
}
