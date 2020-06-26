import 'package:FEhViewer/client/eh_login.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/models/user.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  FocusNode _nodePwd = FocusNode();

  //账号的控制器
  TextEditingController _usernameController = TextEditingController();

  //密码的控制器
  TextEditingController _passwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('用户登录'),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(50, 40, 50, 20),
            child: Column(
              children: <Widget>[
                Container(
                  height: 38,
                  child: CupertinoTextField(
                    controller: _usernameController,
                    placeholder: "请输入账号",
                    prefix: Container(width: 50, child: Text('账号')),
                    decoration: null,
                    // autofocus 自动获得焦点
//                    autofocus: true,
                    onEditingComplete: () {
                      // 点击键盘完成 焦点跳转密码输入框
                      FocusScope.of(context).requestFocus(_nodePwd);
                    },
                  ),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.systemGrey4,
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(top: 10, bottom: 0),
                  child: CupertinoTextField(
                    controller: _passwdController,
                    placeholder: '请输入密码',
                    prefix: Container(width: 50, child: Text('密码')),
                    decoration: null,
                    obscureText: true,
                    focusNode: _nodePwd,
                  ),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.systemGrey4,
                ),
                CupertinoButton(
                  child: Text('登录'),
//                  color: CupertinoColors.activeBlue,
                  onPressed: () {
                    _login();
                  },
                ),
                CupertinoButton(
                  child: Text('通过网页登录'),
                  onPressed: () {
                    debugPrint('通过网页登录');
                    NavigatorUtil.goWebLogin(
                        context, "网页登录", EHConst.URL_SIGN_IN);
                  },
                )
              ],
            ),
          ),
        ));
  }

  /// 用户登录
  void _login() async {
    print({
      'username': _usernameController.text,
      'password': _passwdController.text
    });
    User user;
    try {
      user = await EhUserManager()
          .signIn(_usernameController.text, _passwdController.text);
      Provider.of<UserModel>(context, listen: false).user = user;
    } catch (e) {
      showToast(e.toString());
    }

    if (user != null) {
      NavigatorUtil.goBack(context);
    }
  }
}
