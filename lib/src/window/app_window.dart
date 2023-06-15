import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';
import 'package:window_manager/window_manager.dart';

class AppWindow {
  AppWindow._();

  static Future<AppWindow?> initialize() async {
    if (!defaultTargetPlatform.isDesktop) return null;
    await windowManager.ensureInitialized();
    return AppWindow._();
  }

  /// Exits the app.
  void close() => exit(0);

  /// Focuses the window.
  Future<void> focus() async => await windowManager.focus();

  Future<void> hide() async => await windowManager.hide();

  Future<void> show() async => await windowManager.show();
}
