import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart' hide Response;

class EhCookieInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final cookieHeader =
          options.headers[HttpHeaders.cookieHeader] as String? ?? '';
      final cookiesString = cookieHeader.isNotEmpty ? cookieHeader : 'nw=1';
      logger.t('${options.uri} before checkCookies:$cookiesString');
      final cookies = cookiesString
          .split(';')
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      logger.t('_cookies:$cookies');

      checkCookies(cookies);
      logger.t('after checkCookies:$cookies');

      saveCookieToUser(cookies);

      options.headers[HttpHeaders.cookieHeader] = getCookies(cookies);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveCookies(response)
        .then((_) => super.onResponse(response, handler))
        .catchError((e, StackTrace? stackTrace) {
      DioException err = DioException(
          requestOptions: response.requestOptions,
          error: e,
          stackTrace: stackTrace);
      handler.reject(err, true);
    });
  }

  // 保存cookie
  Future<void> _saveCookies(Response response) async {
    logger.t('response.headers: ${response.headers}');
    final setCookiesFromResponse =
        response.headers[HttpHeaders.setCookieHeader];

    if (setCookiesFromResponse != null) {
      logger.t('set-cookie:$setCookiesFromResponse');
      final setCookies = setCookiesFromResponse
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      logger.d('_set setCookiesFromResponse $setCookies');

      saveCookieToUser(setCookies);
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  static String? getCookiesValue(List<Cookie> cookies, String name) {
    return cookies.firstWhereOrNull((e) => e.name == name)?.value;
  }

  // 检查并处理cookie
  void checkCookies(List<Cookie> cookies) {
    final UserController userController = Get.find();

    final nw = cookies.firstWhereOrNull((element) => element.name == 'nw');
    if (nw != null) {
      nw.value = '1';
    } else {
      cookies.add(Cookie('nw', '1'));
    }

    if (!userController.isLogin) {
      return;
    }

    final user = userController.user.value;

    updateCookie(cookies, 'ipb_member_id', user.memberId);
    updateCookie(cookies, 'ipb_pass_hash', user.passHash);
    updateCookie(cookies, 'igneous', user.igneous);
    updateCookie(cookies, 'hath_perks', user.hathPerks);
    updateCookie(cookies, 'sk', user.sk);
    updateCookie(cookies, 'star', user.star);
    updateCookie(cookies, 'yay', user.yay);
    updateCookie(cookies, 'iq', user.iq);
  }

  void updateCookie(List<Cookie> cookies, String name, String? value) {
    if (value != null && value.isNotEmpty) {
      final tempCookie =
          cookies.firstWhereOrNull((element) => element.name == name);
      if (tempCookie != null) {
        tempCookie.value = value;
      } else {
        cookies.add(Cookie(name, value));
      }
    }
  }

  void saveCookieToUser(List<Cookie> cookies) {
    final UserController userController = Get.find();
    final igneous = getCookiesValue(cookies, 'igneous');
    final newSk = getCookiesValue(cookies, 'sk') ?? '';

    userController.user(userController.user.value.copyWith(
      memberId: getCookiesValue(cookies, 'ipb_member_id')?.oN,
      passHash: getCookiesValue(cookies, 'ipb_pass_hash')?.oN,
      igneous: igneous != 'mystery' && igneous != '' ? igneous?.oN : null,
      hathPerks: getCookiesValue(cookies, 'hath_perks')?.oN,
      sk: newSk.isNotEmpty ? newSk.oN : null,
      star: getCookiesValue(cookies, 'star')?.oN,
      yay: getCookiesValue(cookies, 'yay')?.oN,
      iq: getCookiesValue(cookies, 'iq')?.oN,
    ));

    logger.t('user: ${userController.user.value.toJson()}');
  }
}
