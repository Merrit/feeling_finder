part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  /// The currently loaded [ThemeMode].
  final ThemeMode themeMode;

  const SettingsState({
    required this.themeMode,
  });

  @override
  List<Object> get props => [themeMode];

  SettingsState copyWith({
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
