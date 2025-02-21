import 'package:flutter/material.dart';
import 'package:zryptii/screens/splash_screen.dart';
import 'package:zryptii/theme/app_theme.dart';

void main() {
  runApp(const ZryptiiApp());
}

class ZryptiiApp extends StatelessWidget {
  const ZryptiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZRYPTII',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
