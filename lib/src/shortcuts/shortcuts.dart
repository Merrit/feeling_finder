import 'dart:io';

import 'package:flutter/material.dart';

import '../emoji/cubit/emoji_cubit.dart';
import '../logs/logging_manager.dart';

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  LoggingShortcutManager({required super.shortcuts});

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      log.v('''Handled shortcut
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
    log.v('''Action invoked:
Action: $action($intent)
From: $context
    ''');

    super.invokeAction(action, intent, context);

    return null;
  }
}

/// An intent to change the emoji category to the next one.
class NextCategoryIntent extends Intent {
  const NextCategoryIntent();
}

/// An action to change the emoji category to the next one.
class NextCategoryAction extends Action<NextCategoryIntent> {
  @override
  Object? invoke(NextCategoryIntent intent) {
    log.v('Next category requested.');
    EmojiCubit.instance.nextCategory();
    return null;
  }
}

/// An intent to change the emoji category to the previous one.
class PreviousCategoryIntent extends Intent {
  const PreviousCategoryIntent();
}

/// An action to change the emoji category to the previous one.
class PreviousCategoryAction extends Action<PreviousCategoryIntent> {
  @override
  Object? invoke(PreviousCategoryIntent intent) {
    log.v('Previous category requested.');
    EmojiCubit.instance.previousCategory();
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
    log.v('Quit requested, exiting.');
    exit(0);
  }
}
