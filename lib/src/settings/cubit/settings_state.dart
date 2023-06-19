part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// Whether the app should exit automatically after copying an emoji.
  final bool exitOnCopy;

  /// Whether the app should use the hotkey to show and hide the app.
  final bool hotKeyEnabled;

  /// The currently loaded [ThemeMode].
  final ThemeMode themeMode;

  /// Which [ThemeMode] the user wishes to follow.
  ///
  /// Mostly useful when it is `ThemeMode.system`, so we can distinguish the
  /// mode we are *displaying* from what we are *following*, eg; the
  /// preference is system, but [SettingsState.themeMode] is dark/light.
  final ThemeMode userThemePreference;

  const SettingsState({
    required this.exitOnCopy,
    required this.hotKeyEnabled,
    required this.themeMode,
    required this.userThemePreference,
  });

  @override
  List<Object> get props => [
        exitOnCopy,
        hotKeyEnabled,
        themeMode,
        userThemePreference,
      ];

  SettingsState copyWith({
    bool? exitOnCopy,
    bool? hotKeyEnabled,
    ThemeMode? themeMode,
    ThemeMode? userThemePreference,
  }) {
    return SettingsState(
      exitOnCopy: exitOnCopy ?? this.exitOnCopy,
      hotKeyEnabled: hotKeyEnabled ?? this.hotKeyEnabled,
      themeMode: themeMode ?? this.themeMode,
      userThemePreference: userThemePreference ?? this.userThemePreference,
    );
  }
}
