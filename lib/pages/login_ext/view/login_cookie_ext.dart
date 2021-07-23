import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/login_ext_controller.dart';

class LoginCookie extends GetView<LoginExtController> {
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
                    child: GetBuilder<LoginExtController>(
                      builder: (logic) {
                        return CupertinoButton(
                          child: logic.loadingLogin
                              ? const CupertinoActivityIndicator()
                              : Text(S.of(context).login),
                          color: CupertinoColors.activeBlue,
                          onPressed: logic.loadingLogin
                              ? null
                              : logic.pressLoginCookie,
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
