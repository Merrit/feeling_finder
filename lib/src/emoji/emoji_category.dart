import 'package:flutter/material.dart';
import '../localization/strings.g.dart';

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
  String localizedName() {
    String name;
    switch (this) {
      case EmojiCategory.recent:
        name = translations.emojiCategories.recent;
        break;
      case EmojiCategory.smileys:
        name = translations.emojiCategories.smileys;
        break;
      case EmojiCategory.peopleAndBody:
        name = translations.emojiCategories.peopleAndBody;
        break;
      case EmojiCategory.animalsAndNature:
        name = translations.emojiCategories.animalsAndNature;
        break;
      case EmojiCategory.foodAndDrink:
        name = translations.emojiCategories.foodAndDrink;
        break;
      case EmojiCategory.travelAndPlaces:
        name = translations.emojiCategories.travelAndPlaces;
        break;
      case EmojiCategory.activities:
        name = translations.emojiCategories.activities;
        break;
      case EmojiCategory.objects:
        name = translations.emojiCategories.objects;
        break;
      case EmojiCategory.symbols:
        name = translations.emojiCategories.symbols;
        break;
      case EmojiCategory.flags:
        name = translations.emojiCategories.flags;
        break;
      case EmojiCategory.custom:
        name = translations.emojiCategories.custom;
        break;
    }
    return name;
  }
}
