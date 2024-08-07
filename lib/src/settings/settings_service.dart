import 'dart:convert';

import 'package:flutter/material.dart';

import '../emoji/emoji.dart';
import '../logs/logging_manager.dart';
import '../storage/storage_service.dart';

/// Stores and retrieves user settings.
class SettingsService {
  final StorageService _storageService;

  SettingsService(this._storageService) {
    instance = this;
  }

  /// Singleton instance of the SettingsService.
  static late SettingsService instance;

  /// Whether the app should continue running in the tray when closed.
  Future<bool> closeToTray() async {
    final closeToTray = _storageService.getValue('closeToTray') as bool?;
    return closeToTray ?? false;
  }

  Future<void> saveCloseToTray(bool value) async {
    await _storageService.saveValue(key: 'closeToTray', value: value);
  }

  bool exitOnCopy() {
    final shouldExit = _storageService.getValue('exitOnCopy') as bool?;
    return shouldExit ?? false;
  }

  Future<void> saveExitOnCopy(bool value) async {
    await _storageService.saveValue(key: 'exitOnCopy', value: value);
  }

  bool hideOnCopy() {
    final shouldHide = _storageService.getValue('hideOnCopy') as bool?;
    return shouldHide ?? false;
  }

  Future<void> saveHideOnCopy(bool value) async {
    await _storageService.saveValue(key: 'hideOnCopy', value: value);
  }

  bool hotKeyEnabled() {
    final useHotKey = _storageService.getValue('useHotKey') as bool?;
    return useHotKey ?? false;
  }

  Future<void> saveHotKeyEnabled(bool value) async {
    await _storageService.saveValue(key: 'useHotKey', value: value);
  }

  /// In-memory variable for the recent emojis list.
  final List<Emoji> _recentEmojis = [];

  /// Loads the list of recent emojis from storage.
  List<Emoji> recentEmojis() {
    if (_recentEmojis.isNotEmpty) return _recentEmojis;

    final emojisJsonString = _storageService.getValue('recentEmojis');

    if (emojisJsonString == null) return [];

    if (emojisJsonString is! String) {
      log.e('Recent emojis from storage not valid');
      clearRecentEmojis();
      return [];
    }

    final emojiMapsList = jsonDecode(emojisJsonString) as List<dynamic>;

    for (var emojiJson in emojiMapsList) {
      try {
        final emoji = Emoji.fromJson(emojiJson);
        _recentEmojis.add(emoji);
      } catch (e) {
        log.e('Recent emoji from storage not valid', error: e);
        clearRecentEmojis();
      }
    }
    return _recentEmojis;
  }

  /// Remove an emoji from the recents list.
  Future<void> removeRecentEmoji(Emoji emoji) async {
    _recentEmojis.remove(emoji);
    final emojiMapList = _recentEmojis.map((e) => e.toJson()).toList();
    await _storageService.saveValue(
      key: 'recentEmojis',
      value: jsonEncode(emojiMapList),
    );
  }

  /// Replace the list of recent emojis with a new list.
  Future<void> setRecentEmojis(List<Emoji> emojis) async {
    _recentEmojis.clear();
    _recentEmojis.addAll(emojis);
    final emojiMapList = _recentEmojis.map((e) => e.toJson()).toList();
    await _storageService.saveValue(
      key: 'recentEmojis',
      value: jsonEncode(emojiMapList),
    );
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
    final emojiMapList = _recentEmojis.map((e) => e.toJson()).toList();
    await _storageService.saveValue(
      key: 'recentEmojis',
      value: jsonEncode(emojiMapList),
    );
  }

  /// Save whether the system tray icon should be shown.
  Future<void> saveShowSystemTrayIcon(bool value) async {
    await _storageService.saveValue(key: 'showSystemTrayIcon', value: value);
  }

  /// Whether the system tray icon should be shown.
  bool showSystemTrayIcon() {
    final showSystemTrayIcon = _storageService.getValue('showSystemTrayIcon') as bool?;
    return showSystemTrayIcon ?? true;
  }

  bool startHiddenInTray() {
    final startHidden = _storageService.getValue('startHiddenInTray') as bool?;
    return startHidden ?? false;
  }

  Future<void> saveStartHiddenInTray(bool value) async {
    await _storageService.saveValue(key: 'startHiddenInTray', value: value);
  }

  /// Remove all emojis from the recents list.
  Future<void> clearRecentEmojis() async {
    _recentEmojis.clear();
    await _storageService.deleteValue('recentEmojis');
  }

  /// Loads the user's preferred ThemeMode from storage.
  Future<ThemeMode> themeMode() async {
    final theme = _storageService.getValue('ThemeMode') as String?;
    switch (theme) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    await _storageService.saveValue(key: 'ThemeMode', value: theme.toString());
  }
}
