import 'dart:async';
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

  /// Listener notifies when there is a change in the window.
  void addEvent(WindowEvent event) {
    switch (event) {
      case WindowEvent.focused:
        _windowEventController.add(WindowEvent.focused);
        break;
      case WindowEvent.unfocused:
        _windowEventController.add(WindowEvent.unfocused);
        break;
    }
  }

  /// Exits the app.
  void close() => exit(0);

  /// Stream that emits a signal when the window state has changed.
  Stream<WindowEvent> get events => _windowEventController.stream;

  /// Controller for the [events] stream.
  final StreamController<WindowEvent> _windowEventController =
      StreamController<WindowEvent>.broadcast();

  /// Focuses the window.
  Future<void> focus() async => await windowManager.focus();

  Future<void> hide() async => await windowManager.hide();

  Future<void> show() async => await windowManager.show();
}

enum WindowEvent {
  focused,
  unfocused,
}
