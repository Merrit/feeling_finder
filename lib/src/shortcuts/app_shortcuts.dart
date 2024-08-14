import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shortcuts.dart';

/// Shortcuts that are available everywhere in the app.
///
/// This widget is to be wrapped around the widget intended as a route.
class AppShortcuts extends StatelessWidget {
  final Widget child;

  AppShortcuts({
    super.key,
    required this.child,
  });

  final _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      alt: true,
    ): const PreviousCategoryIntent(),
    const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      alt: true,
    ): const NextCategoryIntent(),
    const SingleActivator(
      LogicalKeyboardKey.keyQ,
      control: true,
    ): const QuitIntent(),
    const SingleActivator(
      LogicalKeyboardKey.keyW,
      control: true,
    ): const QuitIntent(),
  };

  final _actions = <Type, Action<Intent>>{
    NextCategoryIntent: NextCategoryAction(),
    PreviousCategoryIntent: PreviousCategoryAction(),
    QuitIntent: QuitAction(),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      manager: LoggingShortcutManager(shortcuts: _shortcuts),
      child: Actions(
        dispatcher: LoggingActionDispatcher(),
        actions: _actions,
        child: child,
      ),
    );
  }
}
