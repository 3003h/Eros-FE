import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

const TextStyle kTextStyle = TextStyle(
  fontSize: 18,
  textBaseline: TextBaseline.alphabetic,
  height: 1.2,
);

class LoginWebDAV extends GetView<WebdavController> {
  const LoginWebDAV({Key? key}) : super(key: key);

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
        middle: Text('WebDAV Login'),
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
                    LineIcons.mixcloud,
                    size: 120,
                    color: CupertinoColors.activeBlue,
                  ),
                  CupertinoFormSection.insetGrouped(
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    children: [
                      CupertinoTextFormFieldRow(
                        controller: controller.urlController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        // prefix: Text(''),
                        placeholder: 'Url',
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(controller.nodeUser);
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        controller: controller.usernameController,
                        style: kTextStyle,
                        placeholderStyle: _placeholderStyle,
                        // prefix: Text(''),
                        placeholder: 'Username',
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(controller.nodePwd);
                        },
                      ),
                      GetBuilder<WebdavController>(
                        builder: (controller) {
                          return CupertinoTextFormFieldRow(
                            controller: controller.passwdController,
                            style: kTextStyle,
                            placeholderStyle: _placeholderStyle,
                            // prefix: Text(''),
                            placeholder: 'Password',
                            obscureText: controller.obscurePasswd,
                          );
                        },
                      ),
                    ],
                  ),
                  GetBuilder<WebdavController>(
                    builder: (controller) {
                      return Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            child: Icon(controller.obscurePasswd
                                    ? LineIcons.eyeSlash
                                    : LineIcons.eye)
                                .paddingOnly(bottom: 30, right: 28),
                            onTap: controller.switchObscure,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 50,
                    child: GetBuilder<WebdavController>(
                      builder: (logic) {
                        return CupertinoButton(
                          child: logic.loadingLogin
                              ? const CupertinoActivityIndicator()
                              : Text(L10n.of(context).login),
                          color: CupertinoColors.activeBlue,
                          onPressed: logic.loadingLogin
                              ? null
                              : () async {
                                  final rult = await logic.pressLoginWebDAV();
                                  if (rult != null && rult) {
                                    logic.passwdController.text = '';
                                    Get.back();
                                  }
                                },
                        );
                      },
                    ),
                  ),
                  // CupertinoButton(
                  //   minSize: 50,
                  //   padding: const EdgeInsets.all(20),
                  //   child: Column(
                  //     children: [
                  //       const Icon(
                  //         LineIcons.clipboardAlt,
                  //         size: 30,
                  //       ),
                  //       Text(L10n.of(context).read_from_clipboard,
                  //           textScaleFactor: 0.8),
                  //     ],
                  //   ),
                  //   onPressed: controller.readCookieFromClipboard,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
