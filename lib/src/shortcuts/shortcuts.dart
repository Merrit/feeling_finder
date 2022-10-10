import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  LoggingShortcutManager({required super.shortcuts});

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      log('''Handled shortcut
Shortcut: $event
Context: $context
      ''');
    }
    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    log('''Action invoked:
Action: $action($intent)
From: $context
    ''');
    // log('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

/// An intent that is bound to QuitAction in order to quit this application.
class QuitIntent extends Intent {
  const QuitIntent();
}

/// An action that is bound to QuitIntent in order to quit this application.
class QuitAction extends Action<QuitIntent> {
  @override
  Object? invoke(QuitIntent intent) {
    log('Quit requested, exiting.');
    exit(0);
  }
}
