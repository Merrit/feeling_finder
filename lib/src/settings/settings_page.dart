import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../app/app.dart';
import '../core/core.dart';
import '../localization/strings.g.dart';
import 'cubit/settings_cubit.dart';
import 'shortcut.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    // Glue the SettingsCubit to the theme selection DropdownButton.
    //
    // When a user selects a theme from the dropdown list, the
    // SettingsCubit is updated, which rebuilds the MaterialApp.
    final Widget themeTile = BlocBuilder<SettingsCubit, SettingsState>(
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
    );

    final Widget exitAfterCopyTile = BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(translations.settings.exitAfterCopy),
          value: state.exitOnCopy,
          onChanged: (value) => settingsCubit.updateExitOnCopy(value),
        );
      },
    );

    final Widget showTrayTile = BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(translations.settings.showSystemTray),
          value: state.showSystemTrayIcon,
          onChanged: (value) => settingsCubit.updateShowSystemTrayIcon(value),
        );
      },
    );

    final Widget hideOnCopyTile = BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(translations.settings.hideOnCopy),
          value: state.hideOnCopy,
          onChanged: (value) => settingsCubit.updateHideOnCopy(value),
        );
      },
    );

    final Widget closeToTrayTile = BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(translations.settings.closeToTray),
          value: state.closeToTray,
          onChanged: (value) => settingsCubit.updateCloseToTray(value),
        );
      },
    );

    final Widget startHiddenInTrayTile = BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(translations.settings.startHiddenInTray),
          value: state.startHiddenInTray,
          onChanged: state.showSystemTrayIcon
              ? (value) => settingsCubit.updateStartHiddenInTray(value)
              : null,
        );
      },
    );

    final Widget shortcutTile;
    // Hotkey is currently only supported on Linux
    // https://github.com/Merrit/feeling_finder/pull/59#issuecomment-1588154461
    if (defaultTargetPlatform.isLinux) {
      shortcutTile = ListTile(
        leading: const Icon(Icons.keyboard),
        title: Text(translations.settings.shortcut),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShortcutSettingsPage()),
        ),
      );
    } else {
      shortcutTile = const SizedBox();
    }

    final Widget versionWidgets = BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            ListTile(
              title: Text(
                '${translations.settings.currentVersion}: ${state.runningVersion}',
              ),
            ),
            if (state.updateVersion != null)
              ListTile(
                title: Text(
                  (state.updateAvailable)
                      ? '${translations.settings.updateAvailable}: ${state.updateVersion}'
                      : translations.settings.upToDate,
                ),
              ),
            ListTile(
              title: const Text('About'),
              onTap: () => showAboutDialog(
                context: context,
                applicationIcon: CircleAvatar(
                  child: Image.asset('assets/icons/codes.merritt.FeelingFinder.png'),
                ),
                applicationName: 'Feeling Finder',
                applicationVersion: state.runningVersion,
              ),
            ),
          ],
        );
      },
    );

    final Widget homepageTile = ListTile(
      title: Text(translations.settings.homepage),
      trailing: const Icon(Icons.language),
      onTap: () => AppCubit.instance.launchURL(kWebsiteUrl),
    );

    final Widget donateTile = ListTile(
      title: Text(translations.settings.donate),
      trailing: const Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      onTap: () => AppCubit.instance.launchURL(kDonateUrl),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.settings.title),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          children: [
            const SizedBox(height: 50),
            themeTile,
            const Divider(),
            exitAfterCopyTile,
            if (defaultTargetPlatform.isDesktop) showTrayTile,
            if (defaultTargetPlatform.isDesktop) hideOnCopyTile,
            if (defaultTargetPlatform.isDesktop) closeToTrayTile,
            if (defaultTargetPlatform.isDesktop) startHiddenInTrayTile,
            shortcutTile,
            const Divider(),
            versionWidgets,
            const Divider(),
            homepageTile,
            donateTile,
          ],
        ),
      ),
    );
  }
}
