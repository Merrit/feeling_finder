import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import '../logs/logging_manager.dart';

/// Events that can be emitted by the window.
enum WindowEvent {
  close,
  closeRequested,
  focused,
  unfocused,
}

/// Interface for the application window.
class AppWindow {
  AppWindow._();

  factory AppWindow() {
    // Only desktop platforms have a window, so we return a stub implementation for other platforms
    // to avoid runtime errors from trying to access platform functionality that doesn't exist.
    return defaultTargetPlatform.isDesktop ? AppWindowImpl() : AppWindow._();
  }

  Future<void> initialize() => Future.value();

  /// Stream that emits a signal when the window state has changed.
  Stream<WindowEvent> get events => const Stream.empty();

  void close() {}
  Future<void> hide() => Future.value();
  Future<bool> isFocused() => Future.value(false);
  Future<bool> isVisible() => Future.value(false);

  /// Resets the window size to the default size.
  Future<void> resetSize() => Future.value();

  /// Sets whether the window should be shown in the taskbar.
  Future<void> setSkipTaskbar(bool skip) => Future.value();

  Future<void> show() => Future.value();

  /// Toggles the visibility of the window.
  ///
  /// We wanted to have logic to focus the window if it's already visible but not focused, however
  /// this is not possible on Wayland with GTK3. See:
  /// https://gitlab.gnome.org/GNOME/gtk/-/issues/4335
  Future<void> toggleVisible() => Future.value();
  void dispose() {}
}

/// Implementation of [AppWindow] for desktop platforms.
///
/// This implementation should not be used directly, instead use [AppWindow].
@visibleForTesting
class AppWindowImpl with WindowListener implements AppWindow {
  @override
  Future<void> initialize() async {
    if (!defaultTargetPlatform.isDesktop) {
      return;
    }

    await windowManager.ensureInitialized();

    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
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

  @override
  void close() {
    dispose();
    exit(0);
  }

  @override
  Future<void> hide() async => await windowManager.hide();

  @override
  Future<bool> isFocused() async => await windowManager.isFocused();

  @override
  Future<bool> isVisible() async => await windowManager.isVisible();

  @override
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

  @override
  Future<void> setSkipTaskbar(bool skip) async {
    await windowManager.setSkipTaskbar(skip);
  }

  @override
  Future<void> show() async => await windowManager.show();

  @override
  Future<void> toggleVisible() async {
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  }

  @override
  void dispose() => windowManager.removeListener(this);
}
