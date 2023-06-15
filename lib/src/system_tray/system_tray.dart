import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';
import 'package:tray_manager/tray_manager.dart';

import '../core/core.dart';
import '../window/app_window.dart';

/// Manages the system tray icon.
class SystemTray {
  const SystemTray._();

  static Future<SystemTray?> initialize(AppWindow? appWindow) async {
    if (appWindow == null) return null;
    if (!defaultTargetPlatform.isDesktop) return null;

    final String iconPath = (defaultTargetPlatform.isWindows) //
        ? AppIcons.windows
        : AppIcons.linux;

    await trayManager.setIcon(iconPath);

    final Menu menu = Menu(
      items: [
        MenuItem(label: 'Show', onClick: (menuItem) => appWindow.show()),
        MenuItem(label: 'Hide', onClick: (menuItem) => appWindow.hide()),
        MenuItem(label: 'Exit', onClick: (menuItem) => appWindow.close()),
      ],
    );

    await trayManager.setContextMenu(menu);

    return const SystemTray._();
  }

  /// Sets the system tray icon.
  Future<void> setIcon(String iconPath) async {
    await trayManager.setIcon(iconPath);
  }
}
