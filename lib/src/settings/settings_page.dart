import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          width: 350,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                // Glue the SettingsController to the theme selection DropdownButton.
                //
                // When a user selects a theme from the dropdown list, the
                // SettingsController is updated, which rebuilds the MaterialApp.
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return DropdownButton<ThemeMode>(
                      // Read the selected themeMode from the controller
                      value: state.themeMode,
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
                    );
                  },
                ),
              ),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return SwitchListTile(
                    title: const Text('Exit after copying to clipboard'),
                    value: state.exitOnCopy,
                    onChanged: (value) => settingsCubit.updateExitOnCopy(value),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
