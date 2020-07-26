import 'package:FEhViewer/common/eh_login.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginCookiePage extends StatefulWidget {
  @override
  _LoginCookiePageState createState() => _LoginCookiePageState();
}

class _LoginCookiePageState extends State<LoginCookiePage> {
  var _isLogin = false;

  FocusNode _nodeHash = FocusNode();

  // ibp_member_id
  TextEditingController _idController = TextEditingController();

  // ibp_pass_hash
  TextEditingController _hashController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('cookie 登录'),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: <Widget>[
                CupertinoTextField(
                  controller: _idController,
                  decoration: null,
//                  prefix: Text('ibp_member_id'),
                  placeholder: 'ibp_member_id',
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: CupertinoColors.systemGrey4,
                ),
                CupertinoTextField(
                  controller: _hashController,
                  decoration: null,
//                  prefix: Text('ibp_pass_hash'),
                  placeholder: 'ibp_pass_hash',
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.systemGrey4,
                ),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildLoginButton() {
    return Container(
      height: 60,
      child: _isLogin
          ? Container(
              child: CupertinoActivityIndicator(
                radius: 14.0,
                iOSVersionStyle:
                    CupertinoActivityIndicatorIOSVersionStyle.iOS14,
              ),
            )
          : Container(
              child: CupertinoButton(
                child: Text('Ok'),
                onPressed: () {
                  _loginCookie();
                },
              ),
            ),
    );
  }

  /// cookie登录
  void _loginCookie() async {
    Global.loggerNoStack.i({
      'ibp_member_id': _idController.text,
      'ibp_pass_hash': _hashController.text
    });

    if (_idController.text.trim().isEmpty ||
        _hashController.text.trim().isEmpty) {
      showToast('ibp_member_id or ibp_pass_hash is empty');
      return;
    } else {
      setState(() {
        _isLogin = true;
      });
    }

    User user;
    try {
      user = await EhUserManager().signInByCookie(
          _idController.text.trim(), _hashController.text.trim());
      Provider.of<UserModel>(context, listen: false).user = user;
    } catch (e) {
      showToast(e.toString());
      setState(() {
        _isLogin = false;
      });
      throw e;
    }

    if (user != null) {
      Navigator.pop(context, true);
    }
  }
}
