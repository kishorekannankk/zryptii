import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class RecentFile {
  final String path;
  final String name;
  final DateTime lastOpened;
  final String fileType;
  final int fileSize;

  RecentFile({
    required this.path,
    required this.name,
    required this.lastOpened,
    required this.fileType,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'lastOpened': lastOpened.toIso8601String(),
        'fileType': fileType,
        'fileSize': fileSize,
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        path: json['path'],
        name: json['name'],
        lastOpened: DateTime.parse(json['lastOpened']),
        fileType: json['fileType'],
        fileSize: json['fileSize'] as int,
      );

  bool get exists => File(path).existsSync();

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class RecentFilesService {
  static const String _key = 'recent_files';
  static const int _maxFiles = 10;

  static Future<List<RecentFile>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((str) => RecentFile.fromJson(json.decode(str)))
        .where((file) => file.exists)
        .toList();
  }

  static Future<void> addRecentFile(String filePath, String fileType) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    final fileSize = await file.length();
    final prefs = await SharedPreferences.getInstance();
    final existingFiles = await getRecentFiles();

    existingFiles.removeWhere((f) => f.path == filePath);

    final newFile = RecentFile(
      path: filePath,
      name: filePath.split('/').last,
      lastOpened: DateTime.now(),
      fileType: fileType,
      fileSize: fileSize,
    );

    existingFiles.insert(0, newFile);

    while (existingFiles.length > _maxFiles) {
      existingFiles.removeLast();
    }

    final jsonList =
        existingFiles.map((file) => json.encode(file.toJson())).toList();

    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> clearRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static List<RecentFile> sortFiles(List<RecentFile> files, SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return List.from(files)..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameDesc:
        return List.from(files)..sort((a, b) => b.name.compareTo(a.name));
      case SortOption.dateAsc:
        return List.from(files)
          ..sort((a, b) => a.lastOpened.compareTo(b.lastOpened));
      case SortOption.dateDesc:
        return List.from(files)
          ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
      case SortOption.sizeAsc:
        return List.from(files)
          ..sort((a, b) => a.fileSize.compareTo(b.fileSize));
      case SortOption.sizeDesc:
        return List.from(files)
          ..sort((a, b) => b.fileSize.compareTo(a.fileSize));
      case SortOption.typeAsc:
        return List.from(files)
          ..sort((a, b) => a.fileType.compareTo(b.fileType));
      case SortOption.typeDesc:
        return List.from(files)
          ..sort((a, b) => b.fileType.compareTo(a.fileType));
    }
  }
}

enum SortOption {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  sizeAsc,
  sizeDesc,
  typeAsc,
  typeDesc,
}
