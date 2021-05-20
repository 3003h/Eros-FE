import 'dart:async';
import 'dart:io';

import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SplashController extends GetxController {
  late StreamSubscription _intentDataStreamSubscription;
  late String? sharedText = '';

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
        logger.i('value(memory): $value');
        sharedText = value;
        logger.i('Shared: $sharedText');
        startHome(sharedText ?? '');
      }, onError: (err) {
        logger.e('getLinkStream error: $err');
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((String? value) {
        // logger.i('value(closed): $value');
        sharedText = value ?? '';
        logger.v('Shared: $sharedText');
        startHome(sharedText ?? '');
      });
    }
  }

  Future<void> startHome(String url) async {
    if (url != null && url.isNotEmpty) {
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
