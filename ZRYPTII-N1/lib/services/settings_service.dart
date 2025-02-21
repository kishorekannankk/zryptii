import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _showThumbnailsKey = 'show_thumbnails';
  static const String _defaultViewerKey = 'default_viewer';

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  static Future<bool> getShowThumbnails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showThumbnailsKey) ?? true;
  }

  static Future<void> setShowThumbnails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showThumbnailsKey, value);
  }

  static Future<String> getDefaultViewer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultViewerKey) ?? 'system';
  }

  static Future<void> setDefaultViewer(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultViewerKey, value);
  }
}
