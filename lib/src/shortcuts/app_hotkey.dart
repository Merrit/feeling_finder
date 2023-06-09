import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

Stopwatch time = Stopwatch()..start();

class HotKeyService {
  HotKeyService();

  static final HotKeyService instance = HotKeyService();

  Future<void> initHotkeyRegistration([KeyCode? keyCode]) async {
    await hotKeyManager.unregisterAll();
    
    if (time.elapsedMilliseconds >= 0) {
      final HotKey hideShortcut = HotKey(
        keyCode ?? KeyCode.period,
        modifiers: [KeyModifier.alt],
        scope: HotKeyScope.system, // Set as system-wide hotkey.
      );
      
      await hotKeyManager.register(
          hideShortcut,
          keyDownHandler: (hotKey) async {
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
