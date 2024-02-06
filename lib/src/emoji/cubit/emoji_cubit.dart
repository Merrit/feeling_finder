import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../logs/logging_manager.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/settings_service.dart';
import '../../shortcuts/app_hotkey.dart';
import '../../storage/storage_service.dart';
import '../../window/app_window.dart';
import '../emoji.dart';
import '../emoji_category.dart';
import '../emoji_service.dart';

part 'emoji_cubit.freezed.dart';
part 'emoji_state.dart';

/// Controls the state of [EmojiPage] and connects the
/// view to the [EmojiService].
class EmojiCubit extends Cubit<EmojiState> {
  final AppWindow? _appWindow;
  final EmojiService _emojiService;
  final SettingsCubit _settingsCubit;
  final SettingsService _settingsService;
  final StorageService _storageService;

  EmojiCubit(
    this._appWindow,
    this._emojiService,
    this._settingsCubit,
    this._settingsService,
    this._storageService,
  ) : super(EmojiState.initial(
          _settingsService.recentEmojis(),
          _emojiService.emojisByCategory(EmojiCategory.smileys),
        )) {
    instance = this;
  }

  /// Singleton instance of the EmojiCubit.
  static late EmojiCubit instance;

  /// Add a custom emoji to the list of custom emojis.
  Future<void> addCustomEmoji(String emojiString) async {
    final customEmojis = _storageService //
            .getValue('customEmojis') as List<String>? ??
        [];

    final emoji = Emoji(
      aliases: ['custom'],
      category: EmojiCategory.custom,
      emoji: emojiString,
      name: emojiString,
      tags: ['custom'],
      unicodeVersion: '0.0',
    );

    customEmojis.add(jsonEncode(emoji.toJson()));

    await _storageService.saveValue(
      key: 'customEmojis',
      value: customEmojis,
    );

    emit(state.copyWith(
      emojis: [...state.emojis, emoji],
    ));
  }

  /// Clear the list of recent emojis.
  Future<void> clearRecentEmojis() async {
    await _settingsService.clearRecentEmojis();

    if (state.category == EmojiCategory.recent) {
      setCategory(EmojiCategory.smileys);
    }

    emit(state.copyWith(
      haveRecentEmojis: false,
    ));
  }

  /// Search and filter for all emojis that match [searchString].
  Future<void> search(String keyword) async {
    if (keyword.isEmpty) {
      // Keyword is empty when the user clears the search field, so we
      // reset the list of emojis to the current category.
      setCategory(state.category);
      emit(state.copyWith(isSearching: false));
      return;
    }

    emit(state.copyWith(
      emojis: _emojiService.search(keyword),
      isSearching: true,
    ));
  }

  /// Sets the list of loaded emojis to the requested [category].
  void setCategory(EmojiCategory category) {
    List<Emoji> emojis;
    if (category == EmojiCategory.recent) {
      emojis = _settingsService.recentEmojis();
    } else if (category == EmojiCategory.custom) {
      final customEmojis = _storageService //
          .getValue('customEmojis') as List<String>?;
      emojis = customEmojis //
              ?.map((e) => Emoji.fromJson(jsonDecode(e)))
              .toList() ??
          [];
    } else {
      emojis = _emojiService.emojisByCategory(category);
    }

    emit(state.copyWith(
      category: category,
      emojis: emojis,
    ));
  }

  /// Sets the category to the next one in the list.
  ///
  /// If the current category is the last one, it will loop back to the first.
  void nextCategory() {
    // If _settingsService.recentEmojis() is empty, then the recent category
    // will not be shown, so we need to offset the index by 1.
    final bool haveRecentEmojis = _settingsService.recentEmojis().isNotEmpty;
    int nextCategoryIndex = state.category.index + 1;
    if (nextCategoryIndex >= EmojiCategory.values.length) {
      nextCategoryIndex = (haveRecentEmojis) ? 0 : 1;
    }
    setCategory(EmojiCategory.values[nextCategoryIndex]);
  }

  /// Sets the category to the previous one in the list.
  ///
  /// If the current category is the first one, it will loop back to the last.
  void previousCategory() {
    // If _settingsService.recentEmojis() is empty, then the recent category
    // will not be shown, so we need to offset the index by 1.
    final bool haveRecentEmojis = _settingsService.recentEmojis().isNotEmpty;
    int previousCategoryIndex = state.category.index - 1;
    if (previousCategoryIndex == 0 && !haveRecentEmojis || previousCategoryIndex < 0) {
      previousCategoryIndex = EmojiCategory.values.length - 1;
    }
    setCategory(EmojiCategory.values[previousCategoryIndex]);
  }

  /// Remove custom emoji from the list of custom emojis.
  ///
  /// Custom emoji will also be removed from the list of recent emojis.
  Future<void> removeCustomEmoji(Emoji emoji) async {
    final customEmojis = [...state.emojis] //
      ..remove(emoji);

    emit(state.copyWith(emojis: customEmojis));

    await _storageService.saveValue(
      key: 'customEmojis',
      value: customEmojis.map((e) => jsonEncode(e.toJson())).toList(),
    );

    await _settingsService.removeRecentEmoji(emoji);
  }

  /// The user has clicked or tapped an emoji to be copied.
  Future<void> userSelectedEmoji(Emoji emoji) async {
    // Copy emoji to clipboard.
    final clipboardData = ClipboardData(text: emoji.emoji);
    await Clipboard.setData(clipboardData);
    log.i('Copied emoji to clipboard: ${emoji.emoji}');

    final updatedClipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (updatedClipboard == null || updatedClipboard.text != emoji.emoji) {
      log.e('Failed to copy to clipboard.\n'
          'Expected: ${emoji.emoji}\n'
          'Actual: ${updatedClipboard?.text}');
    }

    // Check if the preference to exit on copy is set.
    final shouldExitApp = _settingsCubit.state.exitOnCopy;

    if (!shouldExitApp) {
      // Trigger copy notification.
      // We don't want to bother if the app will be closing immediately.
      emit(state.copyWith(copiedEmoji: emoji.emoji));
    }

    // Update the list of recent emojis.
    await _settingsService.saveRecentEmoji(emoji);

    // Exit the app if the preference for that is true.
    if (shouldExitApp) {
      // Hide the window because it has a small delay before closing to
      // allow the logger to finish writing to the file.
      await _appWindow?.hide();
      log.i('Exiting app after copying emoji');
      await LoggingManager.instance.close();
      await hotKeyService.unregisterBindings();
      exit(0);
    }
  }
}
