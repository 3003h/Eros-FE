import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/models/user.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  final _normalText = "未登录";
  Color _color;

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
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () async {
                (await Api.cookieJar).deleteAll();
                Provider.of<UserModel>(context, listen: false).user = User();
                Provider.of<EhConfigModel>(context, listen: false).siteEx =
                    false;
                Navigator.of(context).pop();
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
        NavigatorUtil.jump(context, EHRoutes.login, rootNavigator: true);
      }
    }

    Widget _buildText() {
      return Consumer<UserModel>(
        builder: (BuildContext context, UserModel value, Widget child) {
          if (value.isLogin) {
            final _userName = value.user.username;
            return Text(_userName);
          } else {
            return Text(_normalText);
          }
        },
      );
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
      _color = CupertinoColors.systemBackground;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = CupertinoColors.systemGrey4;
    });
  }
}
