import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_service.dart';

Stopwatch time = Stopwatch()..start();

//TODO: Make it configurable
KeyCode? keyCode;

class HotKeyService {
  HotKeyService();

  static final HotKeyService instance = HotKeyService();

  Future<void> initHotkeyRegistration() async {
    await hotKeyManager.unregisterAll();

    final useHotKey = SettingsService.instance.hotKeyEnabled();

    if (time.elapsedMilliseconds >= 0 && useHotKey) {
      final HotKey hideShortcut = HotKey(
        keyCode ?? KeyCode.period,
        modifiers: [KeyModifier.alt],
        scope: HotKeyScope.system, // Set as system-wide hotkey.
      );

      await hotKeyManager.register(hideShortcut, keyDownHandler: (hotKey) async {
        if (time.elapsedMilliseconds > 250) {
          if (await windowManager.isMinimized()) {
            time.reset();
            await windowManager.show(inactive: true);
            return;
          }

          if (await windowManager.isVisible()) {
            time.reset();
            await windowManager.hide();
          } else {
            time.reset();
            await windowManager.show();
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
