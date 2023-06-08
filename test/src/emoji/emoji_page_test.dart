import 'package:feeling_finder/src/app/cubit/app_cubit.dart';
import 'package:feeling_finder/src/emoji/cubit/emoji_cubit.dart';
import 'package:feeling_finder/src/emoji/emoji_page.dart';
import 'package:feeling_finder/src/emoji/emoji_service.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:feeling_finder/src/settings/settings_service.dart';
import 'package:feeling_finder/src/storage/storage_service.dart';
import 'package:feeling_finder/src/updates/updates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<StorageService>(),
  MockSpec<ReleaseNotesService>(),
  MockSpec<UpdateService>(),
])
import 'emoji_page_test.mocks.dart';

void main() {
  group('EmojiPage:', () {
    late MockStorageService mockStorageService;
    late MockReleaseNotesService mockReleaseNotesService;
    late MockUpdateService mockUpdateService;

    setUpAll(() async {
      await LoggingManager.initialize(verbose: false);
    });

    setUp(() {
      mockStorageService = MockStorageService();
      mockReleaseNotesService = MockReleaseNotesService();

      mockUpdateService = MockUpdateService();
      when(mockUpdateService.getVersionInfo())
          .thenAnswer((_) => Future.value(const VersionInfo.empty()));
    });

    testWidgets('initial state', (tester) async {
      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final emojiCubit = EmojiCubit(
        EmojiService(),
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: EmojiPage(),
          ),
        ),
      );

      expect(find.byType(EmojiPage), findsOneWidget);
    });

    testWidgets('shows release notes', (tester) async {
      when(mockStorageService.getValue('firstRun'))
          .thenAnswer((_) => Future.value(false));

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
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
      );

      final emojiCubit = EmojiCubit(
        EmojiService(),
        SettingsService(mockStorageService),
        mockStorageService,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: emojiCubit),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: EmojiPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(EmojiPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("What's new in v1.2.3"), findsOneWidget);
    });
  });
}
