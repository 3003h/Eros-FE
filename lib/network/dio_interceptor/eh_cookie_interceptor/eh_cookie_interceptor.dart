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
      logger.t('${options.uri} befor checkCookies:$cookiesString');
      final _cookies = cookiesString
          .split(';')
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      logger.t('_cookies:$_cookies');

      checkCookies(_cookies);
      logger.t('after checkCookies:$_cookies');
      options.headers[HttpHeaders.cookieHeader] = getCookies(_cookies);
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
      DioError err = DioError(
          requestOptions: response.requestOptions,
          error: e,
          stackTrace: stackTrace);
      handler.reject(err, true);
    });
  }

  Future<void> _saveCookies(Response response) async {
    final UserController userController = Get.find();

    final cookies = response.headers[HttpHeaders.setCookieHeader];

    if (cookies != null) {
      logger.t('set-cookie:$cookies');
      final _cookies =
          cookies.map((str) => Cookie.fromSetCookieValue(str)).toList();
      logger.t('_set cookies $_cookies');

      final igneous = getCookiesValue(_cookies, 'igneous');
      final _newSk = getCookiesValue(_cookies, 'sk') ?? '';

      userController.user(userController.user.value.copyWith(
        memberId: getCookiesValue(_cookies, 'ipb_member_id')?.oN,
        passHash: getCookiesValue(_cookies, 'ipb_pass_hash')?.oN,
        igneous: igneous != 'mystery' && igneous != '' ? igneous?.oN : null,
        hathPerks: getCookiesValue(_cookies, 'hath_perks')?.oN,
        sk: _newSk.isNotEmpty ? _newSk.oN : null,
        star: getCookiesValue(_cookies, 'star')?.oN,
        yay: getCookiesValue(_cookies, 'yay')?.oN,
      ));

      // logger.t('new sk $_newSk');

      logger.t('${userController.user.value.toJson()}');
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  static String? getCookiesValue(List<Cookie> cookies, String name) {
    return cookies.firstWhereOrNull((e) => e.name == name)?.value;
  }

  void checkCookies(List<Cookie> cookies) {
    final UserController userController = Get.find();

    final _nw = cookies.firstWhereOrNull((element) => element.name == 'nw');
    if (_nw != null) {
      _nw.value = '1';
    } else {
      cookies.add(Cookie('nw', '1'));
    }

    if (!userController.isLogin) {
      return;
    }

    final memberId = userController.user.value.memberId;
    if (memberId != null && memberId.isNotEmpty) {
      final _c = cookies
          .firstWhereOrNull((element) => element.name == 'ipb_member_id');
      if (_c != null) {
        _c.value = memberId;
      } else {
        cookies.add(Cookie('ipb_member_id', memberId));
      }
    }

    final passHash = userController.user.value.passHash;
    if (passHash != null && passHash.isNotEmpty) {
      final _c = cookies
          .firstWhereOrNull((element) => element.name == 'ipb_pass_hash');
      if (_c != null) {
        _c.value = passHash;
      } else {
        cookies.add(Cookie('ipb_pass_hash', passHash));
      }
    }

    final igneous = userController.user.value.igneous;
    if (igneous != null && igneous.isNotEmpty) {
      final _c =
          cookies.firstWhereOrNull((element) => element.name == 'igneous');
      if (_c != null) {
        _c.value = igneous;
      } else {
        cookies.add(Cookie('igneous', igneous));
      }
    }

    final hathPerks = userController.user.value.hathPerks;
    if (hathPerks != null && hathPerks.isNotEmpty) {
      final _c =
          cookies.firstWhereOrNull((element) => element.name == 'hath_perks');
      if (_c != null) {
        _c.value = hathPerks;
      } else {
        cookies.add(Cookie('hath_perks', hathPerks));
      }
    }

    final sk = userController.user.value.sk;
    if (sk != null && sk.isNotEmpty) {
      final _c = cookies.firstWhereOrNull((element) => element.name == 'sk');
      if (_c != null) {
        _c.value = sk;
      } else {
        cookies.add(Cookie('sk', sk));
      }
    }

    final star = userController.user.value.star;
    if (star != null && star.isNotEmpty) {
      final _c = cookies.firstWhereOrNull((element) => element.name == 'star');
      if (_c != null) {
        _c.value = star;
      } else {
        cookies.add(Cookie('star', star));
      }
    }

    final yay = userController.user.value.yay;
    if (yay != null && yay.isNotEmpty) {
      final _c = cookies.firstWhereOrNull((element) => element.name == 'yay');
      if (_c != null) {
        _c.value = yay;
      } else {
        cookies.add(Cookie('star', yay));
      }
    }
  }
}
