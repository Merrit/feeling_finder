import 'package:flutter/material.dart';

class AppTheme {
  final _theme = ThemeData();
  final _darkTheme = ThemeData.dark();

  final toggleableActiveColor = Colors.lightBlue;

  ThemeData get themeData {
    return _theme.copyWith();
  }

  ThemeData get darkThemeData {
    return _darkTheme.copyWith(
      // ignore: deprecated_member_use
      toggleableActiveColor: toggleableActiveColor,
    );
  }
}
