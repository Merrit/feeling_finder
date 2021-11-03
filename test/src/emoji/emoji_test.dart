import 'dart:convert';

import 'package:feeling_finder/src/emoji/emoji.dart';
import 'package:flutter_test/flutter_test.dart';

const emojiJson = '''
{
    "emoji": "😀",
    "description": "grinning face",
    "category": "Smileys & Emotion",
    "aliases": [
        "grinning"
    ],
    "tags": [
        "smile",
        "happy"
    ],
    "unicode_version": "6.1",
    "ios_version": "6.0"
}
''';

void main() {
  test('emoji builds correctly from json', () {
    // Create an emoji object from json.
    final decodedJson = json.decode(emojiJson);
    final emoji = Emoji.fromJson(decodedJson);

    // Verify properties translated correctly.
    expect(emoji.emoji, '😀');
    expect(emoji.description, 'grinning face');
    expect(emoji.category, 'Smileys & Emotion');
    expect(emoji.aliases, <String>['grinning']);
    expect(emoji.tags, ['smile', 'happy']);
    expect(emoji.unicodeVersion, '6.1');
  });
}
