import 'dart:async';
import 'dart:io';

import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SplashController extends GetxController {
  late StreamSubscription _intentDataStreamSubscription;
  late String? sharedText = '';
  final AutoLockController _autoLockController = Get.find();

  @override
  void onInit() {
    super.onInit();
    if (!Platform.isIOS && !Platform.isAndroid) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        Get.offNamed(EHRoutes.home);
      });
    } else {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen((String value) {
        logger.d('value(memory): $value');
        sharedText = value;
        logger.d('Shared: $sharedText');
        _startHome(sharedText ?? '');
      }, onError: (err) {
        logger.e('getLinkStream error: $err');
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((String? value) {
        // logger.i('value(closed): $value');
        sharedText = value ?? '';
        logger.v('Shared: $sharedText');
        _startHome(sharedText ?? '');
      });
    }
  }

  Future<void> _startHome(String url) async {
    await _autoLockController.resumed(forceLock: true);

    if (url.isNotEmpty) {
      // 通过外部链接关联打开的时候
      logger.i('open $url');
      await Future<void>.delayed(const Duration(milliseconds: 100), () {
        NavigatorUtil.goGalleryDetailReplace(Get.context!, url: url);
      });
    } else {
      // logger.i('url is Empty,jump to home');
      await Future<void>.delayed(const Duration(milliseconds: 800), () {
        Get.offNamed(EHRoutes.home);
      });
    }
  }
}
