import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../clipboard/clipboard_service.dart';
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
    await _clipboardService.setClipboardContents(emoji.emoji);
    // Trigger copy notification.
    emit(state.copyWith(copiedEmoji: emoji.emoji));
    await _settingsService.saveRecentEmoji(emoji);
  }
}
