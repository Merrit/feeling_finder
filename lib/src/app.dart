import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';

import 'emoji/emoji_page.dart';
import 'localization/strings.g.dart';
import 'settings/cubit/settings_cubit.dart';
import 'settings/settings_page.dart';
import 'shortcuts/app_shortcuts.dart';
import 'theme/app_theme.dart';

/// The base widget that configures the application.
class App extends StatefulWidget {
  const App({
    super.key,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TrayListener {
  @override
  void initState() {
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The BlocBuilder widget will rebuild the
    // MaterialApp whenever the ThemeMode is changed.
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) => previous.themeMode != current.themeMode,
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background. This is a setting relevent to mobile devices.
          restorationScopeId: 'app',

          /// Setup for the app translations, the provider inherits from the device locale found in main.dart
          locale: TranslationProvider.of(context).flutterLocale,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppLocaleUtils.supportedLocales,

          /// [translations] is the generated accessor variable for all translations in a set Locale
          title: translations.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsCubit's state to display the correct theme.
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsPage.routeName:
                    return AppShortcuts(child: const SettingsPage());
                  default:
                    return AppShortcuts(child: const EmojiPage());
                }
              },
            );
          },
        );
      },
    );
  }
}
