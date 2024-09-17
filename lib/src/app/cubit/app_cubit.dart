import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../logs/logging_manager.dart';
import '../../settings/settings_service.dart';
import '../../shortcuts/app_hotkey.dart';
import '../../storage/storage_service.dart';
import '../../updates/updates.dart';
import '../../window/app_window.dart';

part 'app_state.dart';
part 'app_cubit.freezed.dart';

class AppCubit extends Cubit<AppState> {
  /// Service for managing the app window.
  final AppWindow? _appWindow;

  /// Service for fetching release notes.
  final ReleaseNotesService _releaseNotesService;

  /// Service for managing preferences and settings.
  final SettingsService _settingsService;

  /// Service for storing and retrieving data.
  final StorageService _storageService;

  /// Service for fetching version info.
  final UpdateService _updateService;

  /// Singleton instance.
  static late AppCubit instance;

  AppCubit(
    this._settingsService,
    this._storageService, {
    AppWindow? appWindow,
    required ReleaseNotesService releaseNotesService,
    required UpdateService updateService,
  })  : _appWindow = appWindow,
        _updateService = updateService,
        _releaseNotesService = releaseNotesService,
        super(AppState.initial()) {
    instance = this;
    _init();
  }

  /// Initializes the cubit.
  ///
  /// Lazy loading is used instead of awaiting on a constructor to avoid
  /// blocking the UI, since none of the data fetched here is critical.
  Future<void> _init() async {
    await _showWindow();
    _appWindow?.events.listen(_handleWindowEvent);
    await _checkForFirstRun();
    await _fetchVersionData();
    await _fetchReleaseNotes();
  }

  /// Shows the app window at startup if not configured to start hidden.
  Future<void> _showWindow() async {
    final bool startHiddenInTray = _settingsService.startHiddenInTray();

    if (startHiddenInTray) {
      return;
    }

    await _appWindow?.show();
  }

  /// Checks if this is the first run of the app.
  Future<void> _checkForFirstRun() async {
    final bool? firstRun = await _storageService.getValue('firstRun');
    if (firstRun == null) {
      emit(state.copyWith(firstRun: true));
      _storageService.saveValue(key: 'firstRun', value: false);
    }
  }

  /// Fetches version data from the update service.
  Future<void> _fetchVersionData() async {
    final versionInfo = await _updateService.getVersionInfo();
    emit(state.copyWith(
      runningVersion: versionInfo.currentVersion,
      updateVersion: versionInfo.latestVersion,
      updateAvailable: versionInfo.updateAvailable,
      showUpdateButton: (defaultTargetPlatform.isDesktop && versionInfo.updateAvailable),
    ));
  }

  /// Fetches release notes from the release notes service.
  Future<void> _fetchReleaseNotes() async {
    if (state.firstRun) return;

    final String? lastReleaseNotesVersionShown = await _storageService //
        .getValue('lastReleaseNotesVersionShown');

    if (lastReleaseNotesVersionShown == state.runningVersion) return;

    final releaseNotes = await _releaseNotesService.getReleaseNotes(
      'v${state.runningVersion}',
    );

    if (releaseNotes == null) return;

    emit(state.copyWith(releaseNotes: releaseNotes));
  }

  /// Handles window events.
  void _handleWindowEvent(WindowEvent event) {
    switch (event) {
      case WindowEvent.closeRequested:
        _handleExitRequest();
      default:
        break;
    }
  }

  /// The window was requested to be closed.
  ///
  /// Decides whether to close the app or hide it.
  ///
  /// Only relevant on desktop platforms.
  Future<void> _handleExitRequest() async {
    assert(_appWindow != null);

    // Hide the window immediately for a feeling of responsiveness.
    await _appWindow!.hide();

    final bool closeToTray = await _settingsService.closeToTray();

    if (closeToTray) {
      return;
    } else {
      _appWindow.dispose();
      await hotKeyService.unregisterBindings();
      exit(0);
    }
  }

  /// The user has dismissed the release notes dialog.
  Future<void> dismissReleaseNotesDialog() async {
    emit(state.copyWith(releaseNotes: null));

    await _storageService.saveValue(
      key: 'lastReleaseNotesVersionShown',
      value: state.runningVersion,
    );
  }

  /// Launch the requested [url] in the default browser.
  Future<bool> launchURL(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      log.e('Unable to parse url: $url');
      return false;
    }

    try {
      return await url_launcher.launchUrl(uri);
    } on PlatformException catch (e) {
      log.e('Could not launch url: $url', error: e);
      return false;
    }
  }

  /// The user has requested to quit the app.
  void quit() async {
    LoggingManager.instance.close();
    await hotKeyService.unregisterBindings();
    exit(0);
  }

  /// Reset the window to the default size.
  void resetWindowSize() async => await _appWindow?.resetSize();
}
