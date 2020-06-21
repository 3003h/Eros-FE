import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/fehviewer/route/navigator_util.dart';
import 'package:FEhViewer/fehviewer/route/routes.dart';
import 'package:FEhViewer/models/provider/userModel.dart';
import 'package:FEhViewer/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class UserItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  final _normalText = "未登录";
  Color _color;

  @override
  Widget build(BuildContext context) {
    void _tapItem() {
      if (Global.profile.user?.username != null) {
        debugPrint(Global.profile.user.username);
        User user = User();
        Provider.of<UserModel>(context, listen: false).user = user;
      } else {
        NavigatorUtil.jump(context, EHRoutes.login);
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
            CupertinoIcons.profile_circled,
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
