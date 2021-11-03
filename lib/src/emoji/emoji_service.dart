import 'dart:convert';

import 'emoji.dart';
import 'emoji_category.dart';

/// Builds the emoji objects for the app to use.
class EmojiService {
  /// The emoji objects are built from the supplied json.
  final String _emojiJson;

  EmojiService(this._emojiJson);

  List<Emoji>? _allEmojis;

  /// Returns every emoji from all categories.
  List<Emoji> allEmojis() {
    if (_allEmojis != null) return _allEmojis!;
    final rawEmojiList = json.decode(_emojiJson) as List;
    final emojiList = <Emoji>[];
    for (final emoji in rawEmojiList) {
      final convertedEmoji = Emoji.fromJson(emoji as Map<String, dynamic>);
      emojiList.add(convertedEmoji);
    }
    _allEmojis = emojiList;
    return emojiList;
  }

  /// Returns the emoji belonging to [category].
  List<Emoji> emojisByCategory(EmojiCategory category) {
    allEmojis(); // Ensure the emoji list has populated.
    assert(_allEmojis != null);
    return _allEmojis!
        .where((emoji) => emoji.category == category.value)
        .toList();
  }
}
