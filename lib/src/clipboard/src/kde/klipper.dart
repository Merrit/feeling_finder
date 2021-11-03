import 'dart:developer';

import 'package:dbus/dbus.dart';

/// Friendly Dart wrapper for KDE's "Klipper" clipboard service via DBus.
abstract class Klipper {
  static Future<void> setClipboardContents(String value) async {
    final client = DBusClient.session();
    final klipperInterface = DBusRemoteObject(
      client,
      name: 'org.kde.klipper',
      path: DBusObjectPath('/klipper'),
    );
    try {
      await klipperInterface.callMethod(
        'org.kde.klipper.klipper',
        'setClipboardContents',
        [DBusString(value)],
      );
    } catch (error) {
      log('Klipper: unable to set clipboard contents.\n'
          'Error: $error');
    }
  }
}
