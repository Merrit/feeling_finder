import 'package:feeling_finder/src/app/cubit/app_cubit.dart';
import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji_page.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:feeling_finder/src/settings/cubit/settings_cubit.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:feeling_finder/src/storage/storage_service.dart';
import 'package:feeling_finder/src/system_tray/system_tray.dart';
import 'package:feeling_finder/src/updates/updates.dart';
import 'package:feeling_finder/src/window/app_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<AppWindow>(),
  MockSpec<SettingsService>(),
  MockSpec<StorageService>(),
  MockSpec<SystemTray>(),
  MockSpec<ReleaseNotesService>(),
  MockSpec<UpdateService>(),
])
import 'emoji_page_test.mocks.dart';

void main() {
  group('EmojiPage:', () {
    late MockAppWindow appWindow;
    late MockSettingsService mockSettingsService;
    late MockStorageService mockStorageService;
    late MockSystemTray mockSystemTray;
    late MockReleaseNotesService mockReleaseNotesService;
    late MockUpdateService mockUpdateService;

    setUpAll(() async {
      await LoggingManager.initialize(verbose: false);

      appWindow = MockAppWindow();
      when(appWindow.isFocused()).thenAnswer((_) async => true);
      when(appWindow.hide()).thenAnswer((_) async {});
      when(appWindow.show()).thenAnswer((_) async {});
    });

    setUp(() {
      mockSettingsService = MockSettingsService();
      mockStorageService = MockStorageService();
      mockSystemTray = MockSystemTray();
      mockReleaseNotesService = MockReleaseNotesService();

      mockUpdateService = MockUpdateService();
      when(mockUpdateService.getVersionInfo())
          .thenAnswer((_) => Future.value(const VersionInfo.empty()));
    });

    testWidgets('initial state', (tester) async {
      final appCubit = AppCubit(
        mockSettingsService,
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final settingsCubit = await SettingsCubit.init(
        mockSettingsService,
        mockSystemTray,
      );

      final emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(false),
        settingsCubit,
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: EmojiPage(),
          ),
        ),
      );

      expect(find.byType(EmojiPage), findsOneWidget);
    });

    testWidgets('shows release notes', (tester) async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(false));

      when(mockStorageService.getValue('lastReleaseNotesVersionShown'))
          .thenAnswer((_) => Future.value('v1.2.2'));

      when(mockReleaseNotesService.getReleaseNotes(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => const ReleaseNotes(
            version: 'v1.2.3',
            date: '2021-01-01',
            notes: 'Release notes',
            fullChangeLogUrl: 'https://example.com',
          ),
        ),
      );

      final appCubit = AppCubit(
        mockSettingsService,
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final settingsCubit = await SettingsCubit.init(
        mockSettingsService,
        mockSystemTray,
      );

      final emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(false),
        settingsCubit,
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: EmojiPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EmojiPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("What's new in v1.2.3"), findsOneWidget);
    });

    testWidgets('Esc clears search text', (tester) async {
      final appCubit = AppCubit(
        mockSettingsService,
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final settingsCubit = await SettingsCubit.init(
        mockSettingsService,
        mockSystemTray,
      );

      final emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(false),
        settingsCubit,
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: EmojiPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the search view via Ctrl+F.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // Type some search text.
      await tester.enterText(find.byType(TextField).last, 'smile');
      await tester.pumpAndSettle();

      // Dismiss with Escape.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // The search bar text should be cleared.
      final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
      expect(searchBar.controller?.text, isEmpty);
    });

    testWidgets('Ctrl+F works after dismissing search with Esc', (tester) async {
      final appCubit = AppCubit(
        mockSettingsService,
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final settingsCubit = await SettingsCubit.init(
        mockSettingsService,
        mockSystemTray,
      );

      final emojiCubit = EmojiCubit(
        appWindow,
        EmojiService(false),
        settingsCubit,
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: EmojiPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the search view via Ctrl+F.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // Dismiss with Escape.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Ctrl+F should open the search view again.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // A TextField should be visible (the search view is open).
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
