import 'dart:io';

import 'package:flutter/material.dart';

import '../emoji/cubit/emoji_cubit.dart';
import '../logs/logging_manager.dart';
import 'app_hotkey.dart';

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  LoggingShortcutManager({required super.shortcuts});

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      log.t('''Handled shortcut
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
    log.t('''Action invoked:
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
    log.t('Next category requested.');
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
    log.t('Previous category requested.');
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
  Future<Object?> invoke(QuitIntent intent) async {
    await hotKeyService.unregisterBindings();
    log.t('Quit requested, exiting.');
    exit(0);
  }
}
