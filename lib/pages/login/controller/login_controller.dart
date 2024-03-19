import 'dart:convert';
import 'dart:io';

import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/login/view/login_cookie.dart';
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

  /// 用户登录
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
      // 这个 user
      user = await userLogin(usernameController.text, passwdController.text);
      logger.d('user: ${user?.toJson()}');
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
      userController.user(user.copyWith(username: usernameController.text.oN));
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

    final memberId = idController.text.trim();
    final passHash = hashController.text.trim();
    final igneous = igneousController.text.trim();

    if (memberId.isEmpty || passHash.isEmpty) {
      showToast('ibp_member_id or ibp_pass_hash is empty');
      return;
    } else {
      loadingLogin = true;
      update();
    }

    FocusScope.of(Get.context!).requestFocus(FocusNode());

    final List<Cookie> cookies = <Cookie>[
      Cookie('ipb_member_id', memberId),
      Cookie('ipb_pass_hash', passHash),
      if (igneous.isNotEmpty) Cookie('igneous', igneous),
    ];

    // final PersistCookieJar cookieJar = await Api.cookieJar;

    // 设置EH的cookie
    // cookieJar.saveFromResponse(Uri.parse(EHConst.EH_BASE_URL), cookies);

    final user = userController.user.value.copyWith(
      username: '${memberId.substring(0, 1)}****'.oN,
      memberId: memberId.oN,
      passHash: _getCookiesValue(cookies, 'ipb_pass_hash')?.oN,
      igneous: _getCookiesValue(cookies, 'igneous')?.oN,
      hathPerks: _getCookiesValue(cookies, 'hath_perks')?.oN,
      sk: _getCookiesValue(cookies, 'sk')?.oN,
    );

    logger.d('user ${user.toJson()}');

    userController.user(user);

    try {
      await asyncGetUserInfo(memberId);
    } catch (e) {
      loadingLogin = false;
      update();
      return;
    }

    Get.back(result: true);
    Api.selEhProfile();
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
      // final PersistCookieJar cookieJar = await Api.cookieJar;

      // 设置EH的cookie
      // cookieJar.saveFromResponse(Uri.parse(EHConst.EH_BASE_URL), cookies);

      final memberId = _getCookiesValue(cookies, 'ipb_member_id')?.trim();
      final passHash = _getCookiesValue(cookies, 'ipb_pass_hash')?.trim();

      if (memberId == null ||
          memberId == '0' ||
          memberId.isEmpty ||
          passHash == null ||
          passHash.isEmpty) {
        return;
      }

      final user = userController.user.value.copyWith(
        username: '${memberId.substring(0, 1)}****'.oN,
        memberId: memberId.oN,
        passHash: _getCookiesValue(cookies, 'ipb_pass_hash')?.oN,
        igneous: _getCookiesValue(cookies, 'igneous')?.oN,
        hathPerks: _getCookiesValue(cookies, 'hath_perks')?.oN,
        sk: _getCookiesValue(cookies, 'sk')?.oN,
      );

      logger.d('>>>>>>>>>>>>>>>> user ${user.toJson()}');

      userController.user(user);

      if (memberId.isNotEmpty) {
        asyncGetUserInfo(memberId);
        Api.selEhProfile();
      }

      Get.back();
    }
  }

  Future<void> asyncGetUserInfo([String? memberId]) async {
    memberId ??= userController.user.value.memberId;
    if (memberId == null) {
      return;
    }
    // 异步获取昵称和头像
    logger.d('异步获取昵称和头像');
    late User? info;
    try {
      info = await getUserInfo(memberId);
    } catch (e) {
      showToast('$e');
      rethrow;
    }

    userController.user(userController.user.value.copyWith(
      nickName: info?.nickName?.oN,
      avatarUrl: info?.avatarUrl?.oN,
    ));
    userController.update();
  }

  Future<void> readCookieFromClipboard() async {
    final kMatchMenberId = RegExp(r'^\d+$');
    final kMatchPassHash = RegExp(r'^[\da-f]{32}$');
    final kMatchIgneous = RegExp(r'^[\da-f]+$');

    final String _clipText =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    // logger.d('Clipboard:\n' + _clipText);
    if (!_clipText.contains('{')) {
      final textArray = _clipText.split(RegExp(r'[\s:;&=]'));
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

  String? _getCookiesValue(List<Cookie> cookies, String name) {
    return cookies.firstWhereOrNull((e) => e.name == name)?.value;
  }

  void switchObscure() {
    obscurePasswd = !obscurePasswd;
    update();
  }

  Future<void> hanOnCookieLogin() async {
    final result = await Get.to(() => const LoginCookie());
    if (result != null && result is bool && result) {
      Api.selEhProfile();
      Get.back();
    }
  }
}
