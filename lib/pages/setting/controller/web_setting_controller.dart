import 'dart:io' as io;

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebSettingController extends GetxController {
  final CookieManager _cookieManager = CookieManager.instance();

  late Future<void> setcookieFuture;

  Future<void> _setCookie() async {
    logger.d('_setCookie');
    // final List<io.Cookie>? cookies =
    //     await Global.cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));

    _cookieManager.deleteAllCookies();

    for (final io.Cookie cookie in Global.profile.user.cookies) {
      logger.v('name:${cookie.name} value:${cookie.value}');
      _cookieManager.setCookie(
          url: Uri.parse(Api.getBaseUrl()),
          name: cookie.name,
          value: cookie.value);
    }
  }

  @override
  void onInit() {
    super.onInit();
    setcookieFuture = _setCookie();
  }
}
