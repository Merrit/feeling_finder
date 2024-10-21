import 'package:feeling_finder/src/window/app_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('receive stub implementation on non-desktop platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final appWindow = AppWindow();
    expect(appWindow, isNot(isA<AppWindowImpl>()));
    debugDefaultTargetPlatformOverride = null;
  });

  test('receive implementation on desktop platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final appWindow = AppWindow();
    expect(appWindow, isA<AppWindowImpl>());
    debugDefaultTargetPlatformOverride = null;
  });
}
