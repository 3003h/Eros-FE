import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderStyle = kTextStyle.copyWith(
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
                    FontAwesomeIcons.circleUser,
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
                        placeholderStyle: placeholderStyle,
                        prefix: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.user,
                              size: 20,
                            ).paddingOnly(right: 12.0),
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
                            placeholderStyle: placeholderStyle,
                            prefix: Row(
                              children: [
                                GestureDetector(
                                  onTap: logic.switchObscure,
                                  child: Icon(
                                    logic.obscurePasswd
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    size: 20,
                                  ).paddingOnly(right: 12.0),
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
                        return CupertinoButton.filled(
                          // color: CupertinoColors.activeBlue,
                          onPressed:
                              logic.loadingLogin ? null : logic.pressLogin,
                          child: logic.loadingLogin
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  L10n.of(context).login,
                                  style: const TextStyle(height: 1.2),
                                ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // web登陆
                      if (GetPlatform.isMobile)
                        CupertinoButton(
                          minSize: 50,
                          padding: const EdgeInsets.all(20),
                          onPressed: controller.handOnWeblogin,
                          child: const Column(
                            children: [
                              Icon(
                                FontAwesomeIcons.earthAmericas,
                                size: 30,
                              ),
                              Text('Web',
                                  textScaler: const TextScaler.linear(0.8)),
                            ],
                          ),
                        ),
                      // cookie登陆
                      CupertinoButton(
                        minSize: 50,
                        padding: const EdgeInsets.all(20),
                        onPressed: controller.hanOnCookieLogin,
                        child: const Column(
                          children: [
                            Icon(
                              FontAwesomeIcons.cookieBite,
                              size: 30,
                            ),
                            Text('Cookie',
                                textScaler: const TextScaler.linear(0.8)),
                          ],
                        ),
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
