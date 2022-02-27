enum EmojiCategory {
  recente,
  tutto,
  faccine,
  persone e corpo,
  animali e natura,
  cibo e bevande,
  viaggi e luoghi,
  attività,
  oggetti,
  simboli,
  bandiere,
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
        return 'Recente';
      case EmojiCategory.all:
        return 'Tutto';
      case EmojiCategory.smileys:
        return 'Faccine & Emotion';
      case EmojiCategory.peopleAndBody:
        return 'Persone & Corpo';
      case EmojiCategory.animalsAndNature:
        return 'Animali & Natura';
      case EmojiCategory.foodAndDrink:
        return 'Cibo & Bevande';
      case EmojiCategory.travelAndPlaces:
        return 'Viaggi & Luoghi';
      case EmojiCategory.activities:
        return 'Attività';
      case EmojiCategory.objects:
        return 'Oggetti';
      case EmojiCategory.symbols:
        return 'Simboli';
      case EmojiCategory.flags:
        return 'Bandiere';
      default:
        return 'Tutto';
    }
  }
}
