import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';
import 'package:unicode_emojis/unicode_emojis.dart' as ue;

import 'emoji.dart';
import 'emoji_category.dart';

/// Builds the emoji objects for the app to use.
class EmojiService {
  /// All of the emojis, ordered by category.
  final Map<EmojiCategory, List<Emoji>> allEmojis;

  const EmojiService._(this.allEmojis);

  /// Builds the emoji set from the supplied json.
  factory EmojiService(bool isWindows11) {
    final Map<EmojiCategory, List<Emoji>> emojiMap = _buildEmojisFromUnicodePackage(isWindows11);

    return EmojiService._(emojiMap);
  }

  /// Returns the `Emoji` belonging to [category].
  List<Emoji> emojisByCategory(EmojiCategory category) => allEmojis[category]!;

  /// Returns all emojis whos description, aliases or tags match [searchString].
  List<Emoji> search(String keyword) {
    final result = ue.UnicodeEmojis.search(keyword) //
        .map((ue.Emoji emoji) => emoji.toEmoji())
        .toList();

    // If the search string contains the word "red", add "black heart suit" and
    // "heavy black heart" emojis to the result.
    //
    // This is a workaround for the fact that these emojis are named oddly in
    // Unicode as a historical artifact.
    // See: https://emojipedia.org/glossary/#black
    if (keyword.contains('red')) {
      ue.UnicodeEmojis.search('black heart suit').forEach((emoji) {
        result.add(emoji.toEmoji());
      });

      ue.UnicodeEmojis.search('heavy black heart').forEach((emoji) {
        result.add(emoji.toEmoji());
      });
    }

    return result;
  }
}

/// Builds the emoji set from the unicode_emojis package.
Map<EmojiCategory, List<Emoji>> _buildEmojisFromUnicodePackage(bool isWindows11) {
  final Map<EmojiCategory, List<Emoji>> emojiMap = {};

  for (final emojiCategory in ue.Category.values) {
    final List<Emoji> emojiList = ue.UnicodeEmojis.allEmojis
        .where((emoji) => emoji.category == emojiCategory)
        .map((ue.Emoji emoji) => emoji.toEmoji())
        .toList();

    if (defaultTargetPlatform.isWindows) {
      // // Windows only supports version 14.0 of the Unicode emoji set.
      // emojiList.removeWhere((e) => double.parse(e.unicodeVersion) > 14.0);
      if (isWindows11) {
        // Windows 11 supports version 14.0 of the Unicode emoji set.
        emojiList.removeWhere((e) => double.parse(e.unicodeVersion) > 14.0);
      } else {
        // Windows 10 supports version 12.0 of the Unicode emoji set.
        emojiList.removeWhere((e) => double.parse(e.unicodeVersion) > 12.0);
      }
    }

    emojiMap[emojiCategory.toEmojiCategory()] = emojiList;
  }

  return emojiMap;
}

extension UnicodeEmojiHelper on ue.Emoji {
  Emoji toEmoji() {
    return Emoji(
      aliases: [],
      category: category.toEmojiCategory(),
      emoji: emoji,
      name: name,
      tags: [],
      unicodeVersion: addedIn,
      variants: skinVariations
          ?.map((skinVariation) => Emoji(
                aliases: [],
                category: category.toEmojiCategory(),
                emoji: skinVariation.emoji,
                name: name,
                tags: [],
                unicodeVersion: addedIn,
              ))
          .toList(),
    );
  }
}

extension UnicodeEmojiCategoryHelper on ue.Category {
  EmojiCategory toEmojiCategory() {
    switch (this) {
      case ue.Category.smileysAndEmotion:
        return EmojiCategory.smileys;
      case ue.Category.peopleAndBody:
        return EmojiCategory.peopleAndBody;
      case ue.Category.animalsAndNature:
        return EmojiCategory.animalsAndNature;
      case ue.Category.foodAndDrink:
        return EmojiCategory.foodAndDrink;
      case ue.Category.travelAndPlaces:
        return EmojiCategory.travelAndPlaces;
      case ue.Category.activities:
        return EmojiCategory.activities;
      case ue.Category.objects:
        return EmojiCategory.objects;
      case ue.Category.symbols:
        return EmojiCategory.symbols;
      case ue.Category.flags:
        return EmojiCategory.flags;
    }
  }
}
