import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum StoragePermissionStatus {
  granted,
  denied,
  restricted,
  unsupportedPlatform,
}

class PermissionsService {
  static Future<StoragePermissionStatus> requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) {
        return StoragePermissionStatus.unsupportedPlatform;
      }

      final androidVersion = await _getAndroidVersion();
      if (androidVersion < 21) {
        // Below Android 5.0 (Lollipop)
        return StoragePermissionStatus.restricted;
      }

      if (androidVersion >= 33) {
        // Android 13 and above
        return await _requestAndroid13Permissions();
      } else if (androidVersion >= 29) {
        // Android 10 and above
        return await _requestAndroid10Permissions();
      } else {
        return await _requestLegacyStoragePermission();
      }
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus> hasStoragePermission() async {
    try {
      if (!Platform.isAndroid) {
        return StoragePermissionStatus.unsupportedPlatform;
      }

      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 33) {
        return await _hasAndroid13Permissions();
      } else if (androidVersion >= 29) {
        return await _hasAndroid10Permissions();
      } else {
        return await _hasLegacyStoragePermission();
      }
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<int> _getAndroidVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<StoragePermissionStatus> _requestAndroid13Permissions() async {
    try {
      final permissions = await Future.wait([
        Permission.photos.request(),
        Permission.storage.request(),
      ]);

      if (permissions.every((status) => status.isGranted)) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus> _requestAndroid10Permissions() async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus>
      _requestLegacyStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus> _hasAndroid13Permissions() async {
    try {
      final permissions = await Future.wait([
        Permission.photos.status,
        Permission.storage.status,
      ]);

      if (permissions.every((status) => status.isGranted)) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus> _hasAndroid10Permissions() async {
    try {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }

  static Future<StoragePermissionStatus> _hasLegacyStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return StoragePermissionStatus.granted;
      }
      return StoragePermissionStatus.denied;
    } catch (e) {
      return StoragePermissionStatus.restricted;
    }
  }
}
