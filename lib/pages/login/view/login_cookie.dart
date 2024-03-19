import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controller/login_controller.dart';

class LoginCookie extends GetView<LoginController> {
  const LoginCookie({Key? key}) : super(key: key);

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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cookie Login'),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    FontAwesomeIcons.cookieBite,
                    size: 120,
                    color: CupertinoColors.activeBlue,
                  ),
                  CupertinoFormSection.insetGrouped(
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    children: [
                      CupertinoTextFormFieldRow(
                        controller: controller.idController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        // prefix: Text(''),
                        placeholder: 'ibp_member_id',
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(controller.nodePwd);
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        controller: controller.hashController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        // prefix: Text(''),
                        placeholder: 'ibp_pass_hash',
                      ),
                      CupertinoTextFormFieldRow(
                        controller: controller.igneousController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        // prefix: Text(''),
                        placeholder: 'igneous',
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
                          onPressed: logic.loadingLogin
                              ? null
                              : logic.pressLoginCookie,
                        );
                      },
                    ),
                  ),
                  CupertinoButton(
                    minSize: 50,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          FontAwesomeIcons.clipboard,
                          size: 30,
                        ),
                        Text(L10n.of(context).read_from_clipboard,
                            textScaleFactor: 0.8),
                      ],
                    ),
                    onPressed: controller.readCookieFromClipboard,
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
