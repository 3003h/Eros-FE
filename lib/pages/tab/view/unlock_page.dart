import 'package:fehviewer/pages/tab/controller/unlock_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pattern_lock/pattern_lock.dart';

class UnLockPage extends StatefulWidget {
  const UnLockPage({Key key, this.context}) : super(key: key);

  @override
  _UnLockPageState createState() => _UnLockPageState();
  final BuildContext context;
}

class _UnLockPageState extends State<UnLockPage> {
  UnlockPageController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.unlockAndback(context: widget.context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoPageScaffold(
          child: Container(
            alignment: Alignment.center,
            child: context.isPortrait
                ? Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(flex: 2),
                      _buildPatternLock(context),
                      Expanded(flex: 3, child: _buildUnlock(context)),
                    ],
                  )
                : Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(flex: 2),
                      _buildPatternLock(context),
                      Expanded(flex: 3, child: _buildUnlock(context)),
                    ],
                  ),
          ),
        ));
  }

  Container _buildPatternLock(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.mediaQueryShortestSide,
        maxWidth: context.mediaQueryShortestSide,
      ),
      child: PatternLock(
        notSelectedColor: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel, context),

        // color of selected points.
        selectedColor:
            CupertinoDynamicColor.resolve(CupertinoColors.activeGreen, context),
        // radius of points.
        pointRadius: 10,
        // whether show user's input and highlight selected points.
        showInput: true,
        // count of points horizontally and vertically.
        dimension: 3,
        // padding of points area relative to distance between points.
        relativePadding: 0.7,
        // needed distance from input to point to select point.
        selectThreshold: 25,
        // whether fill points.
        fillPoints: true,
        // callback that called when user's input complete. Called if user selected one or more points.
        onInputComplete: (List<int> input) {
          print('pattern is $input');
          controller.infoText = '$input';
        },
      ),
    );
  }

  GestureDetector _buildUnlock(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.unlockAndback(context: context),
      child: Obx(() {
        final Widget _errText = Container(
          child: Text(
            controller.infoText,
            style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemRed, context)),
          ),
        );

        final Widget _unlockIcon = Icon(
          CupertinoIcons.lock_fill,
          size: 50,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel, context),
        ).paddingSymmetric(vertical: 20);

        if (context.isPortrait) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _unlockIcon,
              Expanded(child: _errText),
            ],
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _unlockIcon,
              Expanded(child: _errText),
            ],
          );
        }
      }),
    );
  }
}
