import 'dart:io' as io;

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebSettingController extends GetxController {
  final CookieManager _cookieManager = CookieManager.instance();

  late Future<void> setcookieFuture;

  Future<void> _setCookie() async {
    final List<io.Cookie>? cookies =
        await Global.cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));

    for (final io.Cookie cookie in cookies ?? []) {
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
