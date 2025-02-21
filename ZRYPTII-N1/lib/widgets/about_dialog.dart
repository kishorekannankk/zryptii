import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '';

        return AlertDialog(
          title: const Text('About ZRYPTII'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ZRYPTII is a secure file viewer that works completely offline. '
                'It allows you to view various file formats in read-only mode, '
                'ensuring your files remain unmodified.',
              ),
              const SizedBox(height: 16),
              Text('Version: $version'),
              const SizedBox(height: 8),
              const Text('Supported file types:'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: const [
                  Chip(label: Text('PDF')),
                  Chip(label: Text('DOCX')),
                  Chip(label: Text('TXT')),
                  Chip(label: Text('Images')),
                  Chip(label: Text('PPT')),
                  Chip(label: Text('XLS')),
                ],
              ),
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
}
