import 'dart:io' show Platform;

export 'activate_exiting_sessions.dart';

/// Convenience function to check if the app is running on a Linux with the X11 display manager
bool platformIsLinuxX11() {
  if (Platform.isLinux) {
    if (Platform.environment['XDG_SESSION_TYPE'] == 'x11') {
      return true;
    }
  }
  return false;
}
