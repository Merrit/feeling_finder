import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../settings/cubit/settings_cubit.dart';
import '../../settings/settings_service.dart';
import '../emoji.dart';
import '../emoji_category.dart';
import '../emoji_service.dart';

part 'emoji_state.dart';

/// Convenient global access to the EmojiCubit.
///
/// There is only ever 1 instance of this cubit, and having this variable
/// means not having to do `context.read<EmojiCubit>()` to access it every time,
/// as well as making it available without a BuildContext.
late EmojiCubit emojiCubit;

/// Controls the state of [EmojiPage] and connects the
/// view to the [EmojiService].
class EmojiCubit extends Cubit<EmojiState> {
  final EmojiService _emojiService;
  final SettingsService _settingsService;

  EmojiCubit(
    this._emojiService,
    this._settingsService,
  ) : super(EmojiState.initial(
          _settingsService.recentEmojis(),
          _emojiService.emojisByCategory(EmojiCategory.smileys),
        )) {
    emojiCubit = this;
  }

  /// Search and filter for all emojis that match [searchString].
  void search(String searchString) {
    emit(state.copyWith(emojis: _emojiService.search(searchString)));
  }

  /// Sets the list of loaded emojis to the requested [category].
  void setCategory(EmojiCategory category) {
    emit(state.copyWith(
      category: category,
      emojis: (category == EmojiCategory.recent)
          ? _settingsService.recentEmojis()
          : _emojiService.emojisByCategory(category),
    ));
  }

  /// The user has clicked or tapped an emoji to be copied.
  Future<void> userSelectedEmoji(Emoji emoji) async {
    // Copy emoji to clipboard.
    final clipboardData = ClipboardData(text: emoji.emoji);
    await Clipboard.setData(clipboardData);

    ClipboardData? updatedClipboard = await Clipboard.getData('text/plain');
    if (updatedClipboard == null || updatedClipboard.text != emoji.emoji) {
      debugPrint('userSelectedEmoji: failed to copy to clipboard.');
    }

    // Check if the preference to exit on copy is set.
    final shouldExitApp = settingsCubit.state.exitOnCopy;

    if (!shouldExitApp) {
      // Trigger copy notification.
      // We don't want to bother if the app will be closing immediately.
      emit(state.copyWith(copiedEmoji: emoji.emoji));
    }

    // Update the list of recent emojis.
    await _settingsService.saveRecentEmoji(emoji);

    // Exit the app if the preference for that is true.
    if (shouldExitApp) exit(0);
  }
}
