import 'dart:io'; // Add this import for FileSystemException
import 'package:flutter/material.dart';

class ErrorUtils {
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String getReadableError(dynamic error) {
    if (error is FileSystemException) {
      switch (error.osError?.errorCode) {
        case 2:
          return 'File not found';
        case 13:
          return 'Permission denied';
        case 21:
          return 'File is a directory';
        default:
          return 'File system error: ${error.message}';
      }
    }

    return error.toString();
  }
}
