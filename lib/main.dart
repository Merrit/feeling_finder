/// A fast and beautiful app to help convey emotion in text communication.

// ignore_for_file: dangling_library_doc_comments

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';
import 'package:http/http.dart' as http;

import 'src/app.dart';
import 'src/app/app.dart';
import 'src/dbus/dbus_interface.dart';
import 'src/emoji/cubit/emoji_cubit.dart';
import 'src/emoji/emoji_service.dart';
import 'src/helpers/helpers.dart';
import 'src/localization/strings.g.dart';
import 'src/logs/logging_manager.dart';
import 'src/settings/cubit/settings_cubit.dart';
import 'src/settings/settings_service.dart';
import 'src/shortcuts/app_hotkey.dart';
import 'src/storage/storage_service.dart';
import 'src/system_tray/system_tray.dart';
import 'src/updates/updates.dart';
import 'src/window/app_window.dart';

void main(List<String> args) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  // Add the Google Fonts license to the LicenseRegistry.
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  /// Initial configuration for the app locale.
  LocaleSettings.useDeviceLocale();

  final bool verbose = args.contains('-v') ||
      args.contains('--verbose') ||
      const String.fromEnvironment('VERBOSE') == 'true';

  await LoggingManager.initialize(verbose: verbose);
  await activateExistingSession();

  // Initialize the storage service.
  final storageService = StorageService();

  // Wait for the storage service to initialize while showing the splash screen.
  // This allows us to be certain settings are available right away,
  // and prevents unsightly things like the theme suddenly changing when loaded.
  await storageService.init();

  final isWindows11 = await _isWindows11();
  final emojiService = EmojiService(isWindows11);

  // Initialize the settings service.
  final settingsService = SettingsService(storageService);

  final appWindow = AppWindow();
  await appWindow.initialize();

  final systemTray = await SystemTray.initialize(appWindow);

  final appCubit = AppCubit(
    settingsService,
    storageService,
    appWindow: appWindow,
    releaseNotesService: ReleaseNotesService(
      client: http.Client(),
      repository: 'merrit/feeling_finder',
    ),
    updateService: UpdateService(),
  );

  final settingsCubit = await SettingsCubit.init(
    settingsService,
    systemTray,
  );

  // Initialize Visibility Shortcut (Depends on Settings Service)
  if (platformIsLinuxX11()) hotKeyService.initHotkeyRegistration(appWindow);

  if (defaultTargetPlatform.isLinux) {
    final dbusInterface = DBusInterface(appWindow);
    await dbusInterface.initialize();
  }

  // Run the app and pass in the state controllers.
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: appWindow),
        RepositoryProvider.value(value: settingsService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
          BlocProvider(
            create: (context) => EmojiCubit(
              appWindow,
              emojiService,
              settingsCubit,
              settingsService,
              storageService,
            ),
            lazy: false,
          ),
          BlocProvider.value(value: settingsCubit),
        ],
        child: TranslationProvider(child: const App()),
      ),
    ),
  );
}

/// True if the current platform is Windows 11.
///
/// This is important because different versions of Windows support different versions of the
/// Unicode emoji set. We may be able to do away with this check if the bug preventing the Windows
/// builds from using Noto Color Emoji is resolved. See:
/// https://github.com/material-foundation/flutter-packages/issues/575
///
/// It seems that at the moment, Windows 10 supports Unicode 12.0 emojis, while Windows 11
/// supports Unicode 14.0 emojis. See:
/// https://emojipedia.org/microsoft
Future<bool> _isWindows11() async {
  if (!defaultTargetPlatform.isWindows) return false;

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
  // If the platform reports this build number or greater, it is Windows 11.
  const kWindows11AndGreaterBuildNumber = 22000;
  return windowsInfo.buildNumber >= kWindows11AndGreaterBuildNumber ? true : false;
}
