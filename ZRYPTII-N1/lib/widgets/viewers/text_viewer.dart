import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zryptii/services/file_loading_service.dart';

class TextViewer extends StatelessWidget {
  final String filePath;
  final bool isLargeFile;
  final ValueChanged<double>? onProgress;

  const TextViewer({
    super.key,
    required this.filePath,
    this.isLargeFile = false,
    this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLargeFile) {
      return FutureBuilder<String>(
        future: File(filePath).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(snapshot.data ?? ''),
          );
        },
      );
    }

    return StreamBuilder<double>(
      stream: FileLoadingService.loadFileWithProgress(filePath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          onProgress?.call(snapshot.data!);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<String>(
          future: File(filePath).readAsString(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.data ?? ''),
            );
          },
        );
      },
    );
  }
}
