import 'package:dbus/dbus.dart';

import '../core/core.dart';
import '../window/app_window.dart';

/// DBus interface that enables communication with the app via D-Bus.
class DBusInterface extends DBusObject {
  final AppWindow _appWindow;

  static const _dbusObjectPath = DBusObjectPath.unchecked('/');

  DBusInterface(this._appWindow) : super(_dbusObjectPath);

  Future<void> initialize() async {
    final client = DBusClient.session();
    await client.requestName(kPackageId, flags: {DBusRequestNameFlag.replaceExisting});
    await client.registerObject(this);
  }

  /// Allows hiding, showing, and focusing the app window via D-Bus.
  ///
  /// Allows commanding the window from the command line & Wayland (where global hotkeys are not yet
  /// supported).
  Future<DBusMethodResponse> _toggleWindow() async {
    await _appWindow.toggleVisible();
    return DBusMethodSuccessResponse([const DBusBoolean(true)]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('codes.merritt.FeelingFinder', methods: [
        DBusIntrospectMethod(
          'toggleWindow',
          args: [DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out)],
        )
      ])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'codes.merritt.FeelingFinder') {
      if (methodCall.name == 'toggleWindow') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return _toggleWindow();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'codes.merritt.FeelingFinder') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'codes.merritt.FeelingFinder') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
