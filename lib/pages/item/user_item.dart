import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/user.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/network/gallery_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  final String _normalText = '未登录';
  Color _color;
  final EhConfigController ehConfigController = Get.find();
  final UserController userController = Get.find();

  Future<void> _logOut(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
//      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('注销用户'),
          content: Text('确定注销?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () async {
                (await Api.cookieJar).deleteAll();
                // userController.user(User());
                userController.logOut();
                ehConfigController.isSiteEx.value = false;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void _tapItem() {
      if (Global.profile.user?.username != null) {
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
          return Text(_normalText);
        }
      });
    }

    final row = SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(
        // left: 16,
        top: 8,
        bottom: 8,
        // right: 16,
      ),
      child: Container(
        color: _color,
        child: Row(children: <Widget>[
          Icon(
//            CupertinoIcons.profile_circled,
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
      ),
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
      _color = null;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}
