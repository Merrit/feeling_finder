import 'package:flutter/material.dart';
import '../i18n/strings.g.dart';

/// Top-level categories for emojis.
enum EmojiCategory {
  /// Recently used emojis.
  recent('Recent'),

  smileys('Smileys & Emotion'),
  peopleAndBody('People & Body'),
  animalsAndNature('Animals & Nature'),
  foodAndDrink('Food & Drink'),
  travelAndPlaces('Travel & Places'),
  activities('Activities'),
  objects('Objects'),
  symbols('Symbols'),
  flags('Flags'),

  /// User-defined custom emojis.
  custom('Custom');

  /// The human-readable category name.
  final String description;

  const EmojiCategory(this.description);

  /// The translated, human-readable category name.
  ///
  /// Example: English -> `Animals & Nature`, German -> `Tiere & Natur`.
  String localizedName(BuildContext context) {
    String name;
    switch (this) {
      case EmojiCategory.recent:
        name = t.emojiCategories.recent;
        break;
      case EmojiCategory.smileys:
        name = t.emojiCategories.smileys;
        break;
      case EmojiCategory.peopleAndBody:
        name = t.emojiCategories.peopleAndBody;
        break;
      case EmojiCategory.animalsAndNature:
        name = t.emojiCategories.animalsAndNature;
        break;
      case EmojiCategory.foodAndDrink:
        name = t.emojiCategories.foodAndDrink;
        break;
      case EmojiCategory.travelAndPlaces:
        name = t.emojiCategories.travelAndPlaces;
        break;
      case EmojiCategory.activities:
        name = t.emojiCategories.activities;
        break;
      case EmojiCategory.objects:
        name = t.emojiCategories.objects;
        break;
      case EmojiCategory.symbols:
        name = t.emojiCategories.symbols;
        break;
      case EmojiCategory.flags:
        name = t.emojiCategories.flags;
        break;
      case EmojiCategory.custom:
        name = t.emojiCategories.custom;
        break;
    }
    return name;
  }
}
