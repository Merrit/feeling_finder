import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Convenience function to check if the app is running on a desktop computer.
///
/// If the currently running platform is one of Linux, Windows, or MacOS
/// this returns true.
///
/// If the running platform is Android, iOS or Web this returns false.
bool platformIsDesktop() {
  final bool platformIsDesktop;
  if (kIsWeb) {
    platformIsDesktop = false;
  } else {
    switch (Platform.operatingSystem) {
      case 'linux':
        platformIsDesktop = true;
        break;
      case 'windows':
        platformIsDesktop = true;
        break;
      case 'macos':
        platformIsDesktop = true;
        break;
      default:
        platformIsDesktop = false;
    }
  }
  return platformIsDesktop;
}

/// Convenience function to check if the app is running on a mobile device.
bool platformIsMobile() => (!platformIsDesktop() && !kIsWeb) ? true : false;
