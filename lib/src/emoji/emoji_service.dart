import 'dart:convert';

import 'emoji.dart';
import 'emoji_category.dart';

/// Builds the emoji objects for the app to use.
class EmojiService {
  /// All of the emojis, ordered by category.
  final Map<EmojiCategory, List<Emoji>> allEmojis;

  const EmojiService._(this.allEmojis);

  /// Builds the emoji set from the supplied json.
  factory EmojiService(String emojiJson) {
    final emojiListData = json.decode(emojiJson) as List<dynamic>;

    // ignore: prefer_for_elements_to_map_fromiterable
    final emojiMap = Map<EmojiCategory, List<Emoji>>.fromIterable(
      EmojiCategory.values,
      key: (category) => category,
      value: (_) => <Emoji>[],
    )..remove(EmojiCategory.recent);

    for (final emojiData in emojiListData) {
      final emoji = Emoji.fromJson(emojiData);
      emojiMap[emoji.category]!.add(emoji);
    }

    return EmojiService._(emojiMap);
  }

  /// Returns the `Emoji` belonging to [category].
  List<Emoji> emojisByCategory(EmojiCategory category) => allEmojis[category]!;

  /// Returns all emojis whos description, aliases or tags match [searchString].
  List<Emoji> search(String searchString) {
    final matches = <Emoji>[];
    for (var category in allEmojis.values) {
      matches.addAll(category
          .where((emoji) =>
              emoji.description.contains(searchString) ||
              emoji.aliases.contains(searchString) ||
              emoji.tags.contains(searchString))
          .toList());
    }
    return matches;
  }
}
