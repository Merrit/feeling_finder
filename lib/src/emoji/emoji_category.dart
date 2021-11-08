enum EmojiCategory {
  recent,
  all,
  smileys,
  peopleAndBody,
  animalsAndNature,
  foodAndDrink,
  travelAndPlaces,
  activities,
  objects,
  symbols,
  flags,
}

/// Dart doesn't yet support values for enums:
/// https://github.com/dart-lang/language/issues/158
///
/// Use extension on enum as solution to retrieve string values.
///
/// These string values are the human-readable emoji categories.
extension EmojiCategoryHelper on EmojiCategory {
  String get value {
    switch (this) {
      case EmojiCategory.recent:
        return 'Recent';
      case EmojiCategory.all:
        return 'All';
      case EmojiCategory.smileys:
        return 'Smileys & Emotion';
      case EmojiCategory.peopleAndBody:
        return 'People & Body';
      case EmojiCategory.animalsAndNature:
        return 'Animals & Nature';
      case EmojiCategory.foodAndDrink:
        return 'Food & Drink';
      case EmojiCategory.travelAndPlaces:
        return 'Travel & Places';
      case EmojiCategory.activities:
        return 'Activities';
      case EmojiCategory.objects:
        return 'Objects';
      case EmojiCategory.symbols:
        return 'Symbols';
      case EmojiCategory.flags:
        return 'Flags';
      default:
        return 'All';
    }
  }
}
