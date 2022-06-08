import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji.json.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  MockSettingsService settingsService = MockSettingsService();

  late EmojiCubit emojiCubit;

  group('EmojiCubit', () {
    setUp(() {
      // Return no recent emojis.
      when(settingsService.recentEmojis).thenReturn([]);
      final emojiService = EmojiService(emojiJson);
      emojiCubit = EmojiCubit(
        emojiService,
        settingsService,
      );
    });
    test('has emojis', () {
      expect(emojiCubit.state.emojis, isNotEmpty);
    });

    test('initial category is Smileys & Emotion', () {
      expect(emojiCubit.state.category, EmojiCategory.smileys);
    });

    test('setCategory(), then category has changed', () {
      expect(emojiCubit.state.category, EmojiCategory.smileys);
      emojiCubit.setCategory(EmojiCategory.foodAndDrink);
      expect(emojiCubit.state.category, EmojiCategory.foodAndDrink);
    });
  });
}
