import 'package:feeling_finder/src/helpers/helpers.dart';
import 'package:feeling_finder/src/shortcuts/app_hotkey.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../app/app.dart';
import '../core/core.dart';
import '../localization/strings.g.dart';
import 'cubit/settings_cubit.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const routeName = '/settings';
  static bool runsX11 = platformIsLinuxX11();

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.settings.title),
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
                    title: Text(translations.settings.theme),
                    trailing: DropdownButton<ThemeMode>(
                      // Read the selected themeMode from the controller
                      value: state.userThemePreference,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: settingsCubit.updateThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(
                            translations.settings.systemTheme,
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(translations.settings.lightTheme),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(translations.settings.darkTheme),
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
                    title: Text(translations.settings.exitAfterCopy),
                    value: state.exitOnCopy,
                    onChanged: (value) => settingsCubit.updateExitOnCopy(value),
                  );
                },
              ),

              const Divider(),

              if (defaultTargetPlatform.isDesktop)
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      title: Text(translations.settings.showSystemTray),
                      value: state.showSystemTrayIcon,
                      onChanged: (value) =>
                          settingsCubit.updateShowSystemTrayIcon(value),
                    );
                  },
                ),

              if (runsX11)
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      title: Text(translations.settings.hotkeyToggle),
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

              if (runsX11)
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
                          child: Text(translations.settings.shortcutUsage(
                              modifierKey: KeyModifier.alt.keyLabel,
                              actionKey: KeyCode.period.keyLabel)),
                        ));
                  },
                ),

              if (runsX11) const Divider(),

              BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          '${translations.settings.currentVersion}: ${state.runningVersion}',
                        ),
                      ),
                      ListTile(
                        title: Text(
                          (state.updateAvailable)
                              ? '${translations.settings.updateAvailable}: ${state.updateVersion}'
                              : translations.settings.upToDate,
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
                    title: Text(translations.settings.homepage),
                    trailing: const Icon(Icons.language),
                    onTap: () => AppCubit.instance.launchURL(kWebsiteUrl),
                  ),
                  ListTile(
                    title: Text(translations.settings.donate),
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
