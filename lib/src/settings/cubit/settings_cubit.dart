import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flatpak/flutter_flatpak.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../system_tray/system_tray.dart';
import '../settings_service.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

/// Controls the state of the settings for the app.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;
  final SystemTray? _systemTray;

  SettingsCubit._(
    this._settingsService,
    this._systemTray, {
    required bool closeToTray,
    required bool startHiddenInTray,
    required ThemeMode userThemePreference,
  }) : super(
          SettingsState(
            closeToTray: closeToTray,
            exitOnCopy: _settingsService.exitOnCopy(),
            hideOnCopy: _settingsService.hideOnCopy(),
            hotKeyEnabled: _settingsService.hotKeyEnabled(),
            showSystemTrayIcon: _settingsService.showSystemTrayIcon(),
            startHiddenInTray: startHiddenInTray,
            themeMode: userThemePreference,
            userThemePreference: userThemePreference,
          ),
        ) {
    _listenToFlatpakTheme();

    if (state.showSystemTrayIcon) {
      _systemTray?.show();
    }
  }

  static Future<SettingsCubit> init(
    SettingsService settingsService,
    SystemTray? systemTray,
  ) async {
    final bool closeToTray = await settingsService.closeToTray();
    final bool startHiddenInTray = settingsService.startHiddenInTray();

    return SettingsCubit._(
      settingsService,
      systemTray,
      closeToTray: closeToTray,
      startHiddenInTray: startHiddenInTray,
      userThemePreference: await settingsService.themeMode(),
    );
  }

  StreamSubscription<ThemeMode?>? _flatpakThemeModeStream;

  /// Flatpak apps can't read the system theme, so in the sandbox we
  /// listen to changes from the `Flatpak` package.
  Future<void> _listenToFlatpakTheme() async {
    final ThemeMode userThemePref = await _settingsService.themeMode();
    if (userThemePref != ThemeMode.system) {
      await _flatpakThemeModeStream?.cancel();
      _flatpakThemeModeStream = null;
      return;
    }

    final flatpak = Flatpak.init();
    final systemThemeMode = await flatpak?.systemThemeMode();

    if (systemThemeMode != null) {
      emit(state.copyWith(themeMode: systemThemeMode));
    }

    _flatpakThemeModeStream = flatpak?.themeModeStream.listen((ThemeMode? themeMode) {
      if (themeMode == null) return;

      emit(state.copyWith(themeMode: themeMode));
    });
  }

  Future<void> updateCloseToTray([bool? closeToTray]) async {
    if (closeToTray == null) return;

    await _settingsService.saveCloseToTray(closeToTray);
    emit(state.copyWith(closeToTray: closeToTray));
  }

  /// Update and persist whether the app should exit after copy.
  Future<void> updateExitOnCopy(bool value) async {
    // Only one of the two can be enabled at a time.
    final hideOnCopy = value ? false : state.hideOnCopy;

    emit(state.copyWith(
      exitOnCopy: value,
      hideOnCopy: hideOnCopy,
    ));

    await _settingsService.saveExitOnCopy(value);
    await _settingsService.saveHideOnCopy(hideOnCopy);
  }

  /// Update and persist whether the app should hide after copy.
  Future<void> updateHideOnCopy(bool value) async {
    // Only one of the two can be enabled at a time.
    final exitOnCopy = value ? false : state.exitOnCopy;

    emit(state.copyWith(
      exitOnCopy: exitOnCopy,
      hideOnCopy: value,
    ));

    await _settingsService.saveHideOnCopy(value);
    await _settingsService.saveExitOnCopy(exitOnCopy);
  }

  /// Update and persist whether the app uses the Keybind for visibility toggling.
  Future<void> updateHotKeyEnabled(bool value) async {
    emit(state.copyWith(hotKeyEnabled: value));
    await _settingsService.saveHotKeyEnabled(value);
  }

  /// Update and persist whether the app should show the system tray icon.
  Future<void> updateShowSystemTrayIcon(bool showTray) async {
    emit(state.copyWith(showSystemTrayIcon: showTray));
    showTray ? _systemTray?.show() : _systemTray?.remove();
    await _settingsService.saveShowSystemTrayIcon(showTray);
  }

  /// Update and persist whether the app should start hidden in the system tray.
  Future<void> updateStartHiddenInTray(bool startHidden) async {
    emit(state.copyWith(startHiddenInTray: startHidden));
    await _settingsService.saveStartHiddenInTray(startHidden);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == state.themeMode) return;

    // Update the in-memory state and inform listeners a change has occurred.
    emit(state.copyWith(
      themeMode: newThemeMode,
      userThemePreference: newThemeMode,
    ));

    // Persist the changes to disk.
    await _settingsService.updateThemeMode(newThemeMode);

    _listenToFlatpakTheme();
  }
}
