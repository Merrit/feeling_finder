import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flatpak/flutter_flatpak.dart';

import '../settings_service.dart';

part 'settings_state.dart';

/// Convenient global access to the SettingsCubit.
///
/// There is only ever 1 instance of this cubit, and having this variable
/// means not having to do `context.read<SettingsCubit>()` to access it every
/// time, as well as making it available without a BuildContext.
late SettingsCubit settingsCubit;

/// Controls the state of the settings for the app.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;

  SettingsCubit._(
    this._settingsService, {
    required ThemeMode userThemePreference,
  }) : super(
          SettingsState(
            exitOnCopy: _settingsService.exitOnCopy(),
            themeMode: userThemePreference,
            userThemePreference: userThemePreference,
          ),
        ) {
    settingsCubit = this;
    _listenToFlatpakTheme();
  }

  static Future<SettingsCubit> init(SettingsService settingsService) async {
    return SettingsCubit._(
      settingsService,
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

    _flatpakThemeModeStream =
        flatpak?.themeModeStream.listen((ThemeMode? themeMode) {
      if (themeMode == null) return;

      emit(state.copyWith(themeMode: themeMode));
    });
  }

  /// Update and persist whether the app should exit after copy.
  Future<void> updateExitOnCopy(bool value) async {
    emit(state.copyWith(exitOnCopy: value));
    await _settingsService.saveExitOnCopy(value);
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
