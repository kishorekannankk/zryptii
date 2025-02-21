import 'package:flutter/material.dart';
import 'package:zryptii/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _showThumbnails = true;
  String _defaultViewer = 'system';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkMode = await SettingsService.isDarkMode();
    final thumbnails = await SettingsService.getShowThumbnails();
    final viewer = await SettingsService.getDefaultViewer();

    setState(() {
      _isDarkMode = darkMode;
      _showThumbnails = thumbnails;
      _defaultViewer = viewer;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme throughout the app'),
            value: _isDarkMode,
            onChanged: (value) async {
              await SettingsService.setDarkMode(value);
              setState(() => _isDarkMode = value);
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'File Viewing'),
          SwitchListTile(
            title: const Text('Show Thumbnails'),
            subtitle: const Text('Display thumbnails in file list'),
            value: _showThumbnails,
            onChanged: (value) async {
              await SettingsService.setShowThumbnails(value);
              setState(() => _showThumbnails = value);
            },
          ),
          ListTile(
            title: const Text('Default Viewer'),
            subtitle:
                const Text('Choose default application for opening files'),
            trailing: DropdownButton<String>(
              value: _defaultViewer,
              items: const [
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: 'internal',
                  child: Text('Built-in Viewer'),
                ),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await SettingsService.setDefaultViewer(value);
                  setState(() => _defaultViewer = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
