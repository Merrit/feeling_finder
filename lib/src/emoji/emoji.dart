import 'package:flutter/foundation.dart';

/// Represents an emoji.
///
/// Also contains associated metadata like description and category.
@immutable
class Emoji {
  /// The actual emoji, for example: 😆
  final String emoji;

  /// The emoji's description from the unicode spec.
  /// Example: "grinning squinting face".
  final String description;

  /// The emoji's category from the unicode spec.
  /// Example: "Smileys & Emotion".
  final String category;

  /// A list of strings that also match this emoji from the unicode spec.
  /// Example: ```["laughing", "satisfied"]```.
  final List<String> aliases;

  /// Another list of strings that also match this emoji from the unicode spec.
  /// Example: ```["happy", "haha"]```.
  final List<String> tags;

  /// The emoji's version per the unicode spec.
  /// Example: "6.0".
  final String unicodeVersion;

  const Emoji({
    required this.emoji,
    required this.description,
    required this.category,
    required this.aliases,
    required this.tags,
    required this.unicodeVersion,
  });

  factory Emoji.fromJson(Map<String, dynamic> json) => Emoji(
        emoji: json['emoji'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        aliases: json['aliases'].cast<String>(),
        tags: json['tags'].cast<String>(),
        unicodeVersion: json['unicode_version'] as String,
      );
}
