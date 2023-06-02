import 'dart:convert';

import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:feeling_finder/src/emoji/emoji_category.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:feeling_finder/src/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<StorageService>()])
import 'settings_service_test.mocks.dart';

Future<void> main() async {
  group('SettingsService:', () {
    late MockStorageService mockStorageService;
    late SettingsService settingsService;

    setUpAll(() async {
      await LoggingManager.initialize(verbose: false);
    });

    setUp(() {
      mockStorageService = MockStorageService();
      settingsService = SettingsService(mockStorageService);
    });

    test('clearRecentEmojis', () async {
      await settingsService.clearRecentEmojis();
      verify(mockStorageService.deleteValue('recentEmojis'));
      final recentEmojis = settingsService.recentEmojis();
      expect(recentEmojis.length, 0);
    });

    test('exitOnCopy', () {
      when(mockStorageService.getValue('exitOnCopy')).thenReturn(true);
      expect(settingsService.exitOnCopy(), true);
    });

    test('recentEmojis', () {
      when(mockStorageService.getValue('recentEmojis')).thenReturn(
        jsonEncode([
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
        ]),
      );
      expect(settingsService.recentEmojis().length, 2);
    });

    test('saveExitOnCopy', () async {
      await settingsService.saveExitOnCopy(true);
      verify(mockStorageService.saveValue(key: 'exitOnCopy', value: true));
    });

    test('setRecentEmojis', () async {
      final List<Emoji> emojis = [
        const Emoji(
          aliases: ['smile'],
          category: EmojiCategory.smileys,
          emoji: '😄',
          name: 'grinning face with smiling eyes',
          tags: ['happy', 'joy', 'pleased'],
          unicodeVersion: '6.0',
        ),
        const Emoji(
          aliases: ['blue_heart'],
          category: EmojiCategory.symbols,
          emoji: '💙',
          name: 'blue heart',
          tags: ['love'],
          unicodeVersion: '6.0',
        ),
        const Emoji(
          aliases: ['fox'],
          category: EmojiCategory.animalsAndNature,
          emoji: '🦊',
          name: 'fox face',
          tags: ['animal', 'nature'],
          unicodeVersion: '6.0',
        ),
        const Emoji(
          aliases: ['whale'],
          category: EmojiCategory.animalsAndNature,
          emoji: '🐳',
          name: 'spouting whale',
          tags: ['animal', 'nature', 'sea'],
          unicodeVersion: '6.0',
        ),
      ];

      when(mockStorageService.getValue('recentEmojis')).thenReturn(
        jsonEncode(emojis.map((e) => e.toJson()).toList()),
      );
      List<Emoji> recentEmojis = settingsService.recentEmojis();
      expect(recentEmojis.length, 4);
      expect(recentEmojis[0].emoji, '😄');
      expect(recentEmojis[1].emoji, '💙');
      expect(recentEmojis[2].emoji, '🦊');
      expect(recentEmojis[3].emoji, '🐳');

      emojis.removeAt(1);
      await settingsService.setRecentEmojis(emojis);
      recentEmojis = settingsService.recentEmojis();
      expect(recentEmojis.length, 3);
      expect(recentEmojis[0].emoji, '😄');
      expect(recentEmojis[1].emoji, '🦊');
      expect(recentEmojis[2].emoji, '🐳');
    });
  });
}
