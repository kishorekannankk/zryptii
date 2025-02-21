import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class VideoViewer extends StatelessWidget {
  final String filePath;

  const VideoViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(filePath);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_file, size: 48),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Video player coming soon',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
