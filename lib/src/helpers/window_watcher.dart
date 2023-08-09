import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';

import '../shortcuts/app_hotkey.dart';
import 'helpers.dart';

class WindowWatcher extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  const WindowWatcher({super.key, required this.child, required this.onClose});

  @override
  State<StatefulWidget> createState() => _WindowWatcherState();
}

class _WindowWatcherState extends State<WindowWatcher> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    if (platformIsDesktop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // always handle close actions manually
          await windowManager.setPreventClose(true);
        } catch (e) {
          debugPrint(e.toString());
        }
      });
    }
  }

  @override
  Future<void> onWindowClose() async {
    await hotKeyService.unregisterBindings();
    widget.onClose();
  }
}
