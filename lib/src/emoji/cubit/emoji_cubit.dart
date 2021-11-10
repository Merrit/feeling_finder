import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../clipboard/clipboard_service.dart';
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
  final ClipboardService _clipboardService;
  final EmojiService _emojiService;
  final SettingsService _settingsService;

  EmojiCubit(
    this._clipboardService,
    this._emojiService,
    this._settingsService,
  ) : super(EmojiState.initial(_settingsService.recentEmojis())) {
    emojiCubit = this;

    /// If there were no recent emojis we start with the 'All' category.
    /// We call [setCategory] in the constructor so the emoji list can be built.
    if (state.emojis.isEmpty) setCategory(EmojiCategory.all);
  }

  /// Search and filter for an emoji that matches [searchString].
  void search(String searchString) {
    // TODO: This is a terrible way to search.
    final allEmojis = _emojiService.allEmojis();
    final filteredEmojis = <Emoji>[];
    for (var emoji in allEmojis) {
      final haveDescriptionMatch = emoji.description.contains(searchString);
      final haveAliasMatch = emoji.aliases.any(
        (element) => element.contains(searchString),
      );
      final haveTagMatch = emoji.aliases.any(
        (element) => element.contains(searchString),
      );
      final haveMatch = haveDescriptionMatch || haveAliasMatch || haveTagMatch;
      if (haveMatch) filteredEmojis.add(emoji);
    }
    emit(state.copyWith(
      category: EmojiCategory.all,
      emojis: filteredEmojis,
    ));
  }

  /// Sets the list of loaded emojis to the requested [category].
  void setCategory(EmojiCategory category) {
    List<Emoji> emojis;
    switch (category) {
      case EmojiCategory.recent:
        emojis = _settingsService.recentEmojis();
        break;
      case EmojiCategory.all:
        emojis = _emojiService.allEmojis();
        break;
      default:
        emojis = _emojiService.emojisByCategory(category);
    }
    emit(state.copyWith(
      category: category,
      emojis: emojis,
    ));
  }

  /// The user has clicked or tapped an emoji to be copied.
  Future<void> userSelectedEmoji(Emoji emoji) async {
    // Copy emoji to clipboard.
    await _clipboardService.setClipboardContents(emoji.emoji);

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
