import 'package:fehviewer/pages/tab/controller/unlock_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnLockPage extends StatefulWidget {
  @override
  _UnLockPageState createState() => _UnLockPageState();
}

class _UnLockPageState extends State<UnLockPage> {
  UnlockPageController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.unlockAndback());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoPageScaffold(
          child: Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: controller.unlockAndback,
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.lock_fill,
                        size: 50,
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel, context),
                      ).paddingSymmetric(vertical: 20),
                      Text(
                        controller.infoText,
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.systemRed, context)),
                      ).paddingSymmetric(horizontal: 20),
                    ],
                  )),
            ),
          ),
        ));
  }
}
