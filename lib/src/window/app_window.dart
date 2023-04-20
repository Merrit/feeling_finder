import 'package:window_manager/window_manager.dart';

class AppWindow {
  AppWindow._();

  static late AppWindow instance;

  static Future<void> initialize() async {
    await windowManager.ensureInitialized();
    instance = AppWindow._();
  }

  /// Focuses the window.
  Future<void> focus() async => await windowManager.focus();

  Future<void> hide() async => await windowManager.hide();

  Future<void> show() async => await windowManager.show();
}
