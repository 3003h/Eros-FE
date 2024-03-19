import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUIOverlay extends StatelessWidget {
  const SystemUIOverlay({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final brightnessLight = Theme.of(context).brightness == Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness:
            brightnessLight ? Brightness.dark : Brightness.light,
      ),
      child: child ?? Container(),
    );
  }

  static TransitionBuilder? init({TransitionBuilder? builder}) {
    return (BuildContext context, Widget? child) => SystemUIOverlay(
          child: builder?.call(context, child),
        );
  }
}
