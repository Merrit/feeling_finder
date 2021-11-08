import 'package:feeling_finder/src/clipboard/clipboard_service.dart';
import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji.json.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClipboardService extends Mock implements ClipboardService {}

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  final clipboardService = MockClipboardService();
  final settingsService = MockSettingsService();

  late EmojiCubit emojiCubit;

  setUpAll(() {
    // Return no recent emojis.
    when(settingsService.recentEmojis).thenReturn([]);
    final emojiService = EmojiService(emojiJson);
    emojiCubit = EmojiCubit(
      clipboardService,
      emojiService,
      settingsService,
    );
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
