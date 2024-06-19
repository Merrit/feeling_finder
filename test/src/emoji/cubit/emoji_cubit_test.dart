import 'dart:convert';

import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:feeling_finder/src/settings/cubit/settings_cubit.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:feeling_finder/src/storage/storage_service.dart';
import 'package:feeling_finder/src/window/app_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'emoji_cubit_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AppWindow>(),
  MockSpec<SettingsCubit>(),
  MockSpec<StorageService>(),
])
void main() {
  group('EmojiCubit', () {
    late MockAppWindow appWindow;
    late MockSettingsCubit settingsCubit;
    late MockStorageService storageService;
    late SettingsService settingsService;
    late EmojiService emojiService;
    late EmojiCubit emojiCubit;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await LoggingManager.initialize(verbose: false);

      appWindow = MockAppWindow();
      when(appWindow.isFocused()).thenAnswer((_) async => true);
      when(appWindow.hide()).thenAnswer((_) async {});
      when(appWindow.show()).thenAnswer((_) async {});

      settingsCubit = MockSettingsCubit();
      when(settingsCubit.state).thenReturn(const SettingsState(
        closeToTray: false,
        exitOnCopy: false,
        hotKeyEnabled: false,
        showSystemTrayIcon: false,
        themeMode: ThemeMode.system,
        userThemePreference: ThemeMode.dark,
      ));

      emojiService = EmojiService();
    });

    setUp(() {
      storageService = MockStorageService();
      settingsService = SettingsService(storageService);

      // Return no recent emojis.
      when(storageService.getValue('recentEmojis')).thenReturn(null);
    });
    test('has emojis', () {
      emojiCubit = EmojiCubit(
        appWindow,
        emojiService,
        settingsCubit,
        settingsService,
        storageService,
      );
      expect(emojiCubit.state.emojis, isNotEmpty);
    });

    test('initial category is Smileys & Emotion', () {
      emojiCubit = EmojiCubit(
        appWindow,
        emojiService,
        settingsCubit,
        settingsService,
        storageService,
      );
      expect(emojiCubit.state.category, EmojiCategory.smileys);
    });

    test('recent emojis is empty', () {
      emojiCubit = EmojiCubit(
        appWindow,
        emojiService,
        settingsCubit,
        settingsService,
        storageService,
      );
      expect(emojiCubit.state.category, EmojiCategory.smileys);
      expect(emojiCubit.state.emojis.length > 170, true);
      expect(emojiCubit.state.haveRecentEmojis, false);
    });

    test('recent emojis are populated when found in storage', () {
      final json = jsonEncode([
        {
          'aliases': ['smile'],
          'category': EmojiCategory.smileys.name,
          'emoji': '😄',
          'name': 'grinning face with smiling eyes',
          'tags': ['happy', 'joy', 'pleased'],
          'unicodeVersion': '6.0',
        },
        {
          'aliases': ['fox'],
          'category': EmojiCategory.animalsAndNature.name,
          'emoji': '🦊',
          'name': 'fox face',
          'tags': ['animal', 'nature'],
          'unicodeVersion': '6.0',
        },
      ]);

      when(storageService.getValue('recentEmojis')).thenReturn(json);

      emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(),
        settingsCubit,
        settingsService,
        storageService,
      );

      expect(emojiCubit.state.category, EmojiCategory.recent);
      expect(emojiCubit.state.emojis.length, 2);
      expect(emojiCubit.state.emojis[0].emoji, '😄');
      expect(emojiCubit.state.emojis[1].emoji, '🦊');
    });

    test('removeCustomEmoji', () async {
      final json = jsonEncode([
        {
          'aliases': ['smile'],
          'category': EmojiCategory.smileys.name,
          'emoji': '😄',
          'name': 'grinning face with smiling eyes',
          'tags': ['happy', 'joy', 'pleased'],
          'unicodeVersion': '6.0',
        },
        {
          'aliases': ['fox'],
          'category': EmojiCategory.animalsAndNature.name,
          'emoji': '🦊',
          'name': 'fox face',
          'tags': ['animal', 'nature'],
          'unicodeVersion': '6.0',
        },
      ]);

      when(storageService.getValue('recentEmojis')).thenReturn(json);

      emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(),
        settingsCubit,
        settingsService,
        storageService,
      );

      expect(emojiCubit.state.category, EmojiCategory.recent);
      expect(emojiCubit.state.emojis.length, 2);
      expect(emojiCubit.state.emojis[0].emoji, '😄');
      expect(emojiCubit.state.emojis[1].emoji, '🦊');

      when(storageService.getValue('customEmojis')).thenReturn(null);
      emojiCubit.setCategory(EmojiCategory.custom);
      expect(emojiCubit.state.emojis.length, 0);

      const customEmoji = Emoji(
        aliases: ['custom'],
        category: EmojiCategory.custom,
        emoji: '(╯°□°)╯︵ ┻━┻',
        name: '(╯°□°)╯︵ ┻━┻',
        tags: ['custom'],
        unicodeVersion: '0.0',
      );

      await emojiCubit.addCustomEmoji(customEmoji.emoji);
      when(storageService.getValue('customEmojis')).thenReturn(
        [jsonEncode(customEmoji.toJson())],
      );
      expect(emojiCubit.state.emojis.length, 1);
      expect(emojiCubit.state.emojis[0].emoji, customEmoji.emoji);
      await emojiCubit.userSelectedEmoji(customEmoji);
      emojiCubit.setCategory(EmojiCategory.recent);
      expect(emojiCubit.state.emojis.length, 3);
      expect(emojiCubit.state.emojis[0].emoji, '(╯°□°)╯︵ ┻━┻');
      expect(emojiCubit.state.emojis[1].emoji, '😄');
      expect(emojiCubit.state.emojis[2].emoji, '🦊');
      emojiCubit.setCategory(EmojiCategory.custom);
      await emojiCubit.removeCustomEmoji(customEmoji);
      emojiCubit.setCategory(EmojiCategory.recent);
      expect(emojiCubit.state.emojis.length, 2);
      expect(emojiCubit.state.emojis[0].emoji, '😄');
      expect(emojiCubit.state.emojis[1].emoji, '🦊');
    });

    test('setCategory(), then category has changed', () {
      emojiCubit = EmojiCubit(
        appWindow,
        emojiService,
        settingsCubit,
        settingsService,
        storageService,
      );
      expect(emojiCubit.state.category, EmojiCategory.smileys);
      emojiCubit.setCategory(EmojiCategory.foodAndDrink);
      expect(emojiCubit.state.category, EmojiCategory.foodAndDrink);
    });
  });
}
