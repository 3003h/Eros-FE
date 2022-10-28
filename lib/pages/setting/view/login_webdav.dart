import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

    return Obx(() {
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
                      FontAwesomeIcons.cloud,
                      size: 120,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(height: 30),
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
                              child: const Icon(
                                FontAwesomeIcons.clipboard,
                                size: 30,
                              ).paddingOnly(bottom: 30, right: 28, top: 8),
                              onTap: controller.readFromClipboard,
                            ),
                            GestureDetector(
                              child: Icon(controller.obscurePasswd
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye)
                                  .paddingOnly(bottom: 30, right: 28, top: 8),
                              onTap: controller.switchObscure,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() {
                            return CupertinoButton(
                              minSize: 100,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              child: controller.testingConnect
                                  ? const CupertinoActivityIndicator()
                                  : Text('Test'),
                              color: CupertinoColors.activeOrange,
                              onPressed: () async {
                                // final rult = await controller.pressLoginWebDAV();
                                await controller.testWebDav();
                              },
                            );
                          }),
                          CupertinoButton(
                            minSize: 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            child: controller.loadingLogin
                                ? const CupertinoActivityIndicator()
                                : Text(L10n.of(context).login),
                            color: CupertinoColors.activeBlue,
                            onPressed: controller.loadingLogin
                                ? null
                                : () async {
                                    final result =
                                        await controller.pressLoginWebDAV();
                                    if (result != null && result) {
                                      Get.back(id: isLayoutLarge ? 2 : null);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
