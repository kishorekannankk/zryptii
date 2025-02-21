import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:zryptii/services/file_loading_service.dart';

class DocumentViewer extends StatelessWidget {
  final String filePath;
  final bool isLargeFile;
  final ValueChanged<double>? onProgress;

  const DocumentViewer({
    super.key,
    required this.filePath,
    this.isLargeFile = false,
    this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    final extension = path.extension(filePath).toLowerCase();
    final fileName = path.basename(filePath);

    if (extension == '.pdf') {
      return _buildPdfViewer(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, size: 48),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Support for ${extension.toUpperCase()} files coming soon',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(BuildContext context) {
    if (!isLargeFile) {
      return SfPdfViewer.file(
        File(filePath),
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${details.error}')),
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

        return SfPdfViewer.file(
          File(filePath),
          onDocumentLoadFailed: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${details.error}')),
            );
          },
        );
      },
    );
  }
}
