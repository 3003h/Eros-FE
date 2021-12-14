import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/monitor_pop_route.dart';

class FlutterSmartDialogCupertino extends StatefulWidget {
  const FlutterSmartDialogCupertino({Key? key, required this.child})
      : super(key: key);

  final Widget? child;

  @override
  _FlutterSmartDialogCupertinoState createState() =>
      _FlutterSmartDialogCupertinoState();

  static final observer = SmartNavigatorObserver();

  static void monitor() => MonitorPopRoute.instance;

  ///recommend the way of init
  static TransitionBuilder init({TransitionBuilder? builder}) {
    monitor();

    return (BuildContext context, Widget? child) {
      return builder == null
          ? FlutterSmartDialogCupertino(child: child)
          : builder(context, FlutterSmartDialogCupertino(child: child));
    };
  }
}

class _FlutterSmartDialogCupertinoState
    extends State<FlutterSmartDialogCupertino> {
  @override
  void initState() {
    // solve Flutter Inspector -> select widget mode function failure problem
    DialogProxy.instance.initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Overlay(initialEntries: [
        //main layout
        OverlayEntry(
          builder: (BuildContext context) => widget.child ?? Container(),
        ),

        //provided separately for custom dialog
        OverlayEntry(builder: (BuildContext context) {
          DialogProxy.context = context;
          return Container();
        }),

        //provided separately for loading
        DialogProxy.instance.entryLoading,

        //provided separately for toast
        DialogProxy.instance.entryToast,
      ]),
    );
  }
}
