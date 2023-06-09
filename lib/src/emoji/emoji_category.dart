import 'package:flutter/material.dart';

import '../localization/gen/app_localizations.dart';

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
        name = AppLocalizations.of(context)!.emojiCategoryRecent;
        break;
      case EmojiCategory.smileys:
        name = AppLocalizations.of(context)!.emojiCategorySmileys;
        break;
      case EmojiCategory.peopleAndBody:
        name = AppLocalizations.of(context)!.emojiCategoryPeopleAndBody;
        break;
      case EmojiCategory.animalsAndNature:
        name = AppLocalizations.of(context)!.emojiCategoryAnimalsAndNature;
        break;
      case EmojiCategory.foodAndDrink:
        name = AppLocalizations.of(context)!.emojiCategoryFoodAndDrink;
        break;
      case EmojiCategory.travelAndPlaces:
        name = AppLocalizations.of(context)!.emojiCategoryTravelAndPlaces;
        break;
      case EmojiCategory.activities:
        name = AppLocalizations.of(context)!.emojiCategoryActivities;
        break;
      case EmojiCategory.objects:
        name = AppLocalizations.of(context)!.emojiCategoryObjects;
        break;
      case EmojiCategory.symbols:
        name = AppLocalizations.of(context)!.emojiCategorySymbols;
        break;
      case EmojiCategory.flags:
        name = AppLocalizations.of(context)!.emojiCategoryFlags;
        break;
      case EmojiCategory.custom:
        name = AppLocalizations.of(context)!.emojiCategoryCustom;
        break;
    }
    return name;
  }
}
