import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  Color _color;
  Color _pBackgroundColor;
  final EhConfigService ehConfigService = Get.find();
  final UserController userController = Get.find();

  Future<void> _logOut(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('注销用户'),
          content: Text('确定注销?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
              onPressed: () async {
                (await Api.cookieJar).deleteAll();
                // userController.user(User());
                userController.logOut();
                ehConfigService.isSiteEx.value = false;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _color =
        CupertinoDynamicColor.resolve(ehTheme.itmeBackgroundColor, Get.context);
    _pBackgroundColor = _color;
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itmeBackgroundColor, context);
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    void _tapItem() {
      if (userController.isLogin) {
        _logOut(context);
      } else {
        // NavigatorUtil.jump(context, EHRoutes.login, rootNavigator: true);
        Get.toNamed(EHRoutes.login);
      }
    }

    Widget _buildText() {
      return Obx(() {
        if (userController.isLogin) {
          final String _userName = userController.user().username;
          return Text(_userName);
        } else {
          return Text(S.of(context).login);
        }
      });
    }

    final Widget row = Container(
      color: _color,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(children: <Widget>[
        const Icon(
          FontAwesomeIcons.solidUserCircle,
          size: 55.0,
          color: CupertinoColors.systemGrey,
        ),
        // 头像右侧信息
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _buildText(),
        )
      ]),
    );

//    return row;

    return GestureDetector(
      child: row,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _tapItem();
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color = CupertinoDynamicColor.resolve(
          ehTheme.itmeBackgroundColor, Get.context);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}
