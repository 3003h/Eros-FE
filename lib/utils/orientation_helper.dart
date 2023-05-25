import 'package:flutter/services.dart';
// import 'package:orientation/orientation.dart';

// ignore: avoid_classes_with_only_static_members
class OrientationHelper {
  // static Future<void> setEnabledSystemUIOverlays(
  //     List<SystemUiOverlay> overlays) {
  //   // return OrientationPlugin.setEnabledSystemUIOverlays(overlays);
  //   return SystemChrome.setEnabledSystemUIOverlays(overlays);
  // }

  static Future<void> setPreferredOrientations(
      List<DeviceOrientation> orientations) {
    // return OrientationPlugin.setPreferredOrientations(orientations);
    return SystemChrome.setPreferredOrientations(orientations);
  }

  static Future<void> forceOrientation(DeviceOrientation orientation) {
    // return OrientationPlugin.forceOrientation(orientation);
    return SystemChrome.setPreferredOrientations([orientation]);
  }

  /// [DeviceOrientation.portraitUp] is default.
  static const DeviceOrientation initOrientation = DeviceOrientation.portraitUp;

  static Stream<DeviceOrientation>? _onOrientationChange;

  // static Stream<DeviceOrientation>? get onOrientationChange {
  //   _onOrientationChange ??= OrientationPlugin.onOrientationChange
  //       .shareValueSeeded(initOrientation)
  //       .distinct((DeviceOrientation previous, DeviceOrientation next) =>
  //           previous == next);
  //   return _onOrientationChange;
  // }
}
