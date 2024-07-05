import 'constants.dart';

/// The paths to the app's icons.
abstract class AppIcons {
  /// Asset directory containing the app's icons.
  static const String path = 'assets/icons';

  /// Normal icon as an ICO.
  static const String ico = '$path/$kPackageId.ico';

  /// Dark symbolic icon as an ICO.
  static const String icoSymbolicDark = '$path/$kPackageId-symbolicDark.ico';

  /// Light symbolic icon as an ICO.
  static const String icoSymbolicLight = '$path/$kPackageId-symbolicLight.ico';

  /// Normal icon as a PNG.
  static const String png = '$path/$kPackageId.png';

  /// Normal icon as an SVG.
  static const String svg = '$path/$kPackageId.svg';

  /// Dark symbolic icon as an SVG.
  static const String svgSymbolicDark = '$path/$kPackageId-symbolicDark.svg';

  /// Light symbolic icon as an SVG.
  static const String svgSymbolicLight = '$path/$kPackageId-symbolicLight.svg';
}
