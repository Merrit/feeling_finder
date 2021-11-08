import 'package:flutter/material.dart';

import '../storage/storage_service.dart';

/// Stores and retrieves user settings.
class SettingsService {
  final StorageService _storageService;

  SettingsService(this._storageService);

  /// Loads the user's preferred ThemeMode from storage.
  Future<ThemeMode> themeMode() async {
    final theme = _storageService.getValue('ThemeMode');
    switch (theme) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        // If the user has not made a choice we follow system theme.
        return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    await _storageService.saveValue(key: 'ThemeMode', value: theme.toString());
  }
}
