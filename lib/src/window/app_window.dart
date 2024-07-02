import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:helpers/helpers.dart';
import 'package:window_size/window_size.dart' as window_size;

class AppWindow {
  /// The app lifecycle listener.
  late final AppLifecycleListener _appLifecycleListener;

  AppWindow._() {
    _appLifecycleListener = AppLifecycleListener(
      onExitRequested: _handleExitRequest,
    );
  }

  static Future<AppWindow?> initialize() async {
    if (!defaultTargetPlatform.isDesktop) return null;
    return AppWindow._();
  }

  /// To be called when the app is going to exit.
  Future<void> dispose() async {
    _appLifecycleListener.dispose();
    await _windowEventController.close();
  }

  Future<AppExitResponse> _handleExitRequest() async {
    // Emit an event informing the app that the window was requested to close.
    _windowEventController.add(WindowEvent.closeRequested);

    return AppExitResponse.cancel;
  }

  /// Exits the app.
  void close() => exit(0);

  /// Stream that emits a signal when the window state has changed.
  Stream<WindowEvent> get events => _windowEventController.stream;

  /// Controller for the [events] stream.
  final StreamController<WindowEvent> _windowEventController =
      StreamController<WindowEvent>.broadcast();

  Future<bool> isFocused() async =>
      SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed;

  Future<void> hide() async => window_size.setWindowVisibility(visible: false);

  Future<void> show() async => window_size.setWindowVisibility(visible: true);
}

enum WindowEvent {
  closeRequested,
  focused,
  unfocused,
}
