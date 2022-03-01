import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:feeling_finder/src/emoji/emoji.json.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmojiService: ', () {
    final emojiService = EmojiService(emojiJson);

    test('allEmojis has 9 categories', () {
      expect(emojiService.allEmojis.length, 9);
    });

    test(
        'emojisByCategory() returns only emojis belonging to requested category',
        () {
      // Get the list of emojis.
      final emojis = emojiService.emojisByCategory(EmojiCategory.foodAndDrink);

      // Verify the list was populated.
      expect(emojis.length, greaterThan(100));

      // Verify it contains only emojis from the Food & Drink category.
      final otherCategoryEmojis = emojis
          .where((element) => element.category != EmojiCategory.foodAndDrink)
          .toList();
      expect(otherCategoryEmojis, isEmpty);
    });

    test('search() finds apropriate emojis', () {
      final matches = emojiService.search('wave');

      expect(matches, [
        const Emoji(
          emoji: '👋',
          description: 'waving hand',
          category: EmojiCategory.peopleAndBody,
          aliases: ['wave'],
          tags: ['goodbye'],
          unicodeVersion: '6.0',
        ),
        const Emoji(
          emoji: '🌊',
          description: 'water wave',
          category: EmojiCategory.travelAndPlaces,
          aliases: ['ocean'],
          tags: ['sea'],
          unicodeVersion: '6.0',
        ),
      ]);
    });
  });
}
