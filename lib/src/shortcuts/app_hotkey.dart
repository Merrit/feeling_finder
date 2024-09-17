import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../settings/settings_service.dart';
import '../window/app_window.dart';

Stopwatch time = Stopwatch()..start();

//TODO: Make it configurable
PhysicalKeyboardKey? _key;

class HotKeyService {
  HotKeyService();

  static final HotKeyService instance = HotKeyService();

  Future<void> initHotkeyRegistration(AppWindow appWindow) async {
    await hotKeyManager.unregisterAll();

    final useHotKey = SettingsService.instance.hotKeyEnabled();

    if (time.elapsedMilliseconds >= 0 && useHotKey) {
      final HotKey hideShortcut = HotKey(
        key: _key ?? PhysicalKeyboardKey.period,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system, // Set as system-wide hotkey.
      );

      await hotKeyManager.register(hideShortcut, keyDownHandler: (hotKey) async {
        if (time.elapsedMilliseconds > 250) {
          await appWindow.toggleVisible();
          time.reset();
        }
      });
    }
  }

  Future<void> unregisterBindings() async {
    await hotKeyManager.unregisterAll();
  }
}

final hotKeyService = HotKeyService.instance;
