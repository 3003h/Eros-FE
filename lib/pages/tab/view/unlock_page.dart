import 'package:eros_fe/pages/tab/controller/unlock_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UnLockPage extends StatefulWidget {
  const UnLockPage({
    super.key,
    this.autoBack = true,
  });

  final bool autoBack;

  @override
  State<UnLockPage> createState() => _UnLockPageState();
}

class _UnLockPageState extends State<UnLockPage> {
  UnlockPageController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.unlockToBack(
          context: context,
          autoBack: widget.autoBack,
        ));
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
        borderRadius: BorderRadius.circular(100),
        color: CupertinoColors.activeOrange,
        onPressed: () => controller.unlockToBack(
            context: context, autoBack: widget.autoBack),
        child: const Icon(
          CupertinoIcons.lock_fill,
          size: 50,
        ));
  }
}
