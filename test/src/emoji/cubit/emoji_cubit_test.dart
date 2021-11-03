import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji.json.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EmojiCubit emojiCubit;

  setUpAll(() {
    final emojiService = EmojiService(emojiJson);
    emojiCubit = EmojiCubit(emojiService);
  });
  test('emojiState has populated emojis', () {
    expect(emojiCubit.state.emojis, isNotEmpty);
  });

  test('emojiState initial category is All', () {
    expect(emojiCubit.state.category, EmojiCategory.all);
  });

  test('setCategory(), then emojiState category has changed', () {
    expect(emojiCubit.state.category, EmojiCategory.all);
    emojiCubit.setCategory(EmojiCategory.foodAndDrink);
    expect(emojiCubit.state.category, EmojiCategory.foodAndDrink);
  });
}
