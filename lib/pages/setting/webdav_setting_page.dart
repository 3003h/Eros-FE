import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class WebDavSetting extends GetView<WebdavController> {
  const WebDavSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String _title = 'WebDAV';
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 5),
          middle: Text(_title),
          trailing: _buildListBtns(context),
        ),
        child: Obx(() {
          return SafeArea(
            child: controller.validAccount
                ? const WebDavSettingView()
                : Container(),
          );
        }),
      );
    });
  }

  Widget _buildListBtns(BuildContext context) {
    return Obx(() {
      return Container(
        child: controller.validAccount
            ? const SizedBox.shrink()
            : CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.arrowRightToBracket,
                  size: 28,
                ),
                onPressed: () async {
                  final result = await Get.toNamed(
                    EHRoutes.loginWebDAV,
                    id: isLayoutLarge ? 2 : null,
                  );
                  if (result != null && result is bool && result) {
                    Get.back();
                  }
                },
              ),
      );
    });
  }
}

class WebDavSettingView extends GetView<WebdavController> {
  const WebDavSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorSettingItem(
          title: L10n.of(context).webdav_Account,
          desc: controller.webdavProfile.user,
          onTap: () {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Logout?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(L10n.of(context).cancel),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(L10n.of(context).ok),
                      onPressed: () async {
                        // 登出WebDAV
                        Global.profile = Global.profile
                            .copyWith(webdav: const WebdavProfile(url: ''));
                        Global.saveProfile();
                        controller.initClient();
                        controller.closeClient();
                        Get.back();
                      },
                    ),
                  ],
                );
              },
            );
          },
          hideDivider: true,
        ),
        const ItemSpace(),
        TextSwitchItem(
          L10n.of(context).sync_history,
          intValue: controller.syncHistory,
          onChanged: (val) {
            controller.syncHistory = val;
          },
        ),
        TextSwitchItem(
          L10n.of(context).sync_read_progress,
          intValue: controller.syncReadProgress,
          onChanged: (val) {
            controller.syncReadProgress = val;
          },
        ),
        TextSwitchItem(
          L10n.of(context).sync_group,
          intValue: controller.syncGroupProfile,
          onChanged: (val) {
            controller.syncGroupProfile = val;
          },
        ),
        TextSwitchItem(
          L10n.of(context).sync_quick_search,
          hideDivider: true,
          intValue: controller.syncQuickSearch,
          onChanged: (val) {
            controller.syncQuickSearch = val;
          },
        ),
        const ItemSpace(),
        // if (kDebugMode) CatProgressIndicator(),
        const ItemSpace(),
        // if (kDebugMode)
        //   CircularProgressIndicator(
        //     backgroundColor: Colors.grey[200],
        //     valueColor: AlwaysStoppedAnimation(Colors.blue),
        //   ),
      ],
    );
  }
}

Future<void> showWebDAVLogin(BuildContext context) async {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final controller = Get.find<WebdavController>();

  final FocusNode _nodePwd = FocusNode();
  final FocusNode _nodeUname = FocusNode();
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CupertinoTextField(
              decoration: BoxDecoration(
                color: ehTheme.textFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: _urlController,
              placeholder: 'Url',
              autofocus: true,
              onEditingComplete: () {
                // 点击键盘完成
                FocusScope.of(context).requestFocus(_nodeUname);
              },
            ),
            Container(
              height: 10,
            ),
            CupertinoTextField(
              decoration: BoxDecoration(
                color: ehTheme.textFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: _unameController,
              placeholder: 'User',
              focusNode: _nodeUname,
              onEditingComplete: () {
                // 点击键盘完成
                FocusScope.of(context).requestFocus(_nodePwd);
              },
            ),
            Container(
              height: 10,
            ),
            CupertinoTextField(
              decoration: BoxDecoration(
                color: ehTheme.textFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: _pwdController,
              placeholder: 'Password',
              focusNode: _nodePwd,
              obscureText: true,
              onEditingComplete: () async {
                // 点击键盘完成
                final rult = await controller.addWebDAVProfile(
                  _urlController.text,
                  user: _unameController.text,
                  pwd: _pwdController.text,
                );
                if (rult) {
                  Get.back();
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(L10n.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          Obx(() {
            return CupertinoDialogAction(
              child: controller.isLongining
                  ? const CupertinoActivityIndicator()
                  : Text(L10n.of(context).ok),
              onPressed: controller.isLongining
                  ? null
                  : () async {
                      controller.isLongining = true;
                      final rult = await controller.addWebDAVProfile(
                        _urlController.text,
                        user: _unameController.text,
                        pwd: _pwdController.text,
                      );
                      if (rult) {
                        Get.back();
                      }
                    },
            );
          }),
        ],
      );
    },
  );
}
