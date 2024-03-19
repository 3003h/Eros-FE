import 'dart:async';
import 'dart:io';

import 'package:eros_fe/common/controller/auto_lock_controller.dart';
import 'package:eros_fe/common/parser/eh_parser.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/image_view/view/view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
        sharedText = value;
        logger.d('getTextStream Shared: $sharedText');
        _startHome(sharedText ?? '', replace: false);
      }, onError: (err) {
        logger.e('getTextStream error: $err');
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((String? value) {
        // logger.i('value(closed): $value');
        sharedText = value ?? '';
        logger.t('Shared: $sharedText');
        _startHome(sharedText ?? '');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription.cancel();
  }

  Future<void> _startHome(String url, {bool replace = true}) async {
    await _autoLockController.checkLock(forceLock: true);

    final RegExp regGalleryUrl =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
    final RegExp regGalleryPageUrl =
        RegExp(r'https://e[-x]hentai.org/s/[0-9a-z]+/\d+-\d+');
    final RegExp regTagUrl = RegExp(r'https?://e[-x]hentai.org/tag/(.+)/?');
    final RegExp regUploaderUrl =
        RegExp(r'https?://e[-x]hentai.org/uploader/(.+)/?');
    final RegExp regSearchUrl =
        RegExp(r'https?://e[-x]hentai.org/\?(f_search=.+)/?');

    if (url.isNotEmpty) {
      // 通过外部链接关联打开的时候
      debugPrint('open $url');
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
        () {
          final String currentRoute = Get.currentRoute;
          if (regGalleryUrl.hasMatch(url) || regGalleryPageUrl.hasMatch(url)) {
            final List<String> viewPageNames = <String>[
              '/${const ViewPage().runtimeType.toString()}',
              EHRoutes.galleryViewExt,
            ];

            final bool _replace = viewPageNames.contains(currentRoute);

            NavigatorUtil.goGalleryPage(
              url: url,
              replace: replace,
              forceReplace: _replace,
            );
          } else {
            late final String? searchText;
            if (regTagUrl.hasMatch(url)) {
              searchText = regTagUrl.firstMatch(url)?.group(1);
              if (sharedText != null) {
                NavigatorUtil.goSearchPageWithParam(
                  simpleSearch: searchText!,
                  replace: replace,
                );
              }
            } else if (regUploaderUrl.hasMatch(url)) {
              searchText = regUploaderUrl.firstMatch(url)?.group(1);
              if (sharedText != null) {
                NavigatorUtil.goSearchPageWithParam(
                  simpleSearch: 'uploader:${searchText!}',
                  replace: replace,
                );
              }
            } else if (regSearchUrl.hasMatch(url)) {
              final param = regSearchUrl.firstMatch(url)?.group(1);
              logger.d('param: $param');
              final uri = Uri.parse(param ?? '');
              final queryParameters = uri.queryParameters;
              searchText = queryParameters['f_search'];
              final advSearch = parserAdvanceSearch(param);
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
