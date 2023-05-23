import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmojiService: ', () {
    final emojiService = EmojiService();

    test('allEmojis has 8 categories', () {
      expect(emojiService.allEmojis.length, 8);
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

    test('search() finds apropriate emojis', () async {
      final matches = await emojiService.search('wav');

      expect(matches, [
        const Emoji(
          emoji: '👋',
          description: 'Waving Hand',
          category: EmojiCategory.smileys,
          aliases: [],
          tags: [],
          unicodeVersion: '',
          variants: [
            Emoji(
              emoji: '👋🏻',
              description: 'Waving Hand',
              category: EmojiCategory.smileys,
              aliases: [],
              tags: [],
              unicodeVersion: '',
            ),
            Emoji(
              emoji: '👋🏼',
              description: 'Waving Hand',
              category: EmojiCategory.smileys,
              aliases: [],
              tags: [],
              unicodeVersion: '',
            ),
            Emoji(
              emoji: '👋🏽',
              description: 'Waving Hand',
              category: EmojiCategory.smileys,
              aliases: [],
              tags: [],
              unicodeVersion: '',
            ),
            Emoji(
              emoji: '👋🏾',
              description: 'Waving Hand',
              category: EmojiCategory.smileys,
              aliases: [],
              tags: [],
              unicodeVersion: '',
            ),
            Emoji(
              emoji: '👋🏿',
              description: 'Waving Hand',
              category: EmojiCategory.smileys,
              aliases: [],
              tags: [],
              unicodeVersion: '',
            ),
          ],
        ),
        const Emoji(
          emoji: '🌊',
          description: 'Water Wave',
          category: EmojiCategory.animalsAndNature,
          aliases: [],
          tags: [],
          unicodeVersion: '',
          variants: null,
        ),
      ]);
    });
  });
}
