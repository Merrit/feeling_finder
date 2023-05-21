import 'package:freezed_annotation/freezed_annotation.dart';

import 'emoji_category.dart';

part 'emoji.freezed.dart';
part 'emoji.g.dart';

/// Represents an emoji.
///
/// Also contains associated metadata like description and category.
@freezed
class Emoji with _$Emoji {
  const factory Emoji({
    /// A list of strings that also match this emoji from the unicode spec.
    /// Example: ```["laughing", "satisfied"]```.
    required List<String> aliases,

    /// The emoji's category from the unicode spec.
    /// Example: "Smileys & Emotion".
    required EmojiCategory category,

    /// The emoji's description from the unicode spec.
    /// Example: "grinning squinting face".
    required String description,

    /// The actual emoji, for example: 😆
    required String emoji,

    /// Another list of strings that also match this emoji from the unicode spec.
    /// Example: ```["happy", "haha"]```.
    required List<String> tags,

    /// The emoji's version per the unicode spec.
    /// Example: "6.0".
    required String unicodeVersion,

    /// A list of other emojis that are variations of this emoji.
    List<Emoji>? variants,
  }) = _Emoji;

  factory Emoji.fromJson(Map<String, dynamic> json) => _$EmojiFromJson(json);
}
