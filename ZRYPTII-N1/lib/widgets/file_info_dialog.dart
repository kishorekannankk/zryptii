import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class FileInfoDialog extends StatelessWidget {
  final String filePath;

  const FileInfoDialog({
    super.key,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileStat>(
      future: File(filePath).stat(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        }

        final stat = snapshot.data!;
        final formatter = DateFormat('MMM d, y HH:mm:ss');

        return AlertDialog(
          title: const Text('File Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Name:', path.basename(filePath)),
              _buildInfoRow('Type:', path.extension(filePath).toUpperCase()),
              _buildInfoRow('Size:', _formatFileSize(stat.size)),
              _buildInfoRow('Created:', formatter.format(stat.changed)),
              _buildInfoRow('Modified:', formatter.format(stat.modified)),
              _buildInfoRow('Accessed:', formatter.format(stat.accessed)),
              _buildInfoRow('Mode:', stat.modeString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
