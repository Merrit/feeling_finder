import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

  EmojiCubit(
    this._emojiService,
    // TODO: Persist category choice to disk and load that before the
    // cubit, then we can request correct category right away.
  ) : super(EmojiState.initial()) {
    emojiCubit = this;
    setCategory(EmojiCategory.all);
  }

  /// Sets the list of loaded emojis to the requested [category].
  void setCategory(EmojiCategory category) {
    List<Emoji> emojis;
    if (category == EmojiCategory.all) {
      emojis = _emojiService.allEmojis();
    } else {
      emojis = _emojiService.emojisByCategory(category);
    }
    emit(EmojiState(
      category: category,
      emojis: emojis,
    ));
  }
}
