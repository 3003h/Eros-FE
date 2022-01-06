import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/monitor_pop_route.dart';
import 'package:get/get.dart';

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

Future showAttach({
  required BuildContext targetContext,
  required Widget child,
  String? tag,
  VoidCallback? onDismiss,
  double? width,
  EdgeInsetsGeometry? margin,
  AlignmentGeometry? alignmentTemp,
}) async {
  await SmartDialog.showAttach(
    tag: tag,
    keepSingle: true,
    targetContext: targetContext,
    isPenetrateTemp: false,
    // maskColorTemp: Colors.black.withOpacity(0.1),
    alignmentTemp: alignmentTemp,
    clickBgDismissTemp: true,
    onDismiss: onDismiss,
    widget: SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: width,
        margin: margin,
        // constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(16),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.2),
        //       offset: const Offset(0, 0),
        //       blurRadius: 10, //阴影模糊程度
        //       spreadRadius: 1, //阴影扩散程度
        //     ),
        //   ],
        // ),
        // color: CupertinoColors.systemGrey5,
        child: CupertinoPopupSurface(
          child: child,
        ),
      ),
    ),
  );
}
