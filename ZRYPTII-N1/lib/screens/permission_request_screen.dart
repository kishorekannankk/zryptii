import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zryptii/services/permissions_service.dart';

class PermissionRequestScreen extends StatelessWidget {
  const PermissionRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_open,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Storage Access Required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'ZRYPTII needs access to your storage to read files. '
                'No files will be modified.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _requestPermission(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Grant Access'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _openSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final status = await PermissionsService.requestStoragePermission();
    if (!context.mounted) return;

    switch (status) {
      case StoragePermissionStatus.granted:
        Navigator.pop(context, true);
        break;
      case StoragePermissionStatus.denied:
        _showError(context, 'Permission denied. Please grant storage access.');
        break;
      case StoragePermissionStatus.restricted:
        _showError(context, 'Storage access is restricted on this device.');
        break;
      case StoragePermissionStatus.unsupportedPlatform:
        _showError(context, 'This feature is not supported on your device.');
        break;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }
}
