import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/eh_login.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/login/view/login_cookie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const TextStyle kTextStyle = TextStyle(
  fontSize: 18,
  textBaseline: TextBaseline.alphabetic,
  height: 1.2,
);

class LoginController extends GetxController {
  final FocusNode nodePwd = FocusNode();

  //账号的控制器
  final TextEditingController usernameController = TextEditingController();

  //密码的控制器
  final TextEditingController passwdController = TextEditingController();

  // ibp_member_id
  final TextEditingController idController = TextEditingController();

  // ibp_pass_hash
  final TextEditingController hashController = TextEditingController();

  // igneous
  final TextEditingController igneousController = TextEditingController();

  final UserController userController = Get.find();

  bool loadingLogin = false;

  bool obscurePasswd = true;

  /// 普通用户登录
  Future<void> pressLogin() async {
    if (loadingLogin) {
      return;
    }

    loggerNoStack.i({
      'username': usernameController.text,
      'password': passwdController.text
    });

    if (usernameController.text.isEmpty || passwdController.text.isEmpty) {
      showToast('username or password is empty');
      return;
    } else {
      loadingLogin = true;
      update();
    }

    FocusScope.of(Get.context!).requestFocus(FocusNode());
    User? user;
    try {
      // user = await EhUserManager()
      //     .signIn(usernameController.text, passwdController.text);
      user = await userLogin(usernameController.text, passwdController.text);
    } on EhError catch (e, stack) {
      logger.e('$e\n$stack');
      if (e.type == EhErrorType.login) {
        showToast('Login fail');
      }
    } finally {
      loadingLogin = false;
      update();
    }

    if (user != null && user.cookie.isNotEmpty) {
      userController.user(user.copyWith(username: usernameController.text));
      Api.selEhProfile();

      asyncGetUserInfo(user.memberId!);
    }

    Get.back();
  }

  // cookie登陆
  Future<void> pressLoginCookie() async {
    if (loadingLogin) {
      return;
    }

    loggerNoStack.i({
      'ibp_member_id': idController.text,
      'ibp_pass_hash': hashController.text,
      'igneous': igneousController.text,
    });

    if (idController.text.trim().isEmpty ||
        hashController.text.trim().isEmpty) {
      showToast('ibp_member_id or ibp_pass_hash is empty');
      return;
    } else {
      loadingLogin = true;
      update();
    }

    FocusScope.of(Get.context!).requestFocus(FocusNode());
    User user;
    try {
      user = await EhUserManager().signInByCookie(
        idController.text.trim(),
        hashController.text.trim(),
        igneous: igneousController.text.trim(),
      );
      userController.user(user);
    } catch (e) {
      showToast(e.toString());
      loadingLogin = false;
      update();
      rethrow;
    }

    Get.back(result: true);
  }

  void switchObscure() {
    obscurePasswd = !obscurePasswd;
    update();
  }

  Future<void> asyncGetUserInfo(String memberId) async {
    // 异步获取昵称和头像
    logger.d('异步获取昵称和头像');
    final info = await getUserInfo(memberId);
    userController.user(userController.user.value.copyWith(
      nickName: info?.nickName,
      avatarUrl: info?.avatarUrl,
    ));
  }

  Future<void> hanOnCookieLogin() async {
    final result = await Get.to(() => const LoginCookie());
    if (result != null && result is bool && result) {
      Api.selEhProfile();
      Get.back();
    }
  }

  /// 网页登陆
  Future<void> handOnWeblogin() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      showToast('Platform not yet supported');
      return;
    }

    final cookies = await Get.toNamed(
      EHRoutes.webLogin,
      preventDuplicates: false,
    );
    logger.d(' $cookies');

    if (cookies != null && cookies is List<Cookie>) {
      final PersistCookieJar cookieJar = await Api.cookieJar;

      // 设置EH的cookie
      cookieJar.saveFromResponse(Uri.parse(EHConst.EH_BASE_URL), cookies);

      final memberId = getCookiesValue(cookies, 'ipb_member_id');

      if (memberId == null || memberId == '0') {
        return;
      }

      userController.user(userController.user.value.copyWith(
        username: memberId,
        memberId: memberId,
        passHash: getCookiesValue(cookies, 'ipb_pass_hash'),
        igneous: getCookiesValue(cookies, 'igneous'),
        hathPerks: getCookiesValue(cookies, 'hath_perks'),
        sk: getCookiesValue(cookies, 'sk'),
      ));

      if (memberId != null) {
        asyncGetUserInfo(memberId);
        Api.selEhProfile();
      }
    }

    /*if (result != null && result is Map) {
      loadingLogin = true;
      update();

      try {
        final User user = await EhUserManager().signInByWeb(result);
        userController.user(user);

        Api.selEhProfile();
        Get.back();
      } catch (e, stack) {
        showToast(e.toString());
        logger.e('$e\n$stack');
        loadingLogin = false;
        update();
      }
    }*/
  }

  Future<void> readCookieFromClipboard() async {
    final kMatchMenberId = RegExp(r'^\d+$');
    final kMatchPassHash = RegExp(r'^[0-9a-f]{32}$');
    final kMatchIgneous = RegExp(r'^[0-9a-f]+$');

    final String _clipText =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    // logger.d('Clipboard:\n' + _clipText);
    if (!_clipText.contains('{')) {
      final textArray = _clipText.split(RegExp(r'\s|:'));
      logger.d('textArray:$textArray');
      for (final _text in textArray) {
        if (kMatchMenberId.hasMatch(_text)) {
          logger.d('id:$_text');
          idController.text = _text;
          continue;
        }
        if (kMatchPassHash.hasMatch(_text)) {
          logger.d('passHash:$_text');
          hashController.text = _text;
          continue;
        }
        if (kMatchIgneous.hasMatch(_text)) {
          logger.d('igneous:$_text');
          igneousController.text = _text;
        }
      }
      return;
    }

    try {
      final jsonObj = jsonDecode(_clipText);
      final cookieList = jsonObj as List;
      final cookieMap = <String, String>{};
      for (final cookie in cookieList) {
        final _cookieMap = cookie as Map<String, dynamic>;
        final _name = _cookieMap['name'] as String;
        final _value = _cookieMap['value'] as String;
        cookieMap[_name] = _value;
      }
      idController.text = cookieMap['ipb_member_id'] ?? '';
      hashController.text = cookieMap['ipb_pass_hash'] ?? '';
      igneousController.text = cookieMap['igneous'] ?? '';
    } catch (e) {
      logger.e('$e');
    }
  }

  String? getCookiesValue(List<Cookie> cookies, String name) {
    return cookies.firstWhereOrNull((e) => e.name == name)?.value;
  }
}
