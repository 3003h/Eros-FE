import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../controller/login_ext_controller.dart';

class LoginExtPage extends GetView<LoginExtController> {
  const LoginExtPage({Key? key}) : super(key: key);

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
          middle: Text(S.of(context).user_login),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // web登陆
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  LineIcons.globeWithAmericasShown,
                  size: 26,
                ),
                onPressed: controller.hanOnWeblogin,
              ),
              // cookie登陆
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  LineIcons.cookieBite,
                  size: 26,
                ),
                onPressed: controller.hanOnCookieLogin,
              ),
            ],
          )),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                            Icon(LineIcons.user).paddingOnly(right: 4.0),
                            Text(S.of(context).user_name),
                          ],
                        ),
                        placeholder: S.of(context).pls_i_username,
                        textAlign: TextAlign.right,
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(controller.nodePwd);
                        },
                      ),
                      GetBuilder<LoginExtController>(
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
                                Text(S.of(context).passwd),
                              ],
                            ),
                            placeholder: S.of(context).pls_i_passwd,
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
                    child: GetBuilder<LoginExtController>(
                      builder: (logic) {
                        return CupertinoButton(
                          child: logic.loadingLogin
                              ? const CupertinoActivityIndicator()
                              : Text(S.of(context).login),
                          color: CupertinoColors.activeBlue,
                          onPressed:
                              logic.loadingLogin ? null : logic.pressLogin,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
