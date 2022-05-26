import 'dart:io' show FileSystemException;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../helpers/helpers.dart';

/// Interfaces with the host OS to store & retrieve data from disk.
class StorageService {
  /// This class is a singleton.
  /// This variable holds the instance once created.
  static StorageService? _instance;

  /// Private singleton constructor.
  StorageService._singleton();

  /// Factory ensures only one instance is ever created.
  factory StorageService() {
    if (_instance != null) return _instance!;
    return StorageService._singleton();
  }

  /// A generic storage pool, anything large should make its own box.
  Box? _generalBox;

  /// Initialize the storage access.
  /// Needs to be initialized only once, in the `main()` function.
  Future<void> init() async {
    /// On desktop platforms initialize to a specific directory.
    if (platformIsDesktop()) {
      final dir = await getApplicationSupportDirectory();
      // Defaults to ~/.local/share/feeling_finder/storage
      Hive.init(dir.path + '/storage');
    } else {
      // On mobile web, initialize to default location.
      await Hive.initFlutter();
    }

    try {
      _generalBox = await Hive.openBox('general');
    } on FileSystemException catch (e) {
      debugPrint('''
Feeling Finder: Exception opening storage:

$e

Possible another instance is already running?''');
    }
  }

  /// Persist a value to local disk storage.
  Future<void> saveValue({required String key, required dynamic value}) async {
    await _generalBox!.put(key, value);
  }

  /// Get a value from local disk storage.
  dynamic getValue(String key) => _generalBox!.get(key);
}
