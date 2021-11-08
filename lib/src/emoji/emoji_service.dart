import 'dart:convert';

import 'package:collection/collection.dart';

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

  /// Returns an [Emoji] object representation of the [emojiString] passed in.
  /// If the [emojiString] doesn't match any emojis the return is null.
  ///
  /// Example: pass in 🌅 and return is an [Emoji] object whose [Emoji.emoji] is 🌅.
  Emoji? emojiObjectFromString(String emojiString) {
    allEmojis(); // Ensure the emoji list has populated.
    final matchingEmoji = _allEmojis!.firstWhereOrNull(
      (element) => element.emoji == emojiString,
    );
    return matchingEmoji;
  }
}
