import 'src/kde/klipper.dart';

/// This class is the interface to the native OS clipboard.
abstract class ClipboardService {
  /// Set [value] as the current clipboard contents.
  static Future<void> setClipboardContents(String value) async {
    // If adapting for cross-platform / cross-desktop this will need
    // to check the OS and/or desktop environment to call different methods.
    await Klipper.setClipboardContents(value);
  }
}
