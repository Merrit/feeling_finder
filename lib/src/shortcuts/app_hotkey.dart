import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

late LogicalKeyboardKey hotkey;
Stopwatch? time = Stopwatch()..start();
void listener(RawKeyEvent event) async {
  RawKeyboard.instance.handleRawKeyEvent(event);
  //debugPrint(RawKeyboard.instance.keysPressed.toString());
  if (time!.elapsedMilliseconds > 250 && (event.isAltPressed && event.logicalKey == LogicalKeyboardKey.period)) {
    if (await windowManager.isVisible()) {
      time!.reset();
      windowManager.hide();
    } else {
      time!.reset();
      windowManager.show();
    }
  }
}

class HotkeyService {
  HotkeyService();

  Future<void> initHotkeyRegistration([LogicalKeyboardKey? key, KeyCode? keyCode]) async {

    await hotKeyManager.unregisterAll();
    print(time!.elapsedMilliseconds);

    final HotKey hideShortcut = HotKey(
      keyCode ?? KeyCode.period,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system, // Set as system-wide hotkey.
    );
    await hotKeyManager.register(
        hideShortcut,
        keyDownHandler: (hotKey) async {
          debugPrint(time!.elapsedMilliseconds.toString());
          if (time!.elapsedMilliseconds > 250) {
            if (await windowManager.isVisible()) {
              time!.reset();
              windowManager.hide();
            } else {
              time!.reset();
              windowManager.show();
            }
          }
          debugPrint('onKeyDown+${hotKey.toJson()}');
    });

    /*if (registerKeyboardListener(listener) == null) {
      debugPrint("Failed to register keyboard listener");
    }*/
  }
}
