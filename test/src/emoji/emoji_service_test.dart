import 'package:feeling_finder/src/emoji/emoji.json.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EmojiService emojiService;

  setUpAll(() {
    emojiService = EmojiService(emojiJson);
  });

  test('allEmojis() returns a list of all emojis', () {
    // Get the list of emojis.
    final emojis = emojiService.allEmojis();

    // Verify it has returned all emojis.
    //
    // At least approximately all of them -- we don't want to hard-code an
    // absolute number, so when new emojis are added the test will still pass.
    expect(emojis.length, greaterThan(1800));
  });

  test('emojisByCategory() returns only emojis belonging to requested category',
      () {
    // Get the list of emojis.
    final emojis = emojiService.emojisByCategory(EmojiCategory.foodAndDrink);

    // Verify the list was populated.
    expect(emojis.length, greaterThan(100));

    // Verify it contains only emojis from the Food & Drink category.
    final otherCategoryEmojis = emojis
        .where(
            (element) => element.category != EmojiCategory.foodAndDrink.value)
        .toList();
    expect(otherCategoryEmojis, isEmpty);
  });
}
