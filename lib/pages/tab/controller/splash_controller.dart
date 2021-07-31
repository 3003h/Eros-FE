import 'dart:async';
import 'dart:io';

import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
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

    final RegExp regGalleryUrl =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
    final RegExp regGalleryPageUrl =
        RegExp(r'https://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+');
    final RegExp regTagUrl = RegExp(r'https?://e[-x]hentai.org/tag/(.+)/?');
    final RegExp regUploaderUrl =
        RegExp(r'https?://e[-x]hentai.org/uploader/(.+)/?');

    if (url.isNotEmpty) {
      // 通过外部链接关联打开的时候
      debugPrint('open $url');
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
        () {
          if (regGalleryUrl.hasMatch(url) || regGalleryPageUrl.hasMatch(url)) {
            NavigatorUtil.goGalleryPage(url: url, replace: true);
          } else {
            late final String? searchText;
            if (regTagUrl.hasMatch(url)) {
              searchText = regTagUrl.firstMatch(url)?.group(1);
              if (sharedText != null) {
                NavigatorUtil.goGalleryListBySearch(
                  simpleSearch: searchText!,
                  replace: true,
                );
              }
            } else if (regUploaderUrl.hasMatch(url)) {
              searchText = regUploaderUrl.firstMatch(url)?.group(1);
              if (sharedText != null) {
                NavigatorUtil.goGalleryListBySearch(
                  simpleSearch: 'uploader:${searchText!}',
                  replace: true,
                );
              }
            }
          }
        },
      );
    } else {
      // logger.i('url is Empty,jump to home');
      await Future<void>.delayed(const Duration(milliseconds: 800), () {
        Get.offNamed(EHRoutes.home);
      });
    }
  }
}
