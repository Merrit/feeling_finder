import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../helpers/helpers.dart';
import '../localization/strings.g.dart';
import '../shortcuts/app_hotkey.dart';
import '../window/app_window.dart';
import 'cubit/settings_cubit.dart';

class ShortcutSettingsPage extends StatelessWidget {
  const ShortcutSettingsPage({super.key});

  final TextStyle headerStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.settings.shortcut),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settingsCubit = context.read<SettingsCubit>();

          final Widget shortcutExplanation = Text(
            translations.settings.shortcutExplanation,
          );

          final Widget manualShortcut = Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    translations.settings.shortcutInstructionsHeader,
                    style: headerStyle,
                  ),
                  MarkdownBody(
                    selectable: true,
                    data: translations.settings.shortcutInstructions,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text:
                              'dbus-send --session --print-reply --dest=codes.merritt.FeelingFinder / codes.merritt.FeelingFinder.toggleWindow',
                        ),
                      );
                    },
                    child: Text(translations.settings.copyCommand),
                  ),
                ],
              ),
            ),
          );

          final Widget shortcutEnabledTile = SwitchListTile(
            title: Text(translations.settings.hotkeyToggle),
            value: state.hotKeyEnabled,
            onChanged: (value) {
              if (value) {
                hotKeyService.initHotkeyRegistration(context.read<AppWindow>());
              } else {
                hotKeyService.unregisterBindings();
              }
              settingsCubit.updateHotKeyEnabled(value);
            },
          );

          final Widget shortcutConfigTile = Visibility(
            visible: state.hotKeyEnabled,
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedOpacity(
              opacity: state.hotKeyEnabled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              //TODO: Replace with proper hotkey configuration
              child: Text(
                translations.settings.shortcutUsage(
                  modifierKey: HotKeyModifier.alt.name,
                  actionKey: PhysicalKeyboardKey.period.keyLabel,
                ),
              ),
            ),
          );

          final Widget builtInShortcutConfig;
          if (platformIsLinuxX11()) {
            builtInShortcutConfig = Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      translations.settings.builtInShortcut,
                      style: headerStyle,
                    ),
                    shortcutEnabledTile,
                    shortcutConfigTile,
                  ],
                ),
              ),
            );
          } else {
            builtInShortcutConfig = const SizedBox();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            children: [
              shortcutExplanation,
              const SizedBox(height: 20),
              manualShortcut,
              const SizedBox(height: 20),
              builtInShortcutConfig,
            ],
          );
        },
      ),
    );
  }
}
