import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import '../logs/logging_manager.dart';

enum WindowEvent {
  close,
  closeRequested,
  focused,
  unfocused,
}

class AppWindow with WindowListener {
  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  /// Stream that emits a signal when the window state has changed.
  Stream<WindowEvent> get events => _windowEventController.stream;

  /// Controller for the [events] stream.
  final StreamController<WindowEvent> _windowEventController =
      StreamController<WindowEvent>.broadcast();

  @override
  void onWindowEvent(String eventName) {
    log.d('Window event: $eventName');

    switch (eventName) {
      case 'close':
        _windowEventController.add(WindowEvent.closeRequested);
    }
  }

  void close() {
    dispose();
    exit(0);
  }

  Future<void> hide() async => await windowManager.hide();
  Future<bool> isFocused() async => await windowManager.isFocused();
  Future<bool> isVisible() async => await windowManager.isVisible();

  /// Resets the window size to the default size.
  Future<void> resetSize() async {
    final windowInfo = await window_size.getWindowInfo();
    final currentFrame = windowInfo.frame;

    window_size.setWindowFrame(
      Rect.fromLTWH(
        currentFrame.left,
        currentFrame.top,
        640,
        700,
      ),
    );
  }

  /// Sets whether the window should be shown in the taskbar.
  Future<void> setSkipTaskbar(bool skip) async {
    await windowManager.setSkipTaskbar(skip);
  }

  Future<void> show() async => await windowManager.show();

  /// Toggles the visibility of the window.
  ///
  /// We wanted to have logic to focus the window if it's already visible but not focused, however
  /// this is not possible on Wayland with GTK3. See:
  /// https://gitlab.gnome.org/GNOME/gtk/-/issues/4335
  Future<void> toggleVisible() async {
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  }

  void dispose() => windowManager.removeListener(this);
}
