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
    WidgetsBinding.instance.addPostFrameCallback(
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
              child: _buildUnlockButton(context),
            ),
          ),
        ));
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
