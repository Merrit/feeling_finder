import 'dart:io';

import 'package:dbus/dbus.dart';

import '../core/core.dart';
import '../logs/logging_manager.dart';

/// If the app is already running, activate the existing session and exit this one.
Future<void> activateExistingSession() async {
  if (Platform.isLinux) await _activateLinuxSession();
}

Future<void> _activateLinuxSession() async {
  final client = DBusClient.session();
  final object = DBusRemoteObject(
    client,
    name: kPackageId,
    path: DBusObjectPath('/'),
  );

  try {
    // Check if the D-Bus object exists.
    // If it does, the app is already running.
    await object.introspect();
  } on Exception catch (e) {
    log.t('App is not already running: $e');
    return;
  }

  // If we've made it this far, the app is already running.
  try {
    // Toggle the window visibility for the existing session, then exit this one.
    final response = await object.callMethod(
      'codes.merritt.FeelingFinder',
      'toggleWindow',
      [],
    );
    log.i('Toggling window visibility for existing session: $response');
    exit(0);
  } on Exception catch (e) {
    log.e('Failed to toggle window visibility for existing session: $e');
  }
}
