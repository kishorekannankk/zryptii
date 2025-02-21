import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zryptii/screens/file_viewer_screen.dart';
import 'package:zryptii/screens/permission_request_screen.dart';
import 'package:zryptii/services/permissions_service.dart';
import 'package:zryptii/utils/file_utils.dart';
import 'package:zryptii/widgets/about_dialog.dart';
import 'package:zryptii/screens/settings_screen.dart';
import 'package:zryptii/services/recent_files_service.dart';
import 'package:zryptii/widgets/recent_files_list.dart';
import 'package:zryptii/utils/error_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZRYPTII'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open a File',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.file_open),
                      label: const Text('Select File'),
                      onPressed: () => _pickFile(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Files',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const RecentFilesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AppAboutDialog(),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final permissionStatus = await PermissionsService.hasStoragePermission();

      if (permissionStatus != StoragePermissionStatus.granted) {
        // ignore: use_build_context_synchronously
        final permissionGranted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const PermissionRequestScreen(),
          ),
        );

        if (permissionGranted != true) return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath == null) return;

        await _openFile(filePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${e.toString()}')),
      );
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final error = await FileUtils.validateFile(filePath);
      if (error != null) {
        if (!mounted) return;
        ErrorUtils.showErrorSnackBar(context, error);
        return;
      }

      final extension = filePath.split('.').last.toLowerCase();
      await RecentFilesService.addRecentFile(filePath, extension);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewerScreen(filePath: filePath),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ErrorUtils.showErrorSnackBar(
        context,
        'Error opening file: ${ErrorUtils.getReadableError(e)}',
      );
    }
  }
}
