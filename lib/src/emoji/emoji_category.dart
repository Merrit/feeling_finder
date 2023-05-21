import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The various top-level emoji categories.
///
/// `recent` is specific to this app's workings.
enum EmojiCategory {
  recent,
  smileys,
  animalsAndNature,
  foodAndDrink,
  travelAndPlaces,
  activities,
  objects,
  symbols,
  flags,
}

/// Hash map that relates category names from emoji json to their enum values.
const emojiCategoryMap = <String, EmojiCategory>{
  'Recent': EmojiCategory.recent,
  'Smileys & Emotion': EmojiCategory.smileys,
  'Animals & Nature': EmojiCategory.animalsAndNature,
  'Food & Drink': EmojiCategory.foodAndDrink,
  'Travel & Places': EmojiCategory.travelAndPlaces,
  'Activities': EmojiCategory.activities,
  'Objects': EmojiCategory.objects,
  'Symbols': EmojiCategory.symbols,
  'Flags': EmojiCategory.flags,
};

/// Converts the category name from the emoji json into the enum value.
///
/// Example: `Animals & Nature` -> `EmojiCategory.animalsAndNature`.
EmojiCategory emojiCategoryFromString(String emojiString) {
  return emojiCategoryMap[emojiString]!;
}

extension EmojiCategoryHelper on EmojiCategory {
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
    }
    return name;
  }

  /// The original category name from the emoji json, example: `Animals & Nature`.
  String get name => emojiCategoryMap.entries
      .singleWhere((element) => element.value == this)
      .key;
}
