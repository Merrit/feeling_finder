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
          final isFocused = await appWindow.isFocused();

          // TODO: This currently only checks if the window is _visible_, not if it's focused.
          // This means that if the window is visible but not focused, the window will remain
          // unfocused. We'd prefer to set it focused in this case.
          //
          // The `window_size` plugin doesn't provide a way to set focus, and the `window_manager`
          // plugin currently breaks the `onExitRequested` event.
          // See: https://github.com/leanflutter/window_manager/issues/466
          if (isFocused) {
            time.reset();
            await appWindow.hide();
          } else {
            time.reset();
            await appWindow.show();
          }
        }
      });
    }
  }

  Future<void> unregisterBindings() async {
    await hotKeyManager.unregisterAll();
  }
}

final hotKeyService = HotKeyService.instance;
