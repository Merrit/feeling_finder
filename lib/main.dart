/// A fast and beautiful app to help convey emotion in text communication.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/clipboard/clipboard_service.dart';
import 'src/emoji/cubit/emoji_cubit.dart';
import 'src/emoji/emoji.json.dart';
import 'src/emoji/emoji_service.dart';
import 'src/settings/cubit/settings_cubit.dart';
import 'src/settings/settings_service.dart';
import 'src/storage/storage_service.dart';

void main() async {
  // Initialize the storage service.
  final storageService = StorageService();

  // Wait for the storage service to initialize while showing the splash screen.
  // This allows us to be certain settings are available right away,
  // and prevents unsightly things like the theme suddenly changing when loaded.
  await storageService.init();

  // Prepare the source of emojis.
  final emojiService = EmojiService(emojiJson);

  // Initialize the settings service.
  final settingsService = SettingsService(emojiService, storageService);

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
        BlocProvider(
          create: (context) => SettingsCubit(settingsService),
          lazy: false,
        ),
      ],
      child: const App(),
    ),
  );
}
