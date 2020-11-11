import 'dart:io';
import 'dart:ui';

import 'package:FEhViewer/common/eh_login.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/models/user.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_cookie_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _nodePwd = FocusNode();

  //账号的控制器
  final TextEditingController _usernameController = TextEditingController();

  //密码的控制器
  final TextEditingController _passwdController = TextEditingController();

  bool _isLogin = false;
  bool _isWebLogin = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(ln.user_login),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 38,
                    child: CupertinoTextField(
                      selectionHeightStyle: BoxHeightStyle.max,
                      style: TextStyle(textBaseline: TextBaseline.alphabetic),
                      controller: _usernameController,
                      placeholder: ln.pls_i_username,
                      prefix: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 50),
                          child: Text(ln.user_name)),
                      // prefixMode: OverlayVisibilityMode.never,
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
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  ),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.only(top: 10, bottom: 0),
                    child: CupertinoTextField(
                      style: const TextStyle(
                          textBaseline: TextBaseline.alphabetic),
                      controller: _passwdController,
                      placeholder: ln.pls_i_passwd,
                      prefix: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 50),
                          child: Text(ln.passwd)),
                      // prefixMode: OverlayVisibilityMode.never,
                      decoration: null,
                      obscureText: true,
                      focusNode: _nodePwd,
                      onEditingComplete: () {
                        // 点击键盘完成 帐号密码都非空的情况 直接登录
                        _login();
                      },
                    ),
                  ),
                  Container(
                    height: 1,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  ),
                  // 直接登录按钮
                  _buildLoginButton(ln),
                  // 网页登录按钮
                  _buildWebLoginButton(ln, context),
                  // Cookie登录按钮
                  _buildCookieLoginButton(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildLoginButton(S ln) {
    return Container(
      height: 60,
      child: _isLogin
          ? Container(
//              padding: const EdgeInsets.all(8),
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )
          : CupertinoButton(
              child: Text(ln.login),
//             color: CupertinoColors.activeBlue,
              onPressed: () {
                _login();
              },
            ),
    );
  }

  Widget _buildCookieLoginButton(BuildContext context) {
    return Container(
      height: 60,
      child: CupertinoButton(
        child: Text('cookie 登录'),
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return LoginCookiePage();
          })).then((result) {
            if (result ?? false) {
              NavigatorUtil.goBack(context);
            }
          });
        },
      ),
    );
  }

  Widget _buildWebLoginButton(S ln, BuildContext context) {
    return Container(
      height: 60,
      child: _isWebLogin
          ? Container(
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )
          : CupertinoButton(
              child: Text(ln.login_web),
              onPressed: () {
                if (!Platform.isIOS && !Platform.isAndroid) {
                  showToast('平台尚未支持');
                  return;
                }

                NavigatorUtil.goWebLogin(
                  context,
                  ln.login_web,
                  EHConst.URL_SIGN_IN,
                ).then((result) async {
                  if (result is Map) {
                    setState(() {
                      _isWebLogin = true;
                    });
                    try {
                      var user = await EhUserManager().signInByWeb(result);
                      Provider.of<UserModel>(context, listen: false).user =
                          user;
                      NavigatorUtil.goBack(context);
                    } catch (e) {
                      showToast(e.toString());
                      setState(() {
                        _isWebLogin = false;
                      });
                    }
                  }
                });
              },
            ),
    );
  }

  /// 用户登录
  Future<void> _login() async {
    Global.loggerNoStack.i({
      'username': _usernameController.text,
      'password': _passwdController.text
    });

    if (_usernameController.text.isEmpty || _passwdController.text.isEmpty) {
      showToast('username or password is empty');
      return;
    } else {
      setState(() {
        _isLogin = true;
      });
    }

    FocusScope.of(context).requestFocus(FocusNode());
    User user;
    try {
      user = await EhUserManager()
          .signIn(_usernameController.text, _passwdController.text);
      Provider.of<UserModel>(context, listen: false).user = user;
    } catch (e) {
      showToast(e.toString());
      setState(() {
        _isLogin = false;
      });
      rethrow;
    }

    if (user != null) {
      NavigatorUtil.goBack(context);
    }
  }
}
