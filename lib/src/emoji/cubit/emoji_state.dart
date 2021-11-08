part of 'emoji_cubit.dart';

/// Represents the state of the main emoji page.
@immutable
class EmojiState extends Equatable {
  /// The currently selected emoji category.
  final EmojiCategory category;

  /// Set when an emoji is copied to clipboard to trigger notification.
  final String? copiedEmoji;

  /// The list of currently loaded emojis, based on the selected category.
  final List<Emoji> emojis;

  /// True if a list of recent emojis was loaded from storage.
  final bool haveRecentEmojis;

  const EmojiState({
    required this.category,
    this.copiedEmoji,
    required this.emojis,
    this.haveRecentEmojis = false,
  });

  factory EmojiState.initial(List<Emoji> recentEmojis) {
    final haveRecents = (recentEmojis.isNotEmpty);
    final category = (haveRecents) ? EmojiCategory.recent : EmojiCategory.all;
    return EmojiState(
      category: category,
      emojis: (haveRecents) ? recentEmojis : const [],
      haveRecentEmojis: haveRecents,
    );
  }

  @override
  List<Object?> get props => [
        category,
        copiedEmoji,
        emojis,
        haveRecentEmojis,
      ];

  EmojiState copyWith({
    EmojiCategory? category,
    String? copiedEmoji,
    List<Emoji>? emojis,
    bool? haveRecentEmojis,
  }) {
    return EmojiState(
      category: category ?? this.category,
      copiedEmoji: copiedEmoji ?? this.copiedEmoji,
      emojis: emojis ?? this.emojis,
      haveRecentEmojis: haveRecentEmojis ?? this.haveRecentEmojis,
    );
  }
}
