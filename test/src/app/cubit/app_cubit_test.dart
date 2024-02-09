import 'package:feeling_finder/src/app/cubit/app_cubit.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:feeling_finder/src/storage/storage_service.dart';
import 'package:feeling_finder/src/updates/updates.dart';
import 'package:feeling_finder/src/window/app_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<StorageService>(),
  MockSpec<ReleaseNotesService>(),
  MockSpec<UpdateService>(),
])
import 'app_cubit_test.mocks.dart';

Future<void> main() async {
  group('AppCubit:', () {
    late MockStorageService mockStorageService;
    late MockReleaseNotesService mockReleaseNotesService;
    late MockUpdateService mockUpdateService;
    const mockWindowEventsStream = Stream<WindowEvent>.empty();

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

    test('initial state', () {
      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      expect(appCubit.state, AppState.initial());
    });

    test('first run', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(null));

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appCubit.state.firstRun, true);
      await appCubit.close();
    });

    test('not first run', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(false));

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appCubit.state.firstRun, false);
      await appCubit.close();
    });

    test('no update available', () async {
      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.0.0',
            latestVersion: '1.0.0',
            updateAvailable: false,
          ),
        ),
      );

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appCubit.state.runningVersion, '1.0.0');
      expect(appCubit.state.updateVersion, '1.0.0');
      expect(appCubit.state.updateAvailable, false);
      expect(appCubit.state.showUpdateButton, false);
      await appCubit.close();
    });

    test('update available', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.0.0',
            latestVersion: '1.0.1',
            updateAvailable: true,
          ),
        ),
      );

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appCubit.state.runningVersion, '1.0.0');
      expect(appCubit.state.updateVersion, '1.0.1');
      expect(appCubit.state.updateAvailable, true);
      expect(appCubit.state.showUpdateButton, true);
      await appCubit.close();
    });

    test('update available unknown', () async {
      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.0.0',
            latestVersion: null,
            updateAvailable: false,
          ),
        ),
      );

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appCubit.state.runningVersion, '1.0.0');
      expect(appCubit.state.updateVersion, null);
      expect(appCubit.state.updateAvailable, false);
      expect(appCubit.state.showUpdateButton, false);
      await appCubit.close();
    });

    test('fetch release notes not checked on first run', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(null));

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      verifyNever(mockReleaseNotesService.getReleaseNotes(any));
      await appCubit.close();
    });

    test('fetch release notes not checked if already shown for current version', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(false));

      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.1.0',
            latestVersion: '1.1.0',
            updateAvailable: false,
          ),
        ),
      );

      when(mockStorageService.getValue('lastReleaseNotesVersionShown'))
          .thenAnswer((_) => Future.value('1.1.0'));

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      verifyNever(mockReleaseNotesService.getReleaseNotes(any));
      await appCubit.close();
    });

    test('fetch release notes works when release notes never shown', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(false));

      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.1.0',
            latestVersion: '1.1.0',
            updateAvailable: false,
          ),
        ),
      );

      when(mockStorageService.getValue('lastReleaseNotesVersionShown'))
          .thenAnswer((_) => Future.value(null));

      when(mockReleaseNotesService.getReleaseNotes(any)).thenAnswer(
        (_) => Future.value(
          const ReleaseNotes(
            version: '1.1.0',
            date: '2021-01-01',
            notes: 'Notes',
            fullChangeLogUrl: 'https://example.com',
          ),
        ),
      );

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      verify(mockReleaseNotesService.getReleaseNotes('v1.1.0')).called(1);
      await appCubit.close();
    });

    test('fetch release notes works when release notes shown for old version', () async {
      when(mockStorageService.getValue('firstRun')).thenAnswer((_) => Future.value(false));

      when(mockUpdateService.getVersionInfo()).thenAnswer(
        (_) => Future.value(
          const VersionInfo(
            currentVersion: '1.1.0',
            latestVersion: '1.1.0',
            updateAvailable: false,
          ),
        ),
      );

      when(mockStorageService.getValue('lastReleaseNotesVersionShown'))
          .thenAnswer((_) => Future.value('1.0.1'));

      when(mockReleaseNotesService.getReleaseNotes(any)).thenAnswer(
        (_) => Future.value(
          const ReleaseNotes(
            version: '1.1.0',
            date: '2021-01-01',
            notes: 'Notes',
            fullChangeLogUrl: 'https://example.com',
          ),
        ),
      );

      final appCubit = AppCubit(
        mockStorageService,
        releaseNotesService: mockReleaseNotesService,
        updateService: mockUpdateService,
        windowEvents: mockWindowEventsStream,
      );

      // Wait for the cubit to initialize.
      await Future.delayed(const Duration(milliseconds: 100));
      verify(mockReleaseNotesService.getReleaseNotes('v1.1.0')).called(1);
      await appCubit.close();
    });
  });
}
