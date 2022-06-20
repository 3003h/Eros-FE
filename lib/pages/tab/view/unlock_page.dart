import 'package:fehviewer/pages/tab/controller/unlock_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnLockPage extends StatefulWidget {
  const UnLockPage({
    Key? key,
  }) : super(key: key);

  @override
  _UnLockPageState createState() => _UnLockPageState();
}

class _UnLockPageState extends State<UnLockPage> {
  UnlockPageController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => controller.unlockAndback(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoPageScaffold(
          child: SafeArea(
            child: Container(
              alignment: Alignment.center,
/*              child: context.isPortrait
                  ? Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(flex: 2),
                        if (Global.inDebugMode && false)
                          _buildPatternLock(context),
                        Expanded(flex: 1, child: _buildUnlockButton(context)),
                      ],
                    )
                  : Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(flex: 2),
                        if (Global.inDebugMode && false)
                          _buildPatternLock(context),
                        Expanded(flex: 3, child: _buildUnlockButton(context)),
                      ],
                    )*/
              child: _buildUnlockButton(context),
            ),
          ),
        ));
  }

  Widget _buildText(BuildContext context) {
    return Obx(() => Text(
          controller.infoText,
          style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemRed, context)),
        ));
  }

  Widget _buildUnlock(BuildContext context) {
    final Widget _unlockIcon = Icon(
      CupertinoIcons.lock_fill,
      size: 50,
      color: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context),
    ).paddingSymmetric(vertical: 20);

    return GestureDetector(
      onTap: () => controller.unlockAndback(context: context),
      child: _unlockIcon,
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    return CupertinoButton(
        child: const Icon(
          CupertinoIcons.lock_fill,
          size: 50,
        ),
        borderRadius: BorderRadius.circular(100),
        color: CupertinoColors.activeOrange,
        onPressed: () => controller.unlockAndback(context: context));
  }
}
