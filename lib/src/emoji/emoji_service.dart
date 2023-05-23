import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;

import 'emoji.dart';
import 'emoji_category.dart';

/// Builds the emoji objects for the app to use.
class EmojiService {
  /// All of the emojis, ordered by category.
  final Map<EmojiCategory, List<Emoji>> allEmojis;

  const EmojiService._(this.allEmojis);

  /// Builds the emoji set from the supplied json.
  factory EmojiService() {
    final Map<EmojiCategory, List<Emoji>> emojiMap =
        _buildEmojisFromPickerPackage();

    return EmojiService._(emojiMap);
  }

  /// Returns the `Emoji` belonging to [category].
  List<Emoji> emojisByCategory(EmojiCategory category) => allEmojis[category]!;

  /// Returns all emojis whos description, aliases or tags match [searchString].
  Future<List<Emoji>> search(String keyword) async {
    final results = await emoji_picker.EmojiPickerUtils()
        .searchEmoji(keyword, emoji_picker.defaultEmojiSet);

    return results.map((emoji) {
      final category = _pickerEmojis[emoji]!.toEmojiCategory();

      return Emoji(
        aliases: [],
        category: category,
        emoji: emoji.emoji,
        description: emoji.name,
        tags: [],
        unicodeVersion: '',
        variants: _buildVariantsFromPicker(emoji, category),
      );
    }).toList();
  }
}

/// Hash map of all emojis from the emoji_picker_flutter package.
///
/// The key is the Emoji, and the value is the category.
Map<emoji_picker.Emoji, emoji_picker.Category> _pickerEmojis = {};

/// Builds the emoji set from the emoji_picker_flutter package.
Map<EmojiCategory, List<Emoji>> _buildEmojisFromPickerPackage() {
  const pickerEmojiCategories = emoji_picker.defaultEmojiSet;
  final Map<EmojiCategory, List<Emoji>> emojiMap = {};

  for (final emojiCategory in pickerEmojiCategories) {
    final EmojiCategory category = emojiCategory.category.toEmojiCategory();
    final pickerEmojis = emojiCategory.emoji;
    final List<Emoji> emojiList = [];

    for (final emoji in pickerEmojis) {
      final List<Emoji>? variants = _buildVariantsFromPicker(emoji, category);

      emojiList.add(
        Emoji(
          aliases: [],
          category: category,
          emoji: emoji.emoji,
          description: emoji.name,
          tags: [],
          unicodeVersion: '',
          variants: variants,
        ),
      );

      _pickerEmojis[emoji] = emojiCategory.category;
    }

    emojiMap[category] = emojiList;
  }

  return emojiMap;
}

/// Returns a list of [Emoji]s that are variants of the emoji passed in.
///
/// The [emoji] can be either our own [Emoji] class or the one from the
/// emoji_picker_flutter package.
///
/// If the [emoji] does not have any variants, returns `null`.
List<Emoji>? buildVariants({
  Emoji? emoji,
  emoji_picker.Emoji? pickerEmoji,
  required EmojiCategory category,
}) {
  if (emoji != null) {
    return _buildVariantsFromOurEmoji(emoji, category);
  } else if (pickerEmoji != null) {
    return _buildVariantsFromPicker(pickerEmoji, category);
  } else {
    return null;
  }
}

/// Builds emoji variants from our own Emoji class.
List<Emoji>? _buildVariantsFromOurEmoji(Emoji emoji, EmojiCategory category) {
  final emoji_picker.Emoji? pickerEmoji = emoji.toPickerEmoji();
  if (pickerEmoji == null) return null;
  return _buildVariantsFromPicker(pickerEmoji, category);
}

/// Builds emoji variants from the emoji_picker_flutter package.
List<Emoji>? _buildVariantsFromPicker(
  emoji_picker.Emoji emoji,
  EmojiCategory category,
) {
  if (!emoji.hasSkinTone) return null;

  return emoji_picker.SkinTone.values
      .map((skinTone) => Emoji(
            aliases: [],
            category: category,
            emoji: emoji_picker.EmojiPickerUtils()
                .applySkinTone(emoji, skinTone)
                .emoji,
            description: emoji.name,
            tags: [],
            unicodeVersion: '',
          ))
      .toList();
}

extension PickerCategoryHelper on emoji_picker.Category {
  EmojiCategory toEmojiCategory() {
    switch (this) {
      case emoji_picker.Category.SMILEYS:
        return EmojiCategory.smileys;
      case emoji_picker.Category.ANIMALS:
        return EmojiCategory.animalsAndNature;
      case emoji_picker.Category.FOODS:
        return EmojiCategory.foodAndDrink;
      case emoji_picker.Category.TRAVEL:
        return EmojiCategory.travelAndPlaces;
      case emoji_picker.Category.ACTIVITIES:
        return EmojiCategory.activities;
      case emoji_picker.Category.OBJECTS:
        return EmojiCategory.objects;
      case emoji_picker.Category.SYMBOLS:
        return EmojiCategory.symbols;
      case emoji_picker.Category.FLAGS:
        return EmojiCategory.flags;
      default:
        return EmojiCategory.smileys;
    }
  }
}

extension EmojiCategoryHelper on EmojiCategory {
  emoji_picker.Category toPickerCategory() {
    switch (this) {
      case EmojiCategory.smileys:
        return emoji_picker.Category.SMILEYS;
      case EmojiCategory.animalsAndNature:
        return emoji_picker.Category.ANIMALS;
      case EmojiCategory.foodAndDrink:
        return emoji_picker.Category.FOODS;
      case EmojiCategory.travelAndPlaces:
        return emoji_picker.Category.TRAVEL;
      case EmojiCategory.activities:
        return emoji_picker.Category.ACTIVITIES;
      case EmojiCategory.objects:
        return emoji_picker.Category.OBJECTS;
      case EmojiCategory.symbols:
        return emoji_picker.Category.SYMBOLS;
      case EmojiCategory.flags:
        return emoji_picker.Category.FLAGS;
      default:
        return emoji_picker.Category.SMILEYS;
    }
  }
}

extension EmojiHelper on Emoji {
  emoji_picker.Emoji? toPickerEmoji() {
    for (final emojiCategory in emoji_picker.defaultEmojiSet) {
      for (final emoji in emojiCategory.emoji) {
        if (emoji.emoji == this.emoji) {
          return emoji;
        }
      }
    }

    return null;
  }
}
