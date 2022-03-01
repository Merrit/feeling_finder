import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'emoji_category.dart';

/// Represents an emoji.
///
/// Also contains associated metadata like description and category.
class Emoji extends Equatable {
  /// The actual emoji, for example: 😆
  final String emoji;

  /// The emoji's description from the unicode spec.
  /// Example: "grinning squinting face".
  final String description;

  /// The emoji's category from the unicode spec.
  /// Example: "Smileys & Emotion".
  final EmojiCategory category;

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

  /// Builds an Emoji from the provided [json].
  factory Emoji.fromJson(Map<String, dynamic> json) {
    EmojiCategory _emojiCategory = emojiCategoryFromString(
      json['category'] as String,
    );

    return Emoji(
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      category: _emojiCategory,
      aliases: json['aliases'].cast<String>(),
      tags: json['tags'].cast<String>(),
      unicodeVersion: json['unicode_version'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'description': description,
      'category': category.name,
      'aliases': aliases,
      'tags': tags,
      'unicode_version': unicodeVersion,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  List<Object> get props {
    return [
      emoji,
      description,
      category,
      aliases,
      tags,
      unicodeVersion,
    ];
  }
}
