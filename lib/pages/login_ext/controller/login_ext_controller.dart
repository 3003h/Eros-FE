import 'dart:io';

import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/eh_login.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/login_ext/view/login_cookie_ext.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const TextStyle kTextStyle = TextStyle(
  fontSize: 18,
  textBaseline: TextBaseline.alphabetic,
  height: 1.2,
);

class LoginExtController extends GetxController {
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
    User user;
    try {
      user = await EhUserManager()
          .signIn(usernameController.text, passwdController.text);
      userController.user(user);
    } on EhError catch (e, stack) {
      logger.e('$e\n$stack');
      if (e.type == EhErrorType.login) {
        showToast('login fail');
      }
      // rethrow;
    } finally {
      loadingLogin = false;
      update();
    }

    Api.selEhProfile();

    Get.back();
  }

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

  Future<void> hanOnCookieLogin() async {
    final result = await Get.to(() => const LoginCookie());
    if (result != null && result is bool && result) {
      Api.selEhProfile();
      Get.back();
    }
  }

  Future<void> hanOnWeblogin() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      showToast('Platform not yet supported');
      return;
    }

    final dynamic result = await Get.toNamed(
      EHRoutes.webLogin,
      preventDuplicates: false,
    );
    logger.d(' $result');
    if (result != null && result is Map) {
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
    }
  }
}
