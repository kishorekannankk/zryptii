import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zryptii/services/file_loading_service.dart';
import 'dart:typed_data';

class ImageViewer extends StatelessWidget {
  final String filePath;
  final bool isLargeFile;
  final ValueChanged<double>? onProgress;

  const ImageViewer({
    super.key,
    required this.filePath,
    this.isLargeFile = false,
    this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLargeFile) {
      return InteractiveViewer(
        maxScale: 4.0,
        child: Center(
          child: Image.file(File(filePath)),
        ),
      );
    }

    return StreamBuilder<double>(
      stream: FileLoadingService.loadFileWithProgress(filePath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          onProgress?.call(snapshot.data!);
        }

        return FutureBuilder<Uint8List>(
          future: FileLoadingService.loadFileInChunks(filePath, onProgress),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return InteractiveViewer(
              maxScale: 4.0,
              child: Center(
                child: Image.memory(snapshot.data!),
              ),
            );
          },
        );
      },
    );
  }
}
