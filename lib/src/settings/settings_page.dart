import 'package:feeling_finder/src/shortcuts/app_hotkey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app.dart';
import '../core/core.dart';
import '../localization/gen/app_localizations.dart';
import 'cubit/settings_cubit.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Glue the SettingsCubit to the theme selection DropdownButton.
              //
              // When a user selects a theme from the dropdown list, the
              // SettingsCubit is updated, which rebuilds the MaterialApp.
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return ListTile(
                    title: Text(AppLocalizations.of(context)!.theme),
                    trailing: DropdownButton<ThemeMode>(
                      // Read the selected themeMode from the controller
                      value: state.userThemePreference,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: settingsCubit.updateThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(
                            AppLocalizations.of(context)!.systemTheme,
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(AppLocalizations.of(context)!.lightTheme),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(AppLocalizations.of(context)!.darkTheme),
                        )
                      ],
                    ),
                  );
                },
              ),

              const Divider(),

              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.exitAfterCopy),
                    value: state.exitOnCopy,
                    onChanged: (value) => settingsCubit.updateExitOnCopy(value),
                  );
                },
              ),

              const Divider(),

              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return SwitchListTile(
                    title: const Text("Toggle visibility with a keyboard shortcut"),
                    value: state.hotKeyEnabled,
                    onChanged: (value) {
                      if (value) {
                        hotKeyService.initHotkeyRegistration();
                      } else {
                        hotKeyService.unregisterBindings();
                      }
                      settingsCubit.updateHotKeyEnabled(value);
                    },
                  );
                },
              ),

              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return Visibility(
                      visible: state.hotKeyEnabled,
                      maintainAnimation: true,
                      maintainState: true,
                      child: AnimatedOpacity(
                        opacity: state.hotKeyEnabled ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        //TODO: Replace with proper hotkey configuration
                        child: const Text("Press Alt + . to use the shortcut"),
                      )
                  );
                },
              ),

              const Divider(),

              BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          '${AppLocalizations.of(context)!.currentVersion}: ${state.runningVersion}',
                        ),
                      ),
                      ListTile(
                        title: Text(
                          (state.updateAvailable)
                              ? '${AppLocalizations.of(context)!.updateAvailable}: ${state.updateVersion}'
                              : AppLocalizations.of(context)!.upToDate,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Divider(),

              Column(
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.homepage),
                    trailing: const Icon(Icons.language),
                    onTap: () => AppCubit.instance.launchURL(kWebsiteUrl),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.donate),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onTap: () => AppCubit.instance.launchURL(kDonateUrl),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
