import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/eh_login.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginCookiePage extends StatefulWidget {
  @override
  _LoginCookiePageState createState() => _LoginCookiePageState();
}

class _LoginCookiePageState extends State<LoginCookiePage> {
  bool _isLogin = false;

  // ibp_member_id
  final TextEditingController _idController = TextEditingController();

  // ibp_pass_hash
  final TextEditingController _hashController = TextEditingController();

  // igneous
  final TextEditingController _igneousController = TextEditingController();

  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cookie Login'),
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
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
                CupertinoTextField(
                  controller: _hashController,
                  decoration: null,
//                  prefix: Text('ibp_pass_hash'),
                  placeholder: 'ibp_pass_hash',
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
                CupertinoTextField(
                  controller: _igneousController,
                  decoration: null,
                  placeholder: 'igneous',
                ),
                Container(
                  height: 1,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
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
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )
          : Container(
              child: CupertinoButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  _loginCookie();
                },
              ),
            ),
    );
  }

  /// cookie登录
  Future<void> _loginCookie() async {
    loggerNoStack.i({
      'ibp_member_id': _idController.text,
      'ibp_pass_hash': _hashController.text,
      'igneous': _igneousController.text,
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

    FocusScope.of(context).requestFocus(FocusNode());
    User user;
    try {
      user = await EhUserManager().signInByCookie(
        _idController.text.trim(),
        _hashController.text.trim(),
        igneous: _igneousController.text.trim(),
      );
      userController.user(user);
    } catch (e) {
      showToast(e.toString());
      setState(() {
        _isLogin = false;
      });
      rethrow;
    }

    Get.back(result: true);
  }
}
