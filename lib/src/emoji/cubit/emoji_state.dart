part of 'emoji_cubit.dart';

/// Represents the state of the main emoji page.
@freezed
class EmojiState with _$EmojiState {
  const factory EmojiState({
    /// The currently selected emoji category.
    required EmojiCategory category,

    /// Set when an emoji is copied to clipboard to trigger notification.
    String? copiedEmoji,

    /// The list of currently loaded emojis, based on the selected category.
    required List<Emoji> emojis,

    /// True if a list of recent emojis was loaded from storage.
    required bool haveRecentEmojis,

    /// True if a search is currently active.
    required bool isSearching,
  }) = _EmojiState;

  factory EmojiState.initial(List<Emoji> recentEmojis, List<Emoji> smileys) {
    final haveRecents = (recentEmojis.isNotEmpty);
    return EmojiState(
      category: (haveRecents) ? EmojiCategory.recent : EmojiCategory.smileys,
      emojis: (haveRecents) ? recentEmojis : smileys,
      haveRecentEmojis: haveRecents,
      isSearching: false,
    );
  }
}
