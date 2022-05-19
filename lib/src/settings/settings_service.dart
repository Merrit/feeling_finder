import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_flatpak/flutter_flatpak.dart';

import '../emoji/emoji.dart';
import '../storage/storage_service.dart';

/// Stores and retrieves user settings.
class SettingsService {
  final StorageService _storageService;

  SettingsService(this._storageService);

  bool exitOnCopy() {
    final shouldExit = _storageService.getValue('exitOnCopy') as bool?;
    return shouldExit ?? false;
  }

  Future<void> saveExitOnCopy(bool value) async {
    await _storageService.saveValue(key: 'exitOnCopy', value: value);
  }

  /// In-memory variable for the recent emojis list.
  final List<Emoji> _recentEmojis = [];

  /// Loads the list of recent emojis from storage.
  List<Emoji> recentEmojis() {
    if (_recentEmojis.isNotEmpty) return _recentEmojis;
    final emojiStringList = _storageService.getValue(
      'recentEmojis',
    );
    if (emojiStringList == null) return [];
    if (emojiStringList.isEmpty) return [];
    for (var emojiJson in emojiStringList as List<dynamic>) {
      try {
        final emojiMap = json.decode(emojiJson);
        final emoji = Emoji.fromJson(emojiMap);
        _recentEmojis.add(emoji);
      } catch (e) {
        debugPrint('Recent emoji from storage not valid: $e');
        clearRecentEmojis();
      }
    }
    return _recentEmojis;
  }

  /// Updates the list of recent emojis in storage.
  Future<void> saveRecentEmoji(Emoji emoji) async {
    if (_recentEmojis.contains(emoji)) {
      // Don't add duplicates.
      // Remove & re-add so it becomes the most recent.
      _recentEmojis.remove(emoji);
    }
    if (_recentEmojis.length == 20) _recentEmojis.removeLast();
    _recentEmojis.insert(0, emoji);
    final emojiStringList = _recentEmojis.map((e) => e.toJson()).toList();
    await _storageService.saveValue(
      key: 'recentEmojis',
      value: emojiStringList,
    );
  }

  /// Remove all emojis from the recents list.
  Future<void> clearRecentEmojis() async {
    await _storageService.saveValue(key: 'recentEmojis', value: []);
  }

  /// Loads the user's preferred ThemeMode from storage.
  Future<ThemeMode> themeMode() async {
    final theme = _storageService.getValue('ThemeMode');
    switch (theme) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        final Flatpak? flatpak = await Flatpak.init();

        ThemeMode themeMode;
        if (flatpak != null) {
          /// If the app is running in Flatpak we check the system theme
          /// through the `flutter_flatpak` package.
          themeMode = flatpak.themeMode;
        } else {
          /// If the user has not specified a specific theme for
          /// the app we follow the system theme.
          themeMode = ThemeMode.system;
        }

        return themeMode;
    }
  }

  /// Persists the user's preferred ThemeMode to storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    await _storageService.saveValue(key: 'ThemeMode', value: theme.toString());
  }
}
