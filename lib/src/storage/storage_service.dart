import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

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
    final dir = await getApplicationSupportDirectory();
    // Defaults to ~/.local/share/feeling_finder/storage
    Hive.init(dir.path + '/storage');
    _generalBox = await Hive.openBox('general');
  }

  /// Persist a string to local disk storage.
  void setString({required String key, required String value}) {
    _generalBox!.put(key, value);
  }

  /// Get a string from local disk storage.
  String? getString(String key) {
    final String? unboxedValue = _generalBox!.get(key);
    return unboxedValue;
  }
}
