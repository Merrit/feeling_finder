part of 'emoji_cubit.dart';

/// Represents the state of the main emoji page.
@immutable
class EmojiState extends Equatable {
  /// The currently selected emoji category.
  final EmojiCategory category;

  /// The list of currently loaded emojis, based on the selected category.
  final List<Emoji> emojis;

  const EmojiState({
    required this.category,
    required this.emojis,
  });

  factory EmojiState.initial() {
    return const EmojiState(
      category: EmojiCategory.all,
      emojis: [],
    );
  }

  @override
  List<Object> get props => [
        category,
        emojis,
      ];

  EmojiState copyWith({
    EmojiCategory? category,
    List<Emoji>? emojis,
    bool? loading,
  }) {
    return EmojiState(
      category: category ?? this.category,
      emojis: emojis ?? this.emojis,
    );
  }
}
