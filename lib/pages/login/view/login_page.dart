import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _placeholderStyle = kTextStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: CupertinoColors.placeholderText,
    );

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).user_login),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    LineIcons.userCircle,
                    size: 120,
                    color: CupertinoColors.activeBlue,
                  ),
                  const SizedBox(height: 40),
                  CupertinoFormSection.insetGrouped(
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    children: [
                      CupertinoTextFormFieldRow(
                        controller: controller.usernameController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        prefix: Row(
                          children: [
                            const Icon(LineIcons.user).paddingOnly(right: 4.0),
                            Text(L10n.of(context).user_name),
                          ],
                        ),
                        // placeholder: L10n.of(context).pls_i_username,
                        textAlign: TextAlign.right,
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(controller.nodePwd);
                        },
                      ),
                      GetBuilder<LoginController>(
                        builder: (logic) {
                          return CupertinoTextFormFieldRow(
                            controller: controller.passwdController,
                            style: kTextStyle,
                            placeholderStyle: _placeholderStyle,
                            prefix: Row(
                              children: [
                                GestureDetector(
                                  child: Icon(logic.obscurePasswd
                                          ? LineIcons.eyeSlash
                                          : LineIcons.eye)
                                      .paddingOnly(right: 4.0),
                                  onTap: logic.switchObscure,
                                ),
                                Text(L10n.of(context).passwd),
                              ],
                            ),
                            // placeholder: L10n.of(context).pls_i_passwd,
                            textAlign: TextAlign.right,
                            obscureText: logic.obscurePasswd,
                            focusNode: logic.nodePwd,
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: GetBuilder<LoginController>(
                      builder: (logic) {
                        return CupertinoButton(
                          child: logic.loadingLogin
                              ? const CupertinoActivityIndicator()
                              : Text(L10n.of(context).login),
                          color: CupertinoColors.activeBlue,
                          onPressed:
                              logic.loadingLogin ? null : logic.pressLogin,
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // web登陆
                      CupertinoButton(
                        minSize: 50,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: const [
                            Icon(
                              LineIcons.globeWithAmericasShown,
                              size: 30,
                            ),
                            Text('Web', textScaleFactor: 0.8),
                          ],
                        ),
                        onPressed: controller.handOnWeblogin,
                      ),
                      // cookie登陆
                      CupertinoButton(
                        minSize: 50,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: const [
                            Icon(
                              LineIcons.cookieBite,
                              size: 30,
                            ),
                            Text('Cookie', textScaleFactor: 0.8),
                          ],
                        ),
                        onPressed: controller.hanOnCookieLogin,
                      ),
                    ],
                  ).paddingSymmetric(vertical: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
