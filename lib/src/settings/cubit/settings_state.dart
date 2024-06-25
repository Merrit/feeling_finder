part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// Whether the app should continue running in the tray when closed.
    required bool closeToTray,

    /// Whether the app should exit automatically after copying an emoji.
    required bool exitOnCopy,

    /// Whether the app should use the hotkey to show and hide the app.
    required bool hotKeyEnabled,

    /// Whether the system tray icon should be shown.
    required bool showSystemTrayIcon,

    /// Whether the app should start hidden in the system tray.
    required bool startHiddenInTray,

    /// The currently loaded [ThemeMode].
    required ThemeMode themeMode,

    /// Which [ThemeMode] the user wishes to follow.
    ///
    /// Mostly useful when it is `ThemeMode.system`, so we can distinguish the
    /// mode we are *displaying* from what we are *following*, eg; the
    /// preference is system, but [SettingsState.themeMode] is dark/light.
    required ThemeMode userThemePreference,
  }) = _SettingsState;
}
