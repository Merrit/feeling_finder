/// A fast and beautiful app to help convey emotion in text communication.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/clipboard/clipboard_service.dart';
import 'src/emoji/cubit/emoji_cubit.dart';
import 'src/emoji/emoji.json.dart';
import 'src/emoji/emoji_service.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/storage/storage_service.dart';

void main() async {
  // Initialize the storage service.
  final storageService = StorageService();
  await storageService.init();

  // Prepare the source of emojis so it is hereafter available.
  final emojiService = EmojiService(emojiJson);

  // Initialize the settings service.
  final settingsService = SettingsService(emojiService, storageService);
  final settingsController = SettingsController(settingsService);

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the state controllers.
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EmojiCubit(
            ClipboardService(),
            emojiService,
            settingsService,
          ),
          lazy: false,
        ),
      ],
      child: App(settingsController: settingsController),
    ),
  );
}
