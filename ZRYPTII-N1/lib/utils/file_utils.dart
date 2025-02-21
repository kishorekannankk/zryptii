import 'package:path/path.dart' as path;
import 'dart:io';

enum FileType {
  image,
  document,
  text,
  unknown,
}

class FileUtils {
  static final List<String> supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
    'json',
    'xml',
    'csv',
  ];

  static bool isSupportedFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return getFileType(extension) != FileType.unknown;
  }

  static Future<bool> isSupportedFileAsync(String filePath) async {
    String extension = path.extension(filePath).toLowerCase();
    if (extension.startsWith('.')) {
      extension = extension.substring(1);
    }
    return supportedExtensions.contains(extension);
  }

  static FileType getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return FileType.image;
      case '.pdf':
      case '.doc':
      case '.docx':
        return FileType.document;
      case '.txt':
      case '.md':
      case '.json':
      case '.xml':
      case '.csv':
        return FileType.text;
      default:
        return FileType.unknown;
    }
  }

  static String getFilePickerFilter() {
    return supportedExtensions.map((e) => '*.$e').join(';');
  }

  static Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> validateFile(String filePath) async {
    if (!await isFileAccessible(filePath)) {
      return 'File is not accessible or corrupted';
    }

    if (!isSupportedFile(filePath)) {
      return 'Unsupported file format';
    }

    final file = File(filePath);
    if (await file.length() == 0) {
      return 'File is empty';
    }

    return null; // File is valid
  }
}
