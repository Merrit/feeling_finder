import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  SettingsCubit(
    this._settingsService,
  ) : super(
          SettingsState(
            exitOnCopy: _settingsService.exitOnCopy(),
            themeMode: _settingsService.themeMode(),
          ),
        ) {
    settingsCubit = this;
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
    emit(state.copyWith(themeMode: newThemeMode));

    // Persist the changes to disk.
    await _settingsService.updateThemeMode(newThemeMode);
  }
}
