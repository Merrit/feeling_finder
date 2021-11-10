part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// Whether the app should exit automatically after copying an emoji.
  final bool exitOnCopy;

  /// The currently loaded [ThemeMode].
  final ThemeMode themeMode;

  const SettingsState({
    required this.exitOnCopy,
    required this.themeMode,
  });

  @override
  List<Object> get props => [
        exitOnCopy,
        themeMode,
      ];

  SettingsState copyWith({
    bool? exitOnCopy,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      exitOnCopy: exitOnCopy ?? this.exitOnCopy,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
