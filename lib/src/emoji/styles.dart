import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';

final TextTheme emojiTextTheme = GoogleFonts.notoColorEmojiTextTheme();

/// It is required to use the emoji font, otherwise emojis
/// all appear as simple black and white glyphs.
final String? emojiFont = (defaultTargetPlatform.isWindows)
    ? null
    : emojiTextTheme.bodyMedium?.fontFamily ?? 'Noto Color Emoji';
