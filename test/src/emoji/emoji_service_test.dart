import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmojiService: ', () {
    final emojiService = EmojiService();

    test('allEmojis has 9 categories', () {
      expect(emojiService.allEmojis.length, 9);
    });

    test('emojisByCategory() returns only emojis belonging to requested category', () {
      // Get the list of emojis.
      final emojis = emojiService.emojisByCategory(EmojiCategory.foodAndDrink);

      // Verify the list was populated.
      expect(emojis.length, greaterThan(100));

      // Verify it contains only emojis from the Food & Drink category.
      final otherCategoryEmojis = emojis //
          .where((element) => element.category != EmojiCategory.foodAndDrink)
          .toList();
      expect(otherCategoryEmojis, isEmpty);
    });

    test('search() finds apropriate emojis', () {
      final matches = emojiService.search('waving');

      expect(matches, [
        const Emoji(
          emoji: '👋',
          name: 'waving hand sign',
          category: EmojiCategory.peopleAndBody,
          aliases: [],
          tags: [],
          unicodeVersion: '0.6',
          variants: [
            Emoji(
              emoji: '👋🏻',
              name: 'waving hand sign',
              category: EmojiCategory.peopleAndBody,
              aliases: [],
              tags: [],
              unicodeVersion: '0.6',
            ),
            Emoji(
              emoji: '👋🏼',
              name: 'waving hand sign',
              category: EmojiCategory.peopleAndBody,
              aliases: [],
              tags: [],
              unicodeVersion: '0.6',
            ),
            Emoji(
              emoji: '👋🏽',
              name: 'waving hand sign',
              category: EmojiCategory.peopleAndBody,
              aliases: [],
              tags: [],
              unicodeVersion: '0.6',
            ),
            Emoji(
              emoji: '👋🏾',
              name: 'waving hand sign',
              category: EmojiCategory.peopleAndBody,
              aliases: [],
              tags: [],
              unicodeVersion: '0.6',
            ),
            Emoji(
              emoji: '👋🏿',
              name: 'waving hand sign',
              category: EmojiCategory.peopleAndBody,
              aliases: [],
              tags: [],
              unicodeVersion: '0.6',
            ),
          ],
        ),
        const Emoji(
          emoji: '🏴',
          name: 'waving black flag',
          category: EmojiCategory.flags,
          aliases: [],
          tags: [],
          unicodeVersion: '1.0',
        ),
        const Emoji(
          emoji: '🏳️',
          name: 'white flag',
          category: EmojiCategory.flags,
          aliases: [],
          tags: [],
          unicodeVersion: '0.7',
        ),
      ]);
    });
  });
}
